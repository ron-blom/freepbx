FreePBX

# Docker build and push

docker build -t blomron/freepbx .

docker push blomron/freepbx

# Docker run

docker run --restart always --net host --name freepbx -v /root/freepbx-backup:/backup -d -t blomron/freepbx:latest

# Deploy 

helm upgrade --install freepbx-chart ./freepbx-chart
