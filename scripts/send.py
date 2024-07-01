from web3 import Web3

# 自定义配置
rpc_url = "http://127.0.0.1:8545"  # 自定义的 RPC URL
chain_id = 1234  # 自定义的链 ID

# 钱包地址和私钥
sender_address = ""  # 发送者钱包地址
sender_private_key = ""  # 发送者钱包的私钥

# 接收者钱包地址和转账金额（以最小单位表示）
receiver_address = ""  # 接收者钱包地址
amount = 1000000000000000000  # 转账金额（示例为 1个币）

# 创建 Web3 实例
web3 = Web3(Web3.HTTPProvider(rpc_url))

# 构建交易对象
transaction = {
    "to": receiver_address,
    "value": amount,
    "gas": 21000,  # 设置默认的 gas 数量
    "gasPrice": web3.to_wei(50, "gwei"),  # 设置默认的 gas 价格
    "nonce": web3.eth.get_transaction_count(sender_address),
    "chainId": chain_id,
}

# 签名交易
signed_txn = web3.eth.account.sign_transaction(transaction, sender_private_key)

# 发送交易
tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

# 等待交易确认
tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

# 输出交易结果
print("Transaction Hash:", tx_receipt.transactionHash.hex())
print("Gas Used:", tx_receipt.gasUsed)
print("Status:", tx_receipt.status)