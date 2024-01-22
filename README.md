# FreePBX
https://hub.docker.com/r/izdock/izpbx-asterisk

# Docker run

docker run --restart always --net host --name freepbx -v /root/freepbx-backup:/backup -d -t blomron/freepbx:latest

# Deploy 

helm secrets upgrade --install freepbx16-chart ./freepbx16-chart -f freepbx16-chart/secrets.yaml
