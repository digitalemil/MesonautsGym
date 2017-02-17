#!/bin/bash

SERVICE_ACCOUNT=mlb-principal
SERVICE_ACCOUNT_DESCRIPTION="Marathon-LB service account"
WORKING_DIRECTORY="$(dirname "$(readlink "$0")")/.config"

# Fail fast on errors
set -e

# Create working directory
mkdir -p "$WORKING_DIRECTORY"
cd "$WORKING_DIRECTORY"

# Install the DC/OS enterpise CLI
#dcos security -h > /dev/null || dcos package install dcos-enterprise-cli

# Verify that the service account does not yet exists
if  dcos security org service-accounts show $SERVICE_ACCOUNT > /dev/null
then

  echo "Service account $SERVICE_ACCOUNT already exist" >&2

else

  # Create a key pair
  dcos security org service-accounts keypair mlb-private-key.pem mlb-public-key.pem

  # Create a service account
  dcos security org service-accounts create -p mlb-public-key.pem -d "$SERVICE_ACCOUNT_DESCRIPTION" $SERVICE_ACCOUNT

fi


# Create a service account secret
if dcos security secrets create-sa-secret mlb-private-key.pem $SERVICE_ACCOUNT mlb-secret  > /dev/null
then

  echo "Secret mlb-secret already exists" >&2

fi

# Provision the service account with permissions
curl -k -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:services:%252F -d '{"description":"Allows access to any service launched by the native Marathon instance"}' -H 'Content-Type: application/json'
curl -k -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:admin:events -d '{"description":"Allows access to Marathon events"}' -H 'Content-Type: application/json'
curl -k -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:services:%252F/users/$SERVICE_ACCOUNT/read
curl -k -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:admin:events/users/$SERVICE_ACCOUNT/read

cat <<EOF > config.json
{
    "marathon-lb": {
        "secret_name": "mlb-secret"
    }
}
EOF

# Install Marathon-LB
dcos package install --options=config.json marathon-lb --yes

