#!/bin/bash

set -exo pipefail

source /home/ec2-user/.bash_profile

pm2 start /app/index.js --name api
