#!/bin/bash

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
    echo "您已经安装了NVIDIA驱动。无需再次安装。"
  fi
}

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

        echo "NVIDIA Container Toolkit has been installed."
    else
        echo "NVIDIA Container Toolkit is already installed."
    fi
}


# 调用函数进行安装
install_nvidia_driver
install_nvidia_container_toolkit
