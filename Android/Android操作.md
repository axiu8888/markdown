# Android 操作




## adb 操作

参考: [https://www.cnblogs.com/lc-blogs/p/17006300.html](https://www.cnblogs.com/lc-blogs/p/17006300.html)

- 启动adb服务：adb start-server
- 杀死服务：adb kill-server

> 指定 adb server 的网络端口
> adb -P <port> start-server
> ADB的默认端口为 5037。

- 获取root权限：adb root

- 查看设备：adb devices
- 连接设备：adb connect IP:端口
- 获取安装的应用：adb shell pm list packages >> app-info.txt
- 拉取应用：adb pull apk位置 ./
- 强制卸载系统应用：adb shell pm uninstall --user -0 app包名



~