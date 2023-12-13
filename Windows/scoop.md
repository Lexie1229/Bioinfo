# Scoop

## Install Scoop

* Install `Scoop`

```powershell
set-executionpolicy remotesigned -s currentuser
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install sudo 7zip
scoop install aria2 dark innounp
```
Scoop can utilize aria2 to use multi-connection downloads.
Close the powershell window and start a new one to refresh the environment variables.

## Install packages
```powershell
scoop bucket add extras
scoop install curl wget
scoop install gzip unzip grep
scoop install jq jid pandoc
scoop install bat ripgrep tokei hyperfine
scoop install sqlite sqlitestudio
# scoop install proxychains
```
* List installed packages
```powershell
scoop list
```

* scoop软件管理器：scoop < command > [< args >]
    * scoop bucket：管理scoop的buckets。
        * scoop bucket add|rm < name > [< repo >]：添加或删除存储库
        * scoop bucket list|known：列出所有已添加的/已知的bucket
    * scoop 默认的存储库为main
    * scoop install app：安装apps
        * scoop install extras/app:安装指定存储库的app
        * scoop install app@x.xx.x:安装app的指定版本(x.xx.x)
    * scoop uninstall app：卸载app
    * scoop list：列出所有已安装的app
    * scoop update：更新scoop
    * scoop update app：更新apps

* Packages
    * curl：(curl 选项 url)下载工具，利用URL语法在命令行方式下工作的开源文件传输工具
    * wget：(wget 选项 文件)
    * sqlite：SQLite是一个C语言库，是一个小型、快速、自包含、高可靠性、全功能的SQL数据库引擎


