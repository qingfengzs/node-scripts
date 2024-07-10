# 1
apt update && apt install build-essential git make jq curl clang pkg-config libssl-dev -y  && \
mkdir -p /data/airchains/ && cd /data/airchains/ && \
git clone https://github.com/airchains-network/evm-station.git &&\
git clone https://github.com/airchains-network/tracks.git && \
cd /data/airchains/evm-station && go mod tidy && \
/bin/bash ./scripts/local-setup.sh
# 会输出地址和助记词，建议保存输出的信息。
# 导入到leap钱包，查看积分

# 2
# 获取钱包私钥
# 把这个私钥导入小狐狸备用
/bin/bash ./scripts/local-keys.sh

# 3
# 检查成功
ls ~/.evmosd/ && sed -i.bak 's@address = "127.0.0.1:8545"@address = "0.0.0.0:8545"@' ~/.evmosd/config/app.toml

# 4
cat > /etc/systemd/system/evmosd.service << EOF
[Unit]
Description=evmosd node
After=network-online.target
[Service]
User=root
WorkingDirectory=/root/.evmosd
ExecStart=/data/airchains/evm-station/build/station-evm start --metrics "" --log_level "info" --json-rpc.api eth,txpool,personal,net,debug,web3 --chain-id "stationevm_1234-1"
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# 5
systemctl daemon-reload && systemctl enable evmosd && systemctl restart evmosd && systemctl status evmosd.service

# 6
wget https://github.com/airchains-network/tracks/releases/download/v0.0.2/eigenlayer && \
chmod +x eigenlayer && mv eigenlayer /usr/local/bin/eigenlayer && \
eigenlayer operator keys create  -i=true --key-type ecdsa eigen

# 7 替换public key
cd /data/airchains/tracks/ && make build  && \
/data/airchains/tracks/build/tracks init --daRpc "disperser-holesky.eigenda.xyz" --daKey "部署eigenlayer时生成的public key" --daType "eigen" --moniker "localtestnet" --stationRpc "http://127.0.0.1:8545" --stationAPI "http://127.0.0.1:8545" --stationType "evm"

# 领水
/data/airchains/tracks/build/tracks keys junction --accountName ssonix --accountPath $HOME/.tracks/junction-accounts/keys

# 8
/data/airchains/tracks/build/tracks prover v1EVM

# 9
grep node_id ~/.tracks/config/sequencer.toml

/data/airchains/tracks/build/tracks create-station --accountName ssonix --accountPath $HOME/.tracks/junction-accounts/keys --jsonRPC "https://airchains-rpc.kubenode.xyz/" --info "EVM Track" --tracks "air开头的钱包地址" --bootstrapNode "/ip4/本机IP地址/tcp/2300/p2p/上面获取到的nodeid"

# 10
cat > /etc/systemd/system/tracksd.service << EOF
[Unit]
Description=tracksd
After=network-online.target

[Service]
User=root
WorkingDirectory=/root/.tracks
ExecStart=/data/airchains/tracks/build/tracks start

Restart=always
RestartSec=10
LimitNOFILE=65535
SuccessExitStatus=0 1
[Install]
WantedBy=multi-user.target
EOF

# 11
systemctl daemon-reload && systemctl enable tracksd && systemctl restart tracksd

# 12
apt update && apt install python3-pip
pip3 install Web3

# 12 跑python脚本
while true; do python3 send.py; sleep 1; done
#################################################################################
# 看日志
journalctl -u evmosd -f
journalctl -u tracksd -f

# 回滚tracksd
/data/airchains/tracks/build/tracks rollback

# 看积分 链接leap
https://points.airchains.io/

# 设置定时重启
sudo bash -c 'echo -e "#!/bin/bash\n\n# 等待15秒\necho \"等待15秒...\"\nsleep 15\n\n# 重启tracksd服务\necho \"重启tracksd服务...\"\nsystemctl restart tracksd\necho \"tracksd服务已重启\"" > $HOME/restart_services.sh && chmod +x $HOME/restart_services.sh && (crontab -l 2>/dev/null; echo "0 6 * * * $HOME/restart_services.sh") | crontab -'

# 添加小狐狸RPC
# 把rpc改成https://airchains-rpc.kubenode.xyz
# 把LCD改成 https://airchains-api.kubenode.xyz
