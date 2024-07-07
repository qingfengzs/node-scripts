#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 节点安装功能
function install_node() {

# 更新系统包列表
#sudo apt update
#apt install screen -y

## 检查 Docker 是否已安装
#if ! command -v docker &> /dev/null
#then
#    # 如果 Docker 未安装，则进行安装
#    echo "未检测到 Docker，正在安装..."
#    sudo apt-get install ca-certificates curl gnupg lsb-release
#
#    # 添加 Docker 官方 GPG 密钥
#    sudo mkdir -p /etc/apt/keyrings
#    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#
#    # 设置 Docker 仓库
#    echo \
#      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#
#    # 授权 Docker 文件
#    sudo chmod a+r /etc/apt/keyrings/docker.gpg
#    sudo apt-get update
#
#    # 安装 Docker 最新版本
#    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
#else
#    echo "Docker 已安装。"
#fi

# 检查名为pingpong的screen会话是否存在
if screen -list | grep -q "pingpong"; then
    # 如果存在，则执行退出命令
    screen -X -S pingpong quit
else
    # 如果不存在，则输出提示信息
    echo "pingpong已结束"
fi

#获取运行文件
read -p "请输入你的key device id: " your_device_id

keyid="$your_device_id"

# 下载PINGPONG程序
wget -O PINGPONG https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG

if [ -f "./PINGPONG" ]; then
    chmod +x ./PINGPONG
    screen -dmS pingpong bash -c "./PINGPONG --key \"$keyid\""
else
    echo "下载PINGPONG失败，请检查网络连接或URL是否正确。"
fi

 echo "节点已经启动，请使用screen -r pingpong 查看日志或使用脚本功能2"

}

function check_service_status() {
    screen -r pingpong
}

function reboot_pingpong() {
    read -p "请输入你的key device id: " your_device_id
    keyid="$your_device_id"
    screen -dmS pingpong bash -c "./PINGPONG --key \"$keyid\""
}


# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
    echo "================================================================"
    echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
    echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
    echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"
    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 查看节点日志"
    echo "3. 重启pingpong"
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;
    3) reboot_pingpong ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
