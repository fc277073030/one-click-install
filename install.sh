#!/bin/bash
# Author: FANCHAO
# 一键安装脚本

set -euo pipefail  # 严格模式，以确保执行期间的任何错误都会导致脚本立即退出。

#export DEBIAN_FRONTEND=noninteractive

# 设置颜色常量
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly PURPLE='\033[0;35m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # 重置颜色

# 打印欢迎信息
clear
echo -e "${BLUE}=========================================="
echo -e "||    ${YELLOW}欢迎使用一键安装脚本！${BLUE}    ||"
echo -e "==========================================${NC}"
echo -e "${CYAN}这个脚本将自动安装软件包。${NC}"
echo -e "${CYAN}请确保您已经具有必要的权限。${NC}"

# 平滑过渡
for i in {1..40}; do
  echo -ne "${GREEN}.${NC}"
  sleep 0.02
done
#echo -e "\n"

# 首先检查系统是否为 Ubuntu 系统
if [ $(lsb_release -si) != "Ubuntu" ]; then
  echo " ${RED}错误: 这个脚本只支持 Ubuntu 系统！{NC}"
  exit 1
fi


# 主菜单选项
function main_menu() {
  clear
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${YELLOW}         主菜单         ${NC}"
  echo -e "${YELLOW}==============================${NC}"
  echo -e "${GREEN} 1.${NC} 一键安装"
  echo -e "${GREEN} 2.${NC} 运维工具"
  echo -e "${GREEN} 3.${NC} 退出"
  read -rp "请输入选项: " choice
  case $choice in
    1)
      # 一键安装子菜单
      one_click_install_menu
      ;;
    2)
      # 运维工具子菜单
      ops_menu
      ;;
    3)
      # 退出
      exit 0
      ;;
    *)
      echo -e "${RED}无效选项，请重试${NC}"
      sleep 1
      main_menu  # 退回主菜单
      ;;
  esac
}

# 一键安装子菜单
function one_click_install_menu() {
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
      # TODO: 私有云安装
      private_install  # 调用私有化安装函数
      ;;
    2)
      # TODO: 混合云安装
      hybrid_install
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
function ops_menu() {
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
      ops_menu
  esac
}

# 安装 docker
function install_docker() {
  # 检查是否已经安装 docker
  if [ -x "$(command -v docker)" ]; then
    echo -e "${GREEN}Docker 已经安装。${NC}"
  else
    echo -e "${YELLOW}开始安装docker....${NC}"
#    sudo apt update
    sudo apt install -y docker.io
    echo -e "${GREEN}Docker 已经安装。${NC}"
  fi
}

# 安装docker-compose
function install_docker_compose() {
    # 检查是否已经安装docker-compose
    if command -v docker-compose >/dev/null 2>&1; then
        echo -e "${GREEN}docker-compose 已经安装，无需再次安装"
        return
    fi

    # 检查本地是否有docker-compose二进制文件
    if [ -f ./bin/docker-compose ]; then
        sudo cp ./bin/docker-compose /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo -e "${GREEN}docker-compose 已经本地安装{NC}"
        return
    fi

    # 下载并安装docker-compose
    echo "Installing docker-compose from the Internet"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # 检查是否成功安装docker-compose
    if command -v docker-compose >/dev/null 2>&1 ; then
      echo -e "${GREEN}docker-compose安装成功！${NC}"
    else
      echo -e "${RED}docker-compose 安装失败，请重新安装。{NC}"
    fi
}



# 安装NVIDIA驱动函数
function install_nvidia_driver() {
  # 检查当前是否已安装NVIDIA驱动
  if ! lsmod | grep nvidia &> /dev/null; then
    # 没有安装NVIDIA驱动，开始安装最新版本的驱动程序
    echo "正在安装最新版本的NVIDIA驱动..."
    sudo apt update
    sudo apt install -y nvidia-driver-510
    # 安装完成后重新加载NVIDIA驱动模块
    sudo modprobe -r nvidia-drm
    sudo modprobe nvidia-drm
    echo "安装完成！"
  else
    # 已经安装了NVIDIA驱动，输出信息并退出
    echo -e "${GREEN}nvidia-driver 已经安装。无需再次安装。${NC}"
  fi
}

# 安装 Nvidia-Container-Toolkit
function install_nvidia_container_toolkit() {
    if ! dpkg -s nvidia-container-toolkit >/dev/null 2>&1; then
        # 安装必要的依赖项
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

        # 添加 NVIDIA apt-key
        curl -sL https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -

        # 添加 NVIDIA apt 仓库
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
        curl -sL https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

        # 更新 apt 软件包缓存
        sudo apt-get update

        # 安装 NVIDIA Container Toolkit
        sudo apt-get install -y nvidia-container-toolkit

        # 重启 Docker 服务
        sudo systemctl restart docker

        echo -e "${GREEN}NVIDIA Container Toolkit 安装完成.{NC}"
    else
        echo -e "${GREEN}NVIDIA Container Toolkit 已经安装.无需再次安装${NC}"
    fi
}





# 获取主机 ip，并设置为环境变量
function get_host_ip {
  # 提示用户手动输入IP地址，默认为本宿主机IP
  read -p "请输入IP地址（默认为宿主机IP地址: $(hostname -I | awk '{print $1}')）：" ip_address
    if [ -z "$ip_address" ]; then
        ip_address=$(hostname -I | awk '{print $1}')
    fi

    echo -e "您选择的IP地址为：${GREEN}$ip_address${NC}"

    # 验证IP地址格式是否有效
    if [[ ! $ip_address =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo -e "${RED}无效的IP地址格式，请重新运行脚本并输入有效的IP地址。${NC}"
        exit 1
    fi

    # 将目标IP地址保存为环境变量
    export HOST_IP=$ip_address

    # 检查 .env 文件是否存在
    if [ -f ".env" ]; then
      # 检查 .env 文件是否包含 HOST_IP 的值
      if grep -q "HOST_IP" .env; then
        # 如果 .env 文件包含 HOST_IP 的值，则更新它
        sed -i "s/HOST_IP=.*/HOST_IP=$ip_address/" .env
        echo -e "HOST_IP 的值已更新为 ${GREEN}$ip_address。${NC}"
      else
        # 如果 .env 文件不包含 HOST_IP 的值，则将其添加到文件末尾
        echo "HOST_IP=$ip_address" >> .env
        echo "HOST_IP 的值已设置为 $ip_address。"
      fi
    else
      # 如果 .env 文件不存在，则创建它并写入 HOST_IP 的值
      echo "HOST_IP=$ip_address" > .env
      echo "已创建 .env 文件并设置 HOST_IP 的值为 $ip_address。"
    fi

}

# 检查安装是否成功
function check_success() {
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
  get_host_ip
  echo -e "${YELLOW}开始进行私有化安装...${NC}"
  install_docker
  install_docker_compose
  install_nvidia_driver
  install_nvidia_container_toolkit
}

# 混合云安装
function hybrid_install() {
  # TODO: 混合云安装
  echo -e "${YELLOW}此功能待开发${NC}"
}

# 执行主菜单函数
main_menu

