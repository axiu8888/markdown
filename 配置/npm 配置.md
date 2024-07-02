# npm 配置

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
npm login -–registry=http://127.0.0.1:9001/repository/npmhosted
admin
admin123
dingxiuan@163.com
# 上传
npm pack
npm publish -–registry=http://127.0.0.1:9001/repository/npmhosted/
```

## 其他操作

> 清理项目缓存: pnpm store prune
> 清理全局缓存: pnpm cache clean --force
> 安装时查看详情: pnpm install --reporter ndjson
> 安装时忽略锁文件: pnpm install --no-prefer-frozen-lockfile
> 重新安装pnpm: npm uninstall -g pnpm && npm install -g pnpm

~
