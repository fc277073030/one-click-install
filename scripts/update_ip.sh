#!/bin/bash

# 用户输入IP地址
read -p "请输入IP地址：" ip

# 设置环境变量
export HOST_IP="$ip"

# 检查 .env 文件是否存在
if [ -f ".env" ]; then
  # 检查 .env 文件是否包含 HOST_IP 的值
  if grep -q "HOST_IP" .env; then
    # 如果 .env 文件包含 HOST_IP 的值，则更新它
    sed -i "s/HOST_IP=.*/HOST_IP=$ip/" .env
    echo "HOST_IP 的值已更新为 $ip。"
  else
    # 如果 .env 文件不包含 HOST_IP 的值，则将其添加到文件末尾
    echo "HOST_IP=$ip" >> .env
    echo "HOST_IP 的值已设置为 $ip。"
  fi
else
  # 如果 .env 文件不存在，则创建它并写入 HOST_IP 的值
  echo "HOST_IP=$ip" > .env
  echo "已创建 .env 文件并设置 HOST_IP 的值为 $ip。"
fi
