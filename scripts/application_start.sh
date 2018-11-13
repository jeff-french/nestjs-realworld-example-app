#!/bin/bash

set -exuo pipefail

source /home/ec2-user/.bash_profile

npm run prestart:prod
pm2 start dist/main.js --name api
