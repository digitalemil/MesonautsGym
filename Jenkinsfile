def gitCommit() {
        sh "git rev-parse HEAD > GIT_COMMIT"
        def gitCommit = readFile('GIT_COMMIT').trim()
        sh "rm -f GIT_COMMIT"
        return gitCommit
    }

    node {
        // Checkout source code from Git
        stage 'Checkout'
        checkout scm
      
dir ('UI') { 
        // Build Docker image
        stage 'Build'
        withCredentials(
            [[
                $class: 'UsernamePasswordMultiBinding',
                credentialsId: 'dockerhub',
                passwordVariable: 'DOCKERHUB_PASSWORD',
                usernameVariable: 'DOCKERHUB_USERNAME'
            ]]
        ) {
            sh "docker build -t ${env.DOCKERHUB_USERNAME}/${env.DOCKERHUB_REPO}:mesonautsgym-ui-v1.0.0 ."
        }
        // Log in and push image to GitLab
        stage 'Publish'
        withCredentials(
            [[
                $class: 'UsernamePasswordMultiBinding',
                credentialsId: 'dockerhub',
                passwordVariable: 'DOCKERHUB_PASSWORD',
                usernameVariable: 'DOCKERHUB_USERNAME'
            ]]
        ) {
            sh "docker login -u ${env.DOCKERHUB_USERNAME} -p ${env.DOCKERHUB_PASSWORD}"
            sh "docker push ${env.DOCKERHUB_USERNAME}/${env.DOCKERHUB_REPO}:mesonautsgym-ui-v1.0.0"
        }
}


        // Deploy
        stage 'Deploy'
        withCredentials(
            [[
                $class: 'UsernamePasswordMultiBinding',
                credentialsId: 'dockerhub',
                passwordVariable: 'DOCKERHUB_PASSWORD',
                usernameVariable: 'DOCKERHUB_USERNAME'
            ]]
        ) {
        marathon(
            url: 'http://marathon.mesos:8080',
            forceUpdate: true,
            credentialsId: 'dcos-token',
            filename: 'ui-config.tmp',
            id: '/dcosappstudio-mesonautsgym/management/ui',
            docker: '${env.DOCKERHUB_USERNAME}/${env.DOCKERHUB_REPO}:mesonautsgym-ui-v1.0.0'
        )
        }
    }
