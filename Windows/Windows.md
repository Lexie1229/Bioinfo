# Setting-up scripts for Windows 10
[TOC level=2]: # ""
- [Setting-up scripts for Windows 10](#setting-up-scripts-for-windows-10)
  - [Get ISO](#get-iso)
  - [Install, active and update Windows](#install-active-and-update-windows)
  - [Enable some optional features of Windows 10](#enable-some-optional-features-of-windows-10)
  - [WSL 2](#wsl-2)
  - [Ubuntu 20.04](#ubuntu-2004)
  - [Install `winget` and `Windows Terminal`](#install-winget-and-windows-terminal)
  - [Optional: Adjusting Windows](#optional-adjusting-windows)
  - [Optional: winget-pkgs](#optional-winget-pkgs)
  - [Optional: Windows 7 games](#optional-windows-7-games)
  - [Optional: Packages Managements](#optional-packages-managements)
  - [Optional: Rust and C/C++](#optional-rust-and-cc)
  - [Optional: sysinternals](#optional-sysinternals)
  - [Optional: QuickLook Plugins](#optional-quicklook-plugins)
  - [Directory Organization](#directory-organization)

> * Table of Contents, TOC


## Get ISO
Some features of Windows 10 20H1/2004 are needed here.
* Build 19041.84 or later
* English or Chinese Simplified
* 64-bit
* Windows 10
    * <ed2k:
      //|file|zh-cn_windows_10_business_editions_version_21h1_updated_sep_2021_x64_dvd_023d42d3.iso|5709488128|B09B1BA01F76C80E2BD8E798C9E89E7D|/>
    * <magnet:?xt=urn:btih:5C66F9BE1E46D0D4F7EC418D54C3A3FB03679D6D&dn=zh-cn_windows_10_business_editions_version_21h1_updated_sep_2021_x64_dvd_023d42d3.iso&xl=5709488128>
* Windows 11
    * <ed2k:
      //|file|zh-cn_windows_11_business_editions_version_21h2_updated_october_2021_x64_dvd_a84e149f.iso|5419143168|B0C4BE7271CD65B2173326239D4F8BA2|/>
    * <magnet:?xt=urn:btih:98BB0A1703D5E36ADCE9BAAA1E02D86C29C4DF95&dn=zh-cn_windows_11_business_editions_version_21h2_updated_october_2021_x64_dvd_a84e149f.iso&xl=5419143168>

> * ISO镜像文件：光盘镜像的存储格式之一  
> * Build：内部版本号（Version/Release-发布版本号）**.00  
> * 22H2版本：2022年第二次更新  
> * 2004:20年4月发布
> * Edition:版次(专业版/家庭版/企业版)    
> * 64-bit:中央处理器(central processing unit,CPU)位数为8字节，1Byte(字节)=8bit(位)  
> * x86_64:x86架构,64位拓展  
> * ed2k(eDonkey2000 network):文件共享网络 
> * magnet:磁力链接,是对等网络中进行信息检索和下载文档的电脑程序,下载BT种子

## Install, active and update Windows
* Enable Virtualization in BIOS or VM
* Active Windows 10 via KMS, <http://kms.nju.edu.cn/>
* Update Windows and then check system info
```powershell
# simple
winver
# details
systeminfo
```
After Windows updating, the Windows version is 19042.804 as my current date.

> * BIOS(basic input output system):基本输入输出系统（华为开机或重启时长按F2进入BIOS设置界面，设置Virtualization Technology-Enable状态）  
> * VMwave虚拟机  
> * KMS激活工具  
> * CMD（Windows Command Prompt）：命令提示符（Win+R打开“运行命令”窗口，输入“cmd”命令，快速执行指定任务）  
> * Poweshell/CMD：输入命令（winver：windows version；systeminfo:系统信息）

## Enable some optional features of Windows 10
* Mount Windows ISO to D: (or others)
* Open PowerShell as an Administrator
```powershell
# .Net 2.5 and 3
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:D:\sources\sxs
# Online
# DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
# SMB 1
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All
# Telnet
DISM /Online /Enable-Feature /FeatureName:TelnetClient
```

> * mount：Windows系统下，挂载文件到一个虚拟盘/虚拟文件夹中，通过访问这个虚拟盘/文件夹使用整个文件。  
> * .NET:提供一个快速的模块化平台，用于创建在 Windows、Linux 和 macOS 上运行的许多不同类型的应用程序。   
> * DISM（Deployment Image Servicing and Management）：部署映像服务和管理工具(DISM.exe)是一个命令行工具,位于所有Windows 10和Windows 11安装的c:\windows\system32文件夹中.    
> * DISM语法:DISM.exe {/Image:<path_to_offline_image>|/Online} [dism_options]{servicing_command} [<servicing_arguments>}
> * 映像规格(/online or /Image):/Online--以正在运行的操作系统为目标;/Image--指定脱机 Windows 映像的根目录的路径)  
> * powershell查询DISM服务命令及其参数的详细信息: DISM /Online /Enable-Feature /?
> * /Enable-Feature /FeatureName:<name_in_image> [/PackageName:<name_in_image>] [/Source:<source>] [/LimitAccess] [/All]:启用由 FeatureName 命令参数指定的功能;如果该功能是 Windows Foundation 应用程序包，则不必指定/PackageName,否则,请使用/PackageName 指定该功能的父应用程序包;如果这些功能是同一个父应用程序包中的组件，则可以使用多个/FeatureName 参数;使用 /Source 参数指定还原该功能所需的文件位置,可以使用多个 /Source 参数;使用 /LimitAccess 可阻止 DISM 联系 WU/WSUS (Windows Server Update Services,Windows服务器更新服务)获取联机映像;使用 /All 可启用指定功能的所有父级(上一级)功能。
> * /Source:指定Source,DISM 会先在指定的位置进行查找
> * SMB (Server Message Block) ：是一种客户端/服务器协议，用于控制对文件和整个目录以及其他网络资源（如打印机、路由器或向网络开放的接口）的访问。系统不同进程之间的信息交换（也称为进程间通信）可以基于 SMB 协议进行处理。它能被用于 Web 连接和客户端与服务器之间的信息沟通.  
> * TelnetClient:Telnet客户端(远程登陆客户端),是开发人员和管理员帮助管理和测试网络连接的工具,一般用于测试某台计算机的端口号是否可以连通.
> * Telnet协议是TCP/IP协议族中的一员，是Internet远程登录服务的标准协议和主要方式,talent服务的默认端口是23(虚拟端口).它为用户提供了在本地计算机上完成远程主机工作的能力.
> * cmd/powershell输入telnet以访问telnet客户端,输入help以查看支持的Telnet命令.
> * 端口(port):计算机与外界通讯交流的出口;http协议(80 端口);https协议(443 端口).
> * DISM /Online /Enable-Feature /FeatureName:NetFx3 /All 与 Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All 的区别:前者是使用DISM配置、部署Windows可选功能;后者是从PowerShell管理Windows可选功能.

## WSL 2
* Follow instructions of [this page](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install)
* Open PowerShell as an Administrator
```powershell
# HyperV
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
# WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
```
Update the [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-kernel) Linux kernel if necessarily.
Restart then set WSL 2 as default.
```powershell
wsl --set-default-version 2
```

> * VirtualMachinePlatform(虚拟机平台):
> * Microsoft-Hyper-V:Hyper-V是Microsoft的硬件虚拟化产品.它允许你创建和运行一个称为虚拟机的计算机的软件版本.每个虚拟机都充当运行操作系统和程序的完整计算机。当需要计算资源时，虚拟机可让你更灵活、有助于节省时间和资金，并且比在物理硬件上运行一个操作系统更高效地使用硬件.Hyper-V 在其自己的独立空间中运行每个虚拟机，这意味着你可以在同一硬件上同时运行多个虚拟机。你可能希望这样做以避免诸如影响其他工作负荷的崩溃等问题，或者为不同的人员、组或服务提供对不同系统的访问权限.家庭版不可用.
> * WSL（Windows Subsystem for Linux) 
> * kernel(内核):Linux内核是Linux操作系统（OS）的主要组件，也是计算机硬件与其进程之间的核心接口.它负责两者之间的通信，还要尽可能高效地管理资源.


## Ubuntu 20.04
Search `bash` in Microsoft Store or use the following command lines.
```powershell
if (!(Test-Path Ubuntu.appx -PathType Leaf))
{
    Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing
}
Add-AppxPackage .\Ubuntu.appx
```
Launch the distro from the Start menu, wait for a minute or two for the installation to complete,
and set up a new Linux user account.
The following command verifies the status of WSL:
```powershell
wsl -l -v
```

***Symlinks 软链接***
* WSL: reduce the space occupied by virtual disks
```shell
cd
rm -fr Script data
ln -s /mnt/c/Users/wangq/Scripts/ ~/Scripts
ln -s /mnt/d/data/ ~/data
```
* Windows: second disk
    * Open `cmd.exe` as an Administrator
```cmd
cd c:\Users\wangq\
mklink /D c:\Users\wangq\data d:\data
```

> * cd(change directory)
rm 
-s 软链接

## Install `winget` and `Windows Terminal`
```powershell
if (!(Test-Path Microsoft.WindowsTerminal.msixbundle -PathType Leaf))
{
    Invoke-WebRequest `
        'https://github.com/microsoft/winget-cli/releases/download/v1.2.10271/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' `
        -OutFile 'Microsoft.DesktopAppInstaller.msixbundle'
}
Add-AppxPackage -path .\Microsoft.DesktopAppInstaller.msixbundle

winget --version

winget install -e --id Microsoft.WindowsTerminal

winget install -e --id Microsoft.PowerShell

winget install -e --id Git.Git

```

Open `Windows Terminal`

* Set `Settings` -> `Startup` -> `Default profile` to `PowerShell`, not `Windows PowerShell`.

* Set `Default terminal application` to `Windows Terminal`.

* Hide unneeded `Profiles`.

## Optional: Adjusting Windows

Works with Windows 10 or 11.

```powershell
mkdir -p ~/Scripts
cd ~/Scripts
git clone --recursive https://github.com/wang-q/windows

cd ~/Scripts/windows/setup
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File "Win10-Initial-Setup-Script/Win10.ps1" `
    -include "Win10-Initial-Setup-Script/Win10.psm1" `
    -preset "Default.preset"

```

Log in to the Microsoft Store and get updates from there.

## Optional: winget-pkgs

```powershell
# programming
# winget install -s winget -e --id AdoptOpenJDK.OpenJDK
winget install -s winget -e --id Oracle.JavaRuntimeEnvironment
winget install -s winget -e --id Oracle.JDK.18
# winget install -s winget -e --id Microsoft.dotnet
winget install -s winget -e --id StrawberryPerl.StrawberryPerl
# winget install -e --id Python.Python
winget install -s winget -e --id RProject.R
# winget install -s winget -e --id RProject.Rtools
# winget install -s winget-e --id OpenJS.NodeJS.LTS
winget install -s winget -e --id RStudio.RStudio.OpenSource
winget install -s winget -e --id Kitware.CMake

# development
winget install -s winget -e --id GitHub.GitHubDesktop
winget install -s winget -e --id WinSCP.WinSCP
winget install -s winget -e --id Microsoft.VisualStudioCode
winget install -s winget -e --id ScooterSoftware.BeyondCompare4
winget install -s winget -e --id JetBrains.Toolbox
winget install -s winget -e --id Clement.bottom
# winget install -e --id WinFsp.WinFsp
# winget install -e --id SSHFS-Win.SSHFS-Win
# \\sshfs\REMUSER@HOST[\PATH]

# winget install -e --id Docker.DockerDesktop
# winget install -e --id VMware.WorkstationPlayer
# winget install -s winget -e --id Canonical.Multipass

# utils
winget install -s winget -e --id voidtools.Everything
winget install -s winget -e --id Bandisoft.Bandizip
winget install -s msstore Rufus # need v3.18 or higher
winget install -s winget -e --id QL-Win.QuickLook
winget install -s winget -e --id AntibodySoftware.WizTree
winget install -s winget -e --id HandBrake.HandBrake
# winget install -s winget -e --id Microsoft.PowerToys
winget install -s winget -e --id qBittorrent.qBittorrent
winget install -s winget -e --id IrfanSkiljan.IrfanView

# apps
winget install -s winget -e --id Mozilla.Firefox
winget install -s winget -e --id Tencent.WeChat
winget install -s winget -e --id Tencent.TencentMeeting
winget install -s winget -e --id Tencent.QQ
winget install -s winget -e --id NetEase.CloudMusic
winget install -s winget -e --id Youdao.YoudaoDict
winget install -s winget -e --id Baidu.BaiduNetdisk
winget install -s winget -e --id stax76.mpvdotnet
winget install -s winget -e --id Zotero.Zotero

# winget install -e --id Adobe.AdobeAcrobatReaderDC
# winget install -e --id Alibaba.DingTalk

```

## Optional: Windows 7 games

<https://winaero.com/download.php?view.1836>

## Optional: Packages Managements

* [`scoop.md`](setup/scoop.md)
* [`msys2.md`](setup/msys2.md)

## Optional: Rust and C/C++

* [`rust.md`](setup/rust.md)

## Optional: sysinternals

* Add `$HOME/bin` to Path
* Open PowerShell as an Administrator

```powershell
mkdir $HOME/bin

# Add to Path
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$HOME\bin",
    [EnvironmentVariableTarget]::Machine)

```

* Download and extract

```powershell
scoop install unzip

$array = "DU", "ProcessExplorer", "ProcessMonitor", "RAMMap"

foreach ($app in $array) {
    aria2c.exe -c "https://download.sysinternals.com/files/$app.zip"
}

foreach ($app in $array) {
    unzip "$app.zip" -d $HOME/bin -x Eula.txt
}

rm $HOME/bin/*.chm
rm $HOME/bin/*64.exe
rm $HOME/bin/*64a.exe

```

## Optional: QuickLook Plugins

<https://github.com/QL-Win/QuickLook/wiki/Available-Plugins>

```powershell
# epub
$url = (
curl.exe -fsSL https://api.github.com/repos/QL-Win/QuickLook.Plugin.EpubViewer/releases/latest |
    jq -r '.assets[0].browser_download_url'
)
curl.exe -LO $url

# office
$url = (
curl.exe -fsSL https://api.github.com/repos/QL-Win/QuickLook.Plugin.OfficeViewer/releases/latest |
    jq -r '.assets[0].browser_download_url'
)
curl.exe -LO $url

# folder
$url = (
curl.exe -fsSL https://api.github.com/repos/adyanth/QuickLook.Plugin.FolderViewer/releases/latest |
    jq -r '.assets[0].browser_download_url'
)
curl.exe -LO $url

```

Select the `qlplugin` file and press `Spacebar` to install the plugin.

## Directory Organization

* [`packer/`](packer/): Scripts for building a Windows 10 box for Parallels.

* [`setup/`](setup/): Scripts for setting-up Windows.
