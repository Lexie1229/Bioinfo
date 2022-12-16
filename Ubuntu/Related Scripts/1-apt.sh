#!/usr/bin/env bash

> * #!/usr/bin/env bash 声明命令解释器，指明使用什么shell（命令解释器）程序来解释脚本
> * #符号在shell脚本语言中单独使用代表注释标识符，会被脚本解释器自动忽略
> * #!字符序列（Shebang或Hashbang），出现在文本文件的第一行的前两个字符
> * 文件中存在Shebang的情况下，会分析Shebang后的内容，作为解释器指令并调用

1
echo "====> Install softwares via apt-get <===="

输出====> Install softwares via apt-get <====

2
echo "==> Disabling the release upgrader"
sudo sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades

输出==> Disabling the release upgrader
将/etc/update-manager/release-upgrades文件中所有的Prompt=替换为Prompt=never，并创建源文件备份文件.bak
.bak 备份文件
's/旧字符串/新字符串/' 字符串替换
正则表达式：
^ 匹配输入字符串的开始位置
* 匹配前面的子表达式零次或多次
$ 匹配输入字符串的结尾位置
. 匹配除换行符 \n 之外的任何单字符

3 
echo "==> Switch to an adjacent mirror"

输出==> Switch to an adjacent mirror

4
# https://lug.ustc.edu.cn/wiki/mirrors/help/ubuntu
cat <<EOF > list.tmp

deb https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-security main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-updates main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-backports main restricted universe multiverse

## Not recommended
# deb https://mirrors.ustc.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse

EOF

> * cat <<EOF > 文件名
EOF 表示结束
> * 文件/etc/apt/sources.list是一个普通可编辑的文本文件，保存了ubuntu软件更新的源服务器的地址
> * deb:Debian软件包格式,文件扩展名为.deb。
> * deb开头表示直接通过.deb二进制文件进行安装。
> * deb-src开头表示分别表示通过源文件进行安装。


if [ ! -e /etc/apt/sources.list.bak ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi
sudo mv list.tmp /etc/apt/sources.list

# Virtual machines needn't this and I want life easier.
# https://help.ubuntu.com/lts/serverguide/apparmor.html
if [ "$(whoami)" == 'vagrant' ]; then
    echo "==> Disable AppArmor"
    sudo service apparmor stop
    sudo update-rc.d -f apparmor remove
fi

echo "==> Disable whoopsie"
sudo sed -i 's/report_crashes=true/report_crashes=false/' /etc/default/whoopsie
sudo service whoopsie stop

echo "==> Install linuxbrew dependences"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential curl file git
sudo apt-get -y install pkg-config libbz2-dev zlib1g-dev libzstd-dev libexpat1-dev
# sudo apt-get -y install libcurl4-openssl-dev libncurses-dev

> * -y

echo "==> Install other software"
sudo apt-get -y install aptitude parallel vim screen xsltproc numactl

> * parallel
> develop libraries
> libdb-dev libxml2-dev libssl-dev libncurses5-dev libgd-dev
> alignDB
> gtk3

echo "==> Install develop libraries"
# sudo apt-get -y install libreadline-dev libedit-dev
sudo apt-get -y install libdb-dev libxml2-dev libssl-dev libncurses5-dev libgd-dev
# sudo apt-get -y install gdal-bin gdal-data libgdal-dev # /usr/lib/libgdal.so: undefined reference to `TIFFReadDirectory@LIBTIFF_4.0'
# sudo apt-get -y install libgsl0ldbl libgsl0-dev

# Gtk stuff, Need by alignDB
# install them in a fresh machine to avoid problems
echo "==> Install gtk3"
#sudo apt-get -y install libcairo2-dev libglib2.0-0 libglib2.0-dev libgtk-3-dev libgirepository1.0-dev
#sudo apt-get -y install gir1.2-glib-2.0 gir1.2-gtk-3.0 gir1.2-webkit-3.0

echo "==> Install gtk3 related tools"
# sudo apt-get -y install xvfb glade

echo "==> Install graphics tools"
sudo apt-get -y install gnuplot graphviz imagemagick

#echo "==> Install nautilus plugins"
#sudo apt-get -y install nautilus-open-terminal nautilus-actions

# Mysql will be installed separately.
# Remove system provided mysql package to avoid confusing linuxbrew.
echo "==> Remove system provided mysql"
# sudo apt-get -y purge mysql-common

echo "==> Restore original sources.list"
if [ -e /etc/apt/sources.list.bak ]; then
    sudo rm /etc/apt/sources.list
    sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list
fi

echo "====> Basic software installation complete! <===="
