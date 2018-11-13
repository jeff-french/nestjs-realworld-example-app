#!/bin/bash

set -euo pipefail

set -x

whoami
sudo su - ec2-user
whoami
npm run prestart:prod
pm2 start dist/main.js --name api
exit
whoami
