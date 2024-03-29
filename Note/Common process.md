# Common process
## 建立软链接

```bash
# cmd（管理员权限，无需创建文件夹）
mklink /D c:\Users\zhouj\Desktop\targetdirectory(“快捷方式”) d:\sourcedirectory

# linux
ln -s /mnt/c/biosoft/ ~/biosoft(“快捷方式”)
```

## 登录超算

```bash
# 自定义命令，用于登录超算
alias wangq='sshpass -p password ssh username@202.119.37.251'
# URL 202.119.37.251
# username wangq
# password xxxx

# 配置客户端，避免ssh空闲自动断开
sudo vim /ect/ssh/ssh_config
# ssh_config文件中最后添加`ServerAliveInterval 120`
```

## Linux 自动挂载 NAS

```bash
# 安装前置软件 nfs-common 和 cifs-utils 
sudo apt install -y nfs-common cifs-utils

# 创建挂载到的本地文件夹
sudo mkdir /mnt/naszhoujing (&& sudo chmod -R 777 /mnt/naszhoujing)

# 编辑自动挂载文件 /etc/fstab
sudo vim /etc/fstab
//114.212.160.236/backup/ZhouJing /mnt/naszhoujing cifs rw,dir_mode=0777,file_mode=0777,vers=2.0,username=zhoujing,password=****** 0 0

# 执行挂载指令
sudo mount -a
## 若没有报错和提示信息，则表示挂载成功。
```

NOTE：      
* /etc/fstab：File Systems Table，是存储文件系统信息的文件，指定了系统启动时需要挂载的文件系统以及如何挂载它们。每次系统启动时，系统都会自动读取/etc/fstab文件，并尝试按照文件中指定的设置挂载文件系统。
* fstab 文件的每行都代表一个文件系统的挂载选项，由以下部分组成：<文件系统> <挂载点> <文件系统类型> <挂载选项> <备份频率> <是否需要检查>
    * 文件系统：需要挂载的设备或者分区的名称或者UUID。
    * 挂载点：文件系统挂载的目标路径，通常是 /mnt 或者 /media 目录下的子目录。
    * 文件系统类型：文件系统类型，例如ext4、ntfs、vfat等。
    * 挂载选项：挂载选项，例如读写权限、自动挂载、权限等。
    * 备份频率：备份频率，是一个数字，表示文件系统需要备份的优先级。
    * 是否需要检查：指定在开机时是否需要检查文件系统，可以是 0（不检查）、1（检查）或 2（在其他文件系统之后检查）。
* 示例：
    * //your_nas_ip/dir /mnt/NAS/dir cifs rw,dir_mode=0777,file_mode=0777,vers=2.0,username=yourusername,password=yourpassword 0 0
    * your_nas_ip代表你的NAS的访问地址；
    * dir代表NAS下的分享挂载点；
    * /mnt/mountdir代表本设备要挂载到的路径；
    * yourusername为访问的用户名，yourpassword为访问用户的密码，如果设置是匿名访问则不需要username与password两项设置并改为guest。

## Ubuntu 科学上网

* 临时

```shell
# 获取主机IP，在/etc/resolv.conf文件中
export hostip=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\ ).*')

# 设置环境变量，注意修改端口
## http 协议
export https_proxy="http://${hostip}:7890"
export http_proxy="http://${hostip}:7890"
## socket5 协议
export http_proxy="socks5://${hostip}:7890"
export https_proxy="socks5://${hostip}:7890"
## 若端口一致，则可以合并成一句话
export all_proxy="http://${hostip}:7890"
export all_proxy="socks5://${hostip}:7890"

# 查看是否成功启用代理
curl https://ipapi.co/json/
```

* 永久

```shell
vim ~/.bashrc

# 写入环境变量
export hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
# 自定义vpn命令开启代理，unvpn关闭代理
alias vpn='export all_proxy="http://${hostip}:7890"'
alias unvpn='unset all_proxy'

source ~/.bashrc

# 查看是否成功启用代理
curl google.com
```

参考：https://solidspoon.xyz/2021/02/17/%E9%85%8D%E7%BD%AEWSL2%E4%BD%BF%E7%94%A8Windows%E4%BB%A3%E7%90%86%E4%B8%8A%E7%BD%91/

## WSL2增加可用内存和交换分区大小

```bash
# windows资源管理器搜索
%UserProfile%

# 该目录下新建一个文件.wslconfig
.wslconfig

# 写入.wslconfig的内容
[wsl2]
memory=10GB
swap=4GB
localhostForwarding=true

# cmd执行命令
wsl --shutdown
```

参考：https://blog.csdn.net/weixin_45579994/article/details/112386425
