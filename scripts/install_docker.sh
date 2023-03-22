#!/bin/bash

# 安装docker
install_docker() {
  if [ -x "$(command -v docker)" ]; then
    echo -e "${GREEN}Docker 已经安装。${NC}"
  else
    echo -e "${YELLOW}开始安装docker....${NC}"
#    sudo apt update
    sudo apt install -y docker.io
    echo -e "${GREEN}Docker 已经安装。${NC}"
  fi
}

install_docker
