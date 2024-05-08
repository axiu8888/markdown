# npm 配置


## 代理

```
# 淘宝代理
npm config set registry https://registry.npmmirror.com

# 默认的npm代理
npm config set registry https://registry.npmjs.org

# 查看当前的地址
npm config get registry

# electron 代理
electron_mirror=https://npmmirror.com/mirrors/electron

```


## npm上传到nexus3

```
# 登录
npm login --registry=http://192.168.1.200:9001/repository/npmhosted/

# 打包
npm pack

# 上传
npm publish --registry http://192.168.1.200:9001/repository/npmhosted/

```

~
