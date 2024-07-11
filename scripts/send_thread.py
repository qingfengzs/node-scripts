import threading
from web3 import Web3
import time
from queue import Queue

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

class NonceManager:
    def __init__(self, web3, address):
        self.web3 = web3
        self.address = address
        self.nonce = web3.eth.get_transaction_count(address)
        self.lock = threading.Lock()

    def get_nonce(self):
        with self.lock:
            nonce = self.nonce
            self.nonce += 1
            return nonce

nonce_manager = NonceManager(web3, sender_address)

# 定义发送交易的函数
def send_transaction(thread_id):
    try:
        # 获取当前的 nonce
        # nonce = web3.eth.get_transaction_count(sender_address)
        nonce = nonce_manager.get_nonce()
        # 构建交易对象
        transaction = {
            "to": receiver_address,
            "value": amount,
            "gas": 21000,  # 设置默认的 gas 数量
            "gasPrice": web3.to_wei(50, "gwei"),  # 设置默认的 gas 价格
            "nonce": nonce + thread_id,  # 使用不同的 nonce 避免冲突
            "chainId": chain_id,
        }

        # 签名交易
        signed_txn = web3.eth.account.sign_transaction(transaction, sender_private_key)

        # 发送交易
        tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

        # 等待交易确认
        tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

        # 输出交易结果
        print(f"Thread {thread_id} - Transaction Hash: {tx_receipt.transactionHash.hex()}")
        print(f"Thread {thread_id} - Gas Used: {tx_receipt.gasUsed}")
        print(f"Thread {thread_id} - Status: {tx_receipt.status}")
    except Exception as e:
        print(f"Thread {thread_id} - Error: {str(e)}")

# 创建并启动25个线程
threads = []
for i in range(25):
    thread = threading.Thread(target=send_transaction, args=(i,))
    threads.append(thread)
    thread.start()

# 等待所有线程完成
for thread in threads:
    thread.join()

print("All transactions completed.")
