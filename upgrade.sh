#!/bin/bash
cp -r versions/2.0.0/* .
git add .
git commit -m "Upgraded to version 2.0.0"
git push origin master
