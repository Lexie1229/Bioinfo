# Setting-up scripts for Ubuntu 20.04

[TOC levels=1-3]: # ""

- [Setting-up scripts for Ubuntu 20.04](#setting-up-scripts-for-ubuntu-2004)
    - [Bypass GFW blocking](#bypass-gfw-blocking)
    - [Install packages needed by Linuxbrew and some others](#install-packages-needed-by-linuxbrew-and-some-others)
    - [Optional: adjusting Desktop](#optional-adjusting-desktop)
    - [Install Linuxbrew](#install-linuxbrew)
    - [Download](#download)
    - [Install packages managed by Linuxbrew](#install-packages-managed-by-linuxbrew)
    - [Packages of each language](#packages-of-each-language)
    - [Bioinformatics Apps](#bioinformatics-apps)
    - [MySQL](#mysql)
    - [Optional: dotfiles](#optional-dotfiles)
    - [Directory Organization](#directory-organization)

The whole developing environment is based on [Linuxbrew](http:s//linuxbrew.sh/). Many of the
following steps also work under macOS via [Homebrew](https://brew.sh/).

Linux specific scripts were placed in [`prepare/`](prepare).
[This repo](https://github.com/wang-q/dotfiles) contains macOS related codes.

## 1.Bypass GFW blocking

* Query the IP address on [ipaddress](https://www.ipaddress.com/) for

    * `raw.githubusercontent.com`
    * `gist.githubusercontent.com` 
    * `camo.githubusercontent.com`
    * `user-images.githubusercontent.com`

* Add them to `/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts`


#GFW(Great Firewall)-防火墙
hosts文件是linux系统中负责ip地址与域名快速解析的文件
**raw.githubusercontent.com**github用来存储用户上传文件（不是项目仓库的文件，而是issue里的图片之类的）的服务地址
Domain（域）：githubusercontent.com
Domain Label：githubusercontent

1
vi 文件名 ：进入一般模式
sudo vim 文件名 （sudo是系统管理指令，允许系统管理员让普通用户执行一些或者全部的root命令的一个工具）
I切换编辑模式 ； esc退出编辑模式
：wq（保存/退出）
：wq！（强制保存退出）
ip地址 主机名/域名 （主机别名）


2
打开C:\Windows\System32\drivers\etc\hosts文件，
输入 ip地址 主机名/域名 
cmd/Powershell中输入 ping 域名





## 2.Install packages needed by Linuxbrew and some others
```shell script
echo "==> When some packages went wrong, check http://mirrors.ustc.edu.cn/ubuntu/ for updating status."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/1-apt.sh)"

1
curl： 
-f, --fail          Fail silently (no output at all) on HTTP errors
-L, --location      Follow redirects
-S, --show-error    Show error even when -s is used
-s, --silent        Silent mode
bash：
-c 

3.Optional: adjusting Desktop
In GUI desktop, disable auto updates: `Software & updates -> Updates`,
set `Automatically check for updates` to `Never`, untick all checkboxes, click close and click close
again.
GUI（Graphics User Interface）：图形用户界面

1
```shell script
# Removes nautilus bookmarks and disables lock screen
echo '==> `Ctrl+Alt+T` to start a GUI terminal'
curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/2-gnome.sh |
    bash

```

## 4.Install Linuxbrew

使用清华的[镜像](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/).

```shell script
echo "==> Tuna mirrors of Homebrew/Linuxbrew"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
/bin/bash brew-install/install.sh

rm -rf brew-install

test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

if grep -q -i Homebrew $HOME/.bashrc; then
    echo "==> .bashrc already contains Homebrew"
else
    echo "==> Update .bashrc"

    echo >> $HOME/.bashrc
    echo '# Homebrew' >> $HOME/.bashrc
    echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >> $HOME/.bashrc
    echo "export MANPATH='$(brew --prefix)/share/man'":'"$MANPATH"' >> $HOME/.bashrc
    echo "export INFOPATH='$(brew --prefix)/share/info'":'"$INFOPATH"' >> $HOME/.bashrc
    echo "export HOMEBREW_NO_ANALYTICS=1" >> $HOME/.bashrc
    echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> $HOME/.bashrc
    echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc

```

## 5.Download

Fill `$HOME/bin`, `$HOME/share` and `$HOME/Scripts`.

```shell script
curl -LO https://raw.githubusercontent.com/wang-q/dotfiles/master/download.sh
bash download.sh
source $HOME/.bashrc
```

curl:
-L, --location      Follow redirects
-O, --remote-name   Write output to a file named as the remote file

## 6.Install packages managed by Linuxbrew

Packages include:

* Programming languages: Perl, Python, R, Java, Lua and Node.js
* Some generalized tools

```shell script
bash $HOME/Scripts/dotfiles/brew.sh
source $HOME/.bashrc
```

cd ~/Scripts
git clone https://github.com/wang-q/dotfiles
bash $HOME/Scripts/dotfiles/brew.sh
source $HOME/.bashrc


Attentions:

* `r` and `gnuplot` have a lot of dependencies. Just be patient.

* Sometimes there are no binary packages; compiling from source codes may take extra time.

## 7.Packages of each language

```shell script
bash $HOME/Scripts/dotfiles/perl/install.sh

bash $HOME/Scripts/dotfiles/python/install.sh

bash $HOME/Scripts/dotfiles/r/install.sh

# Optional
# bash $HOME/Scripts/dotfiles/rust/install.sh

```

## 8.Bioinformatics Apps

```shell script
bash $HOME/Scripts/dotfiles/genomics.sh

bash $HOME/Scripts/dotfiles/perl/ensembl.sh

# Optional: huge apps
# bash $HOME/Scripts/dotfiles/others.sh

```

## 9.Optional: MySQL

```shell script
bash $HOME/Scripts/dotfiles/mysql.sh

# Following the prompts, create mysql users and install DBD::mysql

```

## 10.Optional: dotfiles

```shell script
bash $HOME/Scripts/dotfiles/install.sh
source $HOME/.bashrc

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

```

Edit `.gitconfig` to your own manually.

## 11.Directory Organization

* [`packer/`](packer): Scripts for building an Ubuntu base box

* [`prepare/`](prepare): Scripts for setting-up Ubuntu

* [`prepare/Vagrant.md`](prepare/Vagrant.md): Vagrant managed box

* [`prepare/CentOS.md`](prepare/CentOS.md): Steps for building CentOS 7 VMs

