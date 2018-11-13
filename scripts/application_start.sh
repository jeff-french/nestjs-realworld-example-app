#!/bin/bash

sudo su - ec2-user
npm run prestart:prod
pm2 start dist/main.js --name api
exit
