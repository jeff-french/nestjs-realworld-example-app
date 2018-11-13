#!/bin/bash

npm run prestart:prod
pm2 start dist/main.js --name api
