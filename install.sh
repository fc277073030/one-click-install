#!/bin/bash
# Author: fanchao
# 一键安装脚本

set -euo pipefail  # 严格模式，以确保执行期间的任何错误都会导致脚本立即退出。

export DEBIAN_FRONTEND=noninteractive

# 设置颜色常量
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly PURPLE='\033[0;35m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # 重置颜色

# 打印欢迎信息
#clear
#echo -e "${BLUE}=========================================="
#echo -e "||    ${YELLOW}欢迎使用一键安装脚本！${BLUE}    ||"
#echo -e "==========================================${NC}"
#echo -e "${CYAN}这个脚本将自动安装软件包。${NC}"
#echo -e "${CYAN}请确保您已经具有必要的权限。${NC}"
#
## 平滑过渡
#for i in {1..50}; do
#  echo -ne "${GREEN}.${NC}"
#  sleep 0.02
#done
#echo -e "\n"

# 首先检查系统是否为 Ubuntu 系统
if [ $(lsb_release -si) != "Ubuntu" ]; then
  echo "Error: This script requires Ubuntu operating system."
  exit 1
fi


# 主菜单选项
main_menu() {
  clear
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${YELLOW}         一键安装脚本         ${NC}"
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${GREEN} 1.${NC} 一键安装"
  echo -e "${GREEN} 2.${NC} 运维工具"
  echo -e "${GREEN} 3.${NC} 退出"
  read -rp "请输入选项: " choice
  case $choice in
    1)
      install_menu
      ;;
    2)
      maintenance_menu
      ;;
    3)
      exit 0
      ;;
    *)
      echo -e "${RED}无效选项，请重试${NC}"
      sleep 1
      main_menu
      ;;
  esac
}

# 一键安装子菜单
install_menu() {
  clear
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${YELLOW}         一键安装菜单         ${NC}"
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${GREEN} 1.${NC} 私有化"
  echo -e "${GREEN} 2.${NC} 混合云"
  echo -e "${GREEN} 3.${NC} 返回上一级菜单"
  read -rp "请输入选项: " choice
  case $choice in
    1)
      # TODO: privo
      private_install
      ;;
    2)
      # TODO: 混合云安装
      hybrid_cloud
      ;;
    3)
      main_menu
      ;;
    *)
      echo -e "${RED}无效选项，请重试${NC}"
      sleep 1
      install_menu
      ;;
  esac
}

# 运维工具子菜单
maintenance_menu() {
  clear
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${YELLOW}         运维工具菜单         ${NC}"
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${GREEN} 1.${NC} 修复redis aof文件"
  echo -e "${GREEN} 2.${NC} 挂载磁盘"
  echo -e "${GREEN} 3.${NC} 返回上一级菜单"
  read -rp "请输入选项: " choice
  case $choice in
    1)
      echo -e "${GREEN}正在修复redis aof文件...${NC}"
      sleep 1
      check_success
      ;;
    2)
      echo -e "${GREEN}挂载成功...${NC}"
      sleep 1
      check_success
      ;;
    3)
      main_menu
      ;;
    *)
      echo -e "${RED}无效选项，请重试${NC}"
      sleep 1
      maintenance_menu
  esac
}

############### 以下是安装软件的函数 ##########################

# 安装docker
function install_docker() {
  # 检查是否已经安装了 Docker，如果已经安装，输出消息并退出
  if command -v docker &>/dev/null; then
    echo -e "${GREEN}Docker 已经安装在此系统上${NC}"
#    exit 0
  fi

  # 检查系统是否为 Ubuntu
  if [ -f /etc/lsb-release ] && grep -q "Ubuntu" /etc/lsb-release; then
    # 更新包列表
    sudo apt-get update

    # 安装 Docker
    sudo apt-get install docker.io -y

    # 启用 Docker 服务
    sudo systemctl enable --now docker
  else
    # 如果系统不是 Ubuntu，则输出错误消息并退出
    echo "不支持的系统。Docker 安装失败。"
    exit 1
  fi

#  exit 0
}

# 安装docker-compose
install_docker_compose() {
  install_docker_compose() {
  if [ ! -f "/usr/local/bin/docker-compose" ]; then
    if [ -f "./bin/docker-compose" ]; then
      echo "docker-compose is found in the local ./bin directory. Installing..."
      sudo cp ./bin/docker-compose /usr/local/bin/
      sudo chmod +x /usr/local/bin/docker-compose
      echo "docker-compose installed successfully."
    else
      echo "docker-compose is not found in the local directory. Downloading..."
      sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose
      sudo cp docker-compose /usr/local/bin/
      sudo chmod +x /usr/local/bin/docker-compose
      echo "docker-compose installed successfully."
    fi
  else
    echo "docker-compose is already installed."
  fi
}
}



# 获取ip
function get_host_ip {
  # 提示用户手动输入IP地址，默认为本宿主机IP
#  echo -e "${GREEN}请输入要安装的目标IP地址（默认为本宿主机IP地址 $(hostname -I | awk '{print $1}')）：${NC}"
#  read target_ip
#  if [ -z "$target_ip" ]; then
#  target_ip=$(hostname -I | awk '{print $1}')
#  fi
#  echo -e "${YELLOW}您输入的目标IP地址为 ${target_ip}${NC}"
#
#  # 将目标IP地址保存为环境变量
#  export TARGET_IP=$target_ip

  read -p "请输入IP地址（默认为宿主机IP地址: $(hostname -I | awk '{print $1}')）：" ip_address
    if [ -z "$ip_address" ]; then
        ip_address=$(hostname -I | awk '{print $1}')
    fi

    echo -e "${GREEN}您选择的IP地址为：$ip_address${NC}"

    # 验证IP地址格式是否有效
    if [[ ! $ip_address =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo -e "${RED}无效的IP地址格式，请重新运行脚本并输入有效的IP地址。${NC}"
        exit 1
    fi

    # 将目标IP地址保存为环境变量
    export TARGET_IP=$ip_address
}

# 检查安装是否成功
check_success() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}安装成功！${NC}"
    exit 0
  else
    echo -e "${RED}安装失败，请重试！${NC}"
    sleep 1
    install_menu
  fi
}

# 私有化安装
function private_install() {
  echo -e "${GREEN}正在进行私有化安装...${NC}"
#  get_host_ip
  install_docker
  install_docker_compose
}

# 混合云安装
function hybrid_cloud() {
  # TODO: 混合云安装
  echo -e "${YELLOW}此功能待开发${NC}"
}

main_menu

