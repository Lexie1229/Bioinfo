# Setting-up scripts for Ubuntu 20.04

[TOC levels=1-3]: # ""

- [Setting-up scripts for Ubuntu 20.04](#setting-up-scripts-for-ubuntu-2004)
  - [1.Bypass GFW blocking](#1bypass-gfw-blocking)
  - [2.Install packages needed by Linuxbrew and some others](#2install-packages-needed-by-linuxbrew-and-some-others)
  - [3.Optional: adjusting Desktop](#3optional-adjusting-desktop)
  - [4.Install Linuxbrew](#4install-linuxbrew)
  - [5.Download](#5download)
  - [6.Install packages managed by Linuxbrew](#6install-packages-managed-by-linuxbrew)
  - [7.Packages of each language](#7packages-of-each-language)
  - [8.Bioinformatics Apps](#8bioinformatics-apps)
  - [9.Optional: MySQL](#9optional-mysql)
  - [10.Optional: dotfiles](#10optional-dotfiles)
  - [11.Directory Organization](#11directory-organization)

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


> * GFW(Great Firewall)-防火墙
> * hosts文件是linux系统中负责ip地址与域名快速解析的文件
> * **raw.githubusercontent.com**github用来存储用户上传文件（不是项目仓库的文件，而是issue里的图片之类的）的服务地址
> * Domain（域）：githubusercontent.com
> * Domain Label：githubusercontent
> * vi 文件名 ：进入一般模式
> * sudo vim 文件名 （sudo是系统管理指令，允许系统管理员让普通用户执行一些或者全部的root命令的一个工具）
> * I切换编辑模式 ； esc退出编辑模式
> * ：wq（保存/退出）
> * ：wq！（强制保存退出）
> * ip地址 主机名/域名 （主机别名）
> * 打开C:\Windows\System32\drivers\etc\hosts文件，输入 ip地址 主机名/域名 
> * cmd/Powershell中输入 ping 域名

## 2.Install packages needed by Linuxbrew and some others
```shell script
echo "==> When some packages went wrong, check http://mirrors.ustc.edu.cn/ubuntu/ for updating status."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/1-apt.sh)"
```


> * curl:下载工具
>> * -f, --fail          Fail silently (no output at all) on HTTP errors 连接失败不显示http错误
>> * -L, --location      Follow redirects 让HTTP 请求跟随服务器的重定向
>> * -S, --show-error    Show error even when -s is used 只输出错误信息
>> * -s, --silent        Silent mode 不输出错误和进度信息
>> * -o, --output <file> Write to file instead of stdout 将服务器的回应保存成文件
>> * -O, --remote-name   Write output to a file named as the remote file 将服务器回应保存成文件，并将 URL 的最后部分当作文件名
> * bash：
>> * -c:从字符串中读入命令
>> * -x:输出执行过程
>> * -n:检测脚本语法是否正确 
> * $():``(反引号），命令替换，用来重组命令行，先完成引号里的命令行，然后将其结果替换出来，再重组成新的命令行。
> * ${}:变量替换。

## 3.Optional: adjusting Desktop
In GUI desktop, disable auto updates: `Software & updates -> Updates`,
set `Automatically check for updates` to `Never`, untick all checkboxes, click close and click close again.

```shell script
# Removes nautilus bookmarks and disables lock screen
echo '==> `Ctrl+Alt+T` to start a GUI terminal'
curl -fsSL https://raw.githubusercontent.com/wang-q/ubuntu/master/prepare/2-gnome.sh |
    bash
```
> * GUI（Graphics User Interface）：图形用户界面
> * 管道命令：管道是一种通信机制，通常用于进程间的通信，它将前面每一个进程的输出（stdout,标准输出，1）直接作为下一个进程的输入（stdin，标准输入，0）。管道命令使用|作为界定符号，仅能处理standard output(stdout),而忽略standard error output(stderr，标准错误，2)。
> * stdout redirection（输出重定向)：使用符号直接把程序输出转向到某个文件或某个程序。
> * 文字描述符：0（stdin，标准输入）、1（stdout，标准输出）、2（stderr，标准错误）.
> * 重定向符号：> 或 >> (前者先清空文件，然后再写入内容；后者将重定向的内容追加到现有文件的尾部)。

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

export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
brew update

> * 安装步骤:
>> * 设置环境变量（临时替换）
>> * 安装Linuxbrew
>>> * Linuxbrew：软件包管理工具，拥有安装、卸载、更新、查看、搜索等很多实用的功能。
> * 安装成功后需将 brew 程序的相关路径加入到环境变量中
4 替换现有仓库上游
替换 brew 程序本身的源

> * git clone：拷贝Git仓库到本地，即将存储库克隆到新目录中。
>> * git clone [url] <rename>:拷贝至本地并重命名存储库。
>> * --depth=1:用于指定克隆深度，为1即表示只克隆最近一次的commit（提交）。限制克隆深度，不会下载历史记录，加快克隆速度。
> * test：用于检查某个条件是否成立和比较值，可以进行数值、字符串和文件的检测。
>> * test expression:判断文件是否存在(当 test 判断 expression 成立时，退出状态为 0，否则为非 0 值).
>> * [ expression ]:test 命令也可以简写为[],左右两边的空格是必须的。
>> * test -e file: 判断文件是否存在。
>> * test -d file: 判断文件是否存在并且是目录。
>> * if test  (表达式为真)
>> * if test !（表达式为假）
> * 逻辑运算符：&&(与)、||(或)、!(非)
>> * 优先级：！> && > ||
> * $HOME：表示环境变量。Linux中变量调用，在变量名前加一个$符号，一般全部大写作为规范。HOME指定当前用户的主目录。
> * $PATH:表示环境变量。查找路径。
> * Linux文件夹：
>> * bin（binary，二进制）：存放可执行的二进制文件。
> * sbin：存放管理员使用的存储二进制系统程序文件。
> * .bashrc:home目录下的一个shell文件，用于储存用户的个性化设置，在bash每次启动时都会加载.bashrc文件中的内容，并根据内容定制当前bash的配置和环境。
>> * 功能：个性化指令、设置环境路径、设置提示符。


> * alias:定义命令别名。
> * source:用于从当前shell会话中的文件读取和执行命令,通常用于保留、更改当前shell中的环境变量.
>> * source:
>> * source可以用.代替。


> * Linux ctrl快捷键：
>> * ctrl+c:退出一个命令。
>> * ctrl+d:退出一个终端；删除光标后一个字符。
>> * ctrl+h:删除光标前一个字符。
>> * ctrl+a:光标跳转行首。
>> * ctrl+e:光标移到行尾。
>> * ctrl+b:光标左移一个字符。
>> * ctrl+f:光标右移一个字符。





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

> * 







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
> * 问题：
> perl：GraphViz 安装失败（Finding xxx on mirror https://mirrors.aliyun.com/CPAN failed.Couldn't find module or a distribution xxx）
>> 解决：GraphViz2

> * CPAM(Comprehensive Perl Archive Network,Perl综合档案网)
> cpanm：
>> * cpanm:一个新型的perl包管理器.
>> * cpanm [options] Module:
>> * --mirror-only:Use the mirror's index file instead of the CPAN Meta DB 
>> * -n(--notest):Do not run unit tests
>> * -q(--quiet):Turns off the most output



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

