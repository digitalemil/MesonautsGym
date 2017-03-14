#!/bin/bash
cp -r versions/1.0.0/* .
git add .
git commit -m "Downgraded to version 1.0.0"
git push origin master
