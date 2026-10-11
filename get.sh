#!/bin/bash
# ocean 转发面板 一行安装 / 升级脚本
# 新装：  curl -fsSL <本脚本地址> | bash -s 你的面板域名
# 升级：  curl -fsSL <本脚本地址> | bash
set -e
BASES=(
  "https://github.com/ocean-fw/ocean/releases/latest/download"
)
[ "$(id -u)" = "0" ] || { echo "请用 root 用户执行"; exit 1; }
case "$(uname -m)" in x86_64|amd64) ;; *) echo "面板目前只支持 x86_64（amd64）服务器"; exit 1;; esac
for c in curl tar sha256sum; do command -v $c >/dev/null || { echo "缺少 $c，请先安装：apt install -y $c 或 yum install -y $c"; exit 1; }; done
W=/root/ocean-setup
rm -rf "$W"; mkdir -p "$W"; cd "$W"
ok=0
for b in "${BASES[@]}"; do
  echo "正在下载：$b"
  if curl -fL --connect-timeout 10 -m 600 -o ocean-customer.tar.gz "$b/ocean-customer.tar.gz"; then
    want=$(curl -fsSL --connect-timeout 10 -m 30 "$b/ocean-customer.tar.gz.sha256" 2>/dev/null | tr -d ' \r\n' || true)
    got=$(sha256sum ocean-customer.tar.gz | awk '{print $1}')
    if [ -n "$want" ] && [ "$want" != "$got" ]; then echo "文件校验不一致，换下一个地址重试"; continue; fi
    ok=1; break
  fi
done
[ "$ok" = "1" ] || { echo "下载失败：所有下载地址都连不上。请检查服务器网络，或联系客服 @ocean_fw_help_bot"; exit 1; }
tar xzf ocean-customer.tar.gz
cd ocean
bash install-panel.sh "$@"
cd /root && rm -rf "$W"
