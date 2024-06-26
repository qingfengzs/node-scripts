# tracks/build/tracks init --daRpc "disperser-holesky.eigenda.xyz" --daKey "72d3aad021000911244768d8f78a0cff833efc450c23b4e66e1096b064cfbf5c35d98c658b57809b380b6e205a631d904dd4a2fc584154ea8d12f9e6169c942a" --daType "eigen" --moniker "ssonix-1" --stationRpc "http://127.0.0.1:8545" --stationAPI "http://127.0.0.1:8545" --stationType "evm"

# tracks/build/tracks keys junction --accountName ssonix --accountPath $HOME/.tracks/junction-accounts/keys

# tracks/build/tracks create-station --accountName ssonix --accountPath $HOME/.tracks/junction-accounts/keys --jsonRPC "https://airchains-rpc.kubenode.xyz/" --info "EVM Track" --tracks "air19ppt9qsww4qt8t7mpkc2wc0r9nu2tnfj6nqexx" --bootstrapNode "/ip4/154.12.242.62/tcp/2300/p2p/12D3KooWLcMFkzcuxGxJpJubkMBLr3U9k81hvcRsn6ZLsyNRDRCN"

# 1
apt update && apt install build-essential git make jq curl clang pkg-config libssl-dev -y  && \
mkdir -p /data/airchains/ && cd /data/airchains/ && \
git clone https://github.com/airchains-network/evm-station.git &&\
git clone https://github.com/airchains-network/tracks.git && \
cd /data/airchains/evm-station  && go mod tidy && \
cd /data/airchains/evm-station  && go mod tidy && \
/bin/bash ./scripts/local-setup.sh
# 会输出地址和助记词，建议保存输出的信息。


# 2
# 获取钱包私钥
# 把这个私钥导入小狐狸备用
/bin/bash ./scripts/local-keys.sh

# 3
# 检查成功
ls ~/.evmosd/ && sed -i.bak 's@address = "127.0.0.1:8545"@address = "0.0.0.0:8545"@' ~/.evmosd/config/app.toml && \
/bin/bash ./scripts/local-start.sh

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

# 7
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
# 看日志
journalctl -u tracksd -f

# 12 跑python脚本


# 看积分 链接leap
https://points.airchains.io/

# 添加小狐狸RPC
# 把rpc改成https://airchains-rpc.kubenode.xyz
# 把LCD改成 https://airchains-api.kubenode.xyz