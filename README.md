# FreePBX
https://hub.docker.com/r/izdock/izpbx-asterisk

# Docker run

docker run --restart always --net host --name freepbx -v /root/freepbx-backup:/backup -d -t blomron/freepbx:latest

# Deploy 

helm upgrade --install freepbx-chart ./freepbx-chart
