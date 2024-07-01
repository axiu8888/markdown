

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


dir=D:/develop/wsl
mkdir -p $dir

name=Ubuntu-24.04
echo "exec ==>: wsl --export $name $dir/$name.tar"
wsl --export $name $dir/$name.tar

echo "exec ==>: wsl --unregister $name"
wsl --unregister $name

echo "exec ==>: wsl --import $name $dir/$name $dir/$name.tar --version 2"
wsl --import $name $dir/$name $dir/$name.tar --version 2

echo "$name end..."
