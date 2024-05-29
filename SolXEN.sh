#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

function install_without_wallet() {
    # 更新系统和安装必要的包
    echo "更新系统软件包..."
    sudo apt update && sudo apt upgrade -y
    echo "安装必要的工具和依赖..."
    sudo apt install -y curl build-essential jq git libssl-dev pkg-config screen

    # 安装 Rust 和 Cargo
#    echo "正在安装 Rust 和 Cargo..."
#    curl https://sh.rustup.rs -sSf | sh -s -- -y
#    source $HOME/.cargo/env

    # 安装 Solana CLI
    echo "正在安装 Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"

    # 检查 solana-keygen 是否在 PATH 中
    if ! command -v solana-keygen &> /dev/null; then
        echo "将 Solana CLI 添加到 PATH"
        export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # 创建 Solana 密钥对
    echo "正在创建 Solana 密钥对..."
    solana-keygen new --derivation-path m/44'/501'/0'/0' --force | tee solana-keygen-output.txt

    # 显示提示信息，要求用户确认已备份
    echo "请确保你已经备份了上面显示的助记词和私钥信息。"
    echo "请向pubkey充值sol资产，用于挖矿gas费用。"

    echo "备份完成后，请输入 'yes' 继续："

    read -p "" user_confirmation

    if [[ "$user_confirmation" == "yes" ]]; then
        echo "确认备份。继续执行脚本..."
    else
        echo "脚本终止。请确保备份你的信息后再运行脚本。"
        exit 1
    fi

    # 获取操作系统类型和架构
    OS=$(uname -s)
    ARCH=$(uname -m)

    # 确定下载 URL
    case "$OS" in
      "Darwin")
        if [ "$ARCH" = "x86_64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-darwin-amd64.tar.gz"
        elif [ "$ARCH" = "arm64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-darwin-arm64.tar.gz"
        else
          echo "不支持的架构: $ARCH"
          exit 1
        fi
        ;;
      "Linux")
        if [ "$ARCH" = "x86_64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-linux-amd64.tar.gz"
        elif [ "$ARCH" = "aarch64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-linux-arm64.tar.gz"
        else
          echo "不支持的架构: $ARCH"
          exit 1
        fi
        ;;
      *)
        echo "无法支持的系统: $OS"
        exit 1
        ;;
    esac

    # 创建临时目录并下载文件
    TMP_DIR=$(mktemp -d)
    cd $TMP_DIR
    echo "下载对应文件 $URL..."
    curl -L -o solxen-tx.tar.gz $URL

    # 创建用户主目录的 solxen 文件夹
    SOLXEN_DIR="$HOME/solxen"
    mkdir -p $SOLXEN_DIR

    # 解压缩文件
    echo "解压文件中 solxen-tx.tar.gz..."
    tar -xzvf solxen-tx.tar.gz -C $SOLXEN_DIR

    # 检查文件是否存在
    SOLXEN_FILE="$SOLXEN_DIR/solxen-tx.yaml"
    if [ ! -f $SOLXEN_FILE ]; then
      echo "Error: $SOLXEN_FILE 不存在。"
      exit 1
    fi

    read -p "请输入SOL钱包助记词: " mnemonic
    read -p "请输入同时运行的钱包数量，建议输入4: " num
    read -p "请输入优先级费用: " fee
    read -p "请输入间隔时间(毫秒): " time
    read -p "请输入空投接收地址，需要ETH钱包地址: " evm
    read -p "请输入sol rpc地址: " url

    # 更新 solxen-tx.yaml 文件
    sed -i "s|Mnemonic:.*|Mnemonic: \"$mnemonic\"|" $SOLXEN_FILE
    sed -i "s|Num:.*|Num: $num|" $SOLXEN_FILE
    sed -i "s|Fee:.*|Fee: $fee|" $SOLXEN_FILE
    sed -i "s|Time:.*|Time: $time|" $SOLXEN_FILE
    sed -i "s|ToAddr:.*|ToAddr: $evm|" $SOLXEN_FILE
    sed -i "s|Url:.*|Url: $url|" $SOLXEN_FILE

    # 清理临时目录
    cd ~
    rm -rf $TMP_DIR

    # 启动 screen 会话并运行命令
    screen -dmS solxen bash -c 'while true; do cd $HOME/solxen && ./solxen-tx miner; sleep 5; done'

    echo "solxen-tx 安装和配置成功，请使用功能3查看运行情况"

    echo '====================== 安装完成，节点已经后台启动，请使用脚本功能2/输入screen -r SOLXEN 查看运行情况==========================='
}

function install_node() {
    # 获取操作系统类型和架构
    OS=$(uname -s)
    ARCH=$(uname -m)

    # 确定下载 URL
    case "$OS" in
      "Darwin")
        if [ "$ARCH" = "x86_64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-darwin-amd64.tar.gz"
        elif [ "$ARCH" = "arm64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-darwin-arm64.tar.gz"
        else
          echo "不支持的架构: $ARCH"
          exit 1
        fi
        ;;
      "Linux")
        if [ "$ARCH" = "x86_64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-linux-amd64.tar.gz"
        elif [ "$ARCH" = "aarch64" ]; then
          URL="https://github.com/mmc-98/solxen-tx/releases/download/mainnet-beta2/solxen-tx-mainnet-beta2-linux-arm64.tar.gz"
        else
          echo "不支持的架构: $ARCH"
          exit 1
        fi
        ;;
      *)
        echo "无法支持的系统: $OS"
        exit 1
        ;;
    esac

    # 创建临时目录并下载文件
    TMP_DIR=$(mktemp -d)
    cd $TMP_DIR
    echo "下载对应文件 $URL..."
    curl -L -o solxen-tx.tar.gz $URL

    # 创建用户主目录的 solxen 文件夹
    SOLXEN_DIR="$HOME/solxen"
    mkdir -p $SOLXEN_DIR

    # 解压缩文件
    echo "解压文件中 solxen-tx.tar.gz..."
    tar -xzvf solxen-tx.tar.gz -C $SOLXEN_DIR

    # 检查文件是否存在
    SOLXEN_FILE="$SOLXEN_DIR/solxen-tx.yaml"
    if [ ! -f $SOLXEN_FILE ]; then
      echo "Error: $SOLXEN_FILE 不存在。"
      exit 1
    fi

    read -p "请输入SOL钱包助记词: " mnemonic
    read -p "请输入同时运行的钱包数量，建议输入4: " num
    read -p "请输入优先级费用: " fee
    read -p "请输入间隔时间(毫秒): " time
    read -p "请输入空投接收地址，需要ETH钱包地址: " evm
    read -p "请输入sol rpc地址: " url

    # 更新 solxen-tx.yaml 文件
    sed -i "s|Mnemonic:.*|Mnemonic: \"$mnemonic\"|" $SOLXEN_FILE
    sed -i "s|Num:.*|Num: $num|" $SOLXEN_FILE
    sed -i "s|Fee:.*|Fee: $fee|" $SOLXEN_FILE
    sed -i "s|Time:.*|Time: $time|" $SOLXEN_FILE
    sed -i "s|ToAddr:.*|ToAddr: $evm|" $SOLXEN_FILE
    sed -i "s|Url:.*|Url: $url|" $SOLXEN_FILE

    # 清理临时目录
    cd ~
    rm -rf $TMP_DIR

    # 启动 screen 会话并运行命令
    screen -dmS solxen bash -c 'while true; do cd $HOME/solxen && ./solxen-tx miner; sleep 5; done'


    echo "solxen-tx 安装和配置成功，请使用功能3查看运行情况"
}

# 查看进度
function check_XEN() {
    screen -r solxen
}

function check_wallet() {
    cd solxen
    ./solxen-tx balance
}

function running() {
    cd ~
    screen -dmS solxen bash -c 'while true; do cd solxen && ./solxen-tx miner; sleep 5; done'
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
        echo "=========================基于github用户:mmc-98修改======================================="
        echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 全新安装节点，适合没有solana钱包用户"
        echo "2. 常规安装节点，适合已有solana钱包用户"
        echo "3. 查看运行情况"
        echo "4. 查看钱包地址信息"
        echo "5. 适用于修改某些配置后，重新启动挖矿"
        read -p "请输入选项（1-5）: " OPTION

        case $OPTION in
        1) install_without_wallet ;;
        2) install_node ;;
        3) check_XEN ;;
        4) check_wallet ;;
        5) running ;;
        *) echo "无效选项。" ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu