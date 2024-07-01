from web3 import Web3
import random
import os
import json

# 自定义配置
rpc_url = "http://127.0.0.1:8545"  # 自定义的 RPC URL
chain_id = 1234  # 自定义的链 ID
account_file = "accounts.txt"
initial_account = {
    "address": "你的初始账户地址",
    "private_key": "你的初始账户私钥"
}

# 创建 Web3 实例
web3 = Web3(Web3.HTTPProvider(rpc_url))

# 创建或读取账户
def get_or_create_accounts():
    if os.path.exists(account_file):
        with open(account_file, 'r') as f:
            return json.load(f)
    else:
        accounts = [
            {"address": web3.eth.account.create().address,
             "private_key": web3.eth.account.create().privateKey.hex()}
            for _ in range(25)
        ]
        with open(account_file, 'w') as f:
            json.dump(accounts, f)
        return accounts

# 转账函数
def transfer(sender_address, sender_private_key, receiver_address, amount):
    transaction = {
        "to": receiver_address,
        "value": amount,
        "gas": 21000,
        "gasPrice": web3.to_wei(50, "gwei"),
        "nonce": web3.eth.get_transaction_count(sender_address),
        "chainId": chain_id,
    }

    signed_txn = web3.eth.account.sign_transaction(transaction, sender_private_key)
    tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)
    tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

    print(f"交易从 {sender_address} 到 {receiver_address}")
    print("交易哈希:", tx_receipt.transactionHash.hex())
    print("使用的Gas:", tx_receipt.gasUsed)
    print("状态:", tx_receipt.status)
    print("--------------------")

# 主函数
def main():
    accounts = get_or_create_accounts()

    # 初始账户向25个账户每个转100个币
    initial_balance = web3.eth.get_balance(initial_account["address"])
    if initial_balance < web3.to_wei(2500, "ether"):
        print("初始账户余额不足，无法执行初始转账")
        return

    for account in accounts:
        transfer(
            initial_account["address"],
            initial_account["private_key"],
            account["address"],
            web3.to_wei(100, "ether")
        )

    # 无限循环执行25个账户之间的互转
    while True:
        for _ in range(25):
            sender = random.choice(accounts)
            receiver = random.choice([acc for acc in accounts if acc != sender])
            amount = web3.to_wei(random.uniform(0.1, 1), "ether")  # 随机金额0.1-1 ETH

            try:
                transfer(sender["address"], sender["private_key"], receiver["address"], amount)
            except Exception as e:
                print(f"交易错误: {str(e)}")
                print("--------------------")

if __name__ == "__main__":
    main()