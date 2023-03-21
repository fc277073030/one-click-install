#!/bin/bash

# 定义颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 定义主菜单选项
OPTIONS=("一键安装" "运维工具" "退出")

# 定义运维子菜单选项
TOOLS=("修复 Docker 容器 Redis 的 AOF 文件" "返回上级菜单")

# 定义函数来安装 docker-compose 示例
function install_docker_compose() {
    read -p "请输入IP地址（默认为宿主机IP地址）：" ip_address
    if [ -z "$ip_address" ]; then
        ip_address=$(hostname -I | awk '{print $1}')
    fi

    echo -e "${YELLOW}您选择的IP地址为：$ip_address${NC}"

    # 验证IP地址格式是否有效
    if [[ ! $ip_address =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo -e "${RED}无效的IP地址格式，请重新运行脚本并输入有效的IP地址。${NC}"
        exit 1
    fi

    # 安装docker和docker-compose
    # ...

    echo -e "${GREEN}docker-compose 示例安装完成。${NC}"
    exit 0
}

# 定义函数来挂载磁盘
function mount_disk() {
	  # TODO
    echo "挂载磁盘"
}

# 定义函数来修复 Redis AOF 文件
function fix_redis_aof() {
    # TODO
    echo "修复redis aof 文件"
}

# 定义函数来显示主菜单
function show_main_menu() {
    echo -e "${YELLOW}请选择以下选项：${NC}"
    for i in "${!OPTIONS[@]}"; do
        echo -e "${YELLOW}$((i+1)). ${OPTIONS[$i]}${NC}"
    done
}

# 根据用户选择的选项执行相应的操作
while true; do
    show_main_menu
    read -p "请输入选项序号：" opt
    case $opt in
        1)
            install_docker_compose
            break
            ;;
        2)
            while true; do
                echo -e "${YELLOW}请选择以下选项：${NC}"
                for i in "${!TOOLS[@]}"; do
                    echo -e "${YELLOW}$((i+1)). ${TOOLS[$i]}${NC}"
                done
                read -p "请输入选项序号：" tool_opt
                case $tool_opt in
                    1)
                        fix_redis_aof
                        break
                        ;;
                    2)
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选项，请重新输入。${NC}"
                        ;;
                esac
            done
            ;;
        3)
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选项，请重新输入。${NC}"
            ;;
    esac
done
