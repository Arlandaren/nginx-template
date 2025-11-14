#!/bin/bash

cd /home/nginx

if [ "$1" = "-f" ]; then
    docker compose logs nginx -f
else
    docker compose logs nginx
fi
