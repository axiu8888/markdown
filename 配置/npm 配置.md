# npm 配置

## .npmrc 配置

```
registry=http://192.168.1.200:9001/repository/npmgroup/
electron_mirror=https://npmmirror.com/mirrors/electron/
disturl=https://npmmirror.com/mirrors/node/
node_mirror=https://npmmirror.com/mirrors/node/
```

## 代理

```
# 淘宝代理
npm config set registry https://registry.npmmirror.com/

# 默认的npm代理
npm config set registry https://registry.npmjs.org/

# 查看当前的地址
npm config get registry

# electron 代理
electron_mirror=https://npmmirror.com/mirrors/electron/

```

## npm上传到nexus3   `^_^`

```
# 登录
npm login --registry=http://127.0.0.1:9001/repository/npmhosted/
# 打包
npm pack
# 上传
npm publish --registry http://127.0.0.1:9001/repository/npmhosted/


# 代理
npm config set registry http://127.0.0.1:9001/repository/npmgroup/
# 添加账号
npm adduser
admin
admin123
dingxiuan@163


# 仓库注册
npm login --registry=http://127.0.0.1:9001/repository/npmhosted
admin
admin123
dingxiuan@163.com
# 上传
npm pack
npm publish --registry=http://127.0.0.1:9001/repository/npmhosted/
```

## 其他操作

> 清理项目缓存: pnpm store prune
> 清理全局缓存: pnpm cache clean --force
> 安装时查看详情: pnpm install --reporter ndjson
> 安装时忽略锁文件: pnpm install --no-prefer-frozen-lockfile
> 重新安装pnpm: npm uninstall -g pnpm && npm install -g pnpm

~

## nvm 配置

### 下载和安装

```
cd ~/
git clone https://github.com/nvm-sh/nvm.git .nvm
```

添加配置
vim ~/.profile  或者  vim ~/.bashrc

```
export NVM_DIR="/opt/env/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

source ~/.profile
source ~/.bashrc

### 常用命令

1. 查看远程可用的版本：`nvm ls-remote`
2. 安装：`nvm install v23.5.0`
3. 指定版本：`nvm use v23.5.0`

~
