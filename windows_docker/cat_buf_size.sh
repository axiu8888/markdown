
echo -e "\n"
echo "查看网络内存的接收缓冲区大小 ==>: cat /proc/sys/net/core/rmem_max"
cat /proc/sys/net/core/rmem_max
echo "查看网络内存的发送缓冲区大小 ==>: cat /proc/sys/net/core/wmem_max"
cat /proc/sys/net/core/wmem_max


echo -e "\n"
MB=1048576
echo "2MB ==>: $(((2 * MB)))"
echo "4MB ==>: $(((4 * MB)))"
echo "6MB ==>: $(((6 * MB)))"
echo "8MB ==>: $(((8 * MB)))"
echo "12MB ==>: $(((12 * MB)))"
echo "16MB ==>: $(((16 * MB)))"
echo "32MB ==>: $(((32 * MB)))"


echo -e "\n"
# echo "修改接收缓冲区大小 echo \"8388608\" > /proc/sys/net/core/rmem_max"
echo "修改接收缓冲区大小 sudo sysctl -w net.core.rmem_max=8388608"
# echo "修改发送缓冲区大小 echo \"8388608\" > /proc/sys/net/core/wmem_max"
echo "修改发送缓冲区大小 sudo sysctl -w net.core.wmem_max=8388608"
# sudo sysctl -w net.core.rmem_max=16777216
# sudo sysctl -w net.core.wmem_max=8388608