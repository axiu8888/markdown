

# 更新 https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
# wget https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

# 设置wsl的默认版本
wsl --set-default-version 2

# 查看子系统的版本
wsl --list -v
# 查看在线可选的子系统
# wsl --list -o
# 安装子系统
# wsl --install -d Ubuntu-24.04


destDir=D:/develop/wsl
tmpDir=D:/develop/wsl/tmp

mkdir -p $destDir && mkdir -p $tmpDir

name=Ubuntu-24.04
wsl --export $name $tmpDir/$name.tar
wsl --unregister $name
wsl --import $name $destDir/$name $tmpDir/$name.tar --version 2
echo "$name end"
