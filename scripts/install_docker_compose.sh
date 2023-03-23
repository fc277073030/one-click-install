# 安装docker-compose
install_docker_compose() {
    # 检查是否已经安装docker-compose
    if command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose is already installed"
        return
    fi

    # 检查本地是否有docker-compose二进制文件
    if [ -f ./bin/docker-compose ]; then
        echo "Installing docker-compose from local binary"
        sudo cp ./bin/docker-compose /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        return
    fi

    # 下载并安装docker-compose
    echo "Installing docker-compose from the Internet"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# 调用函数来安装docker-compose
install_docker_compose
