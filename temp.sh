kubeadm init --pod-network-cidr=192.168.0.0/16 --upload-certs --control-plane-endpoint=157.173.197.79 --apiserver-advertise-address=157.173.197.79 --service-cidr=172.36.1.0/24 --v=5 --cri-socket  unix:///var/run/cri-dockerd.sock


/etc/nginx/cert/blockfree.fun