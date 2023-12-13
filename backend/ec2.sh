#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/ec2-user/log.txt 2>&1
# everything below is logged 

sudo amazon-linux-extras install docker
docker run -p 80:80 -v /home/ec2-user/keys.env:/app/keys.env public.ecr.aws/q0a7p9w3/notes-prod:latest