# Common process
## 建立软链接

```bash
# cmd（管理员权限，无需创建文件夹）
mklink /D c:\Users\zhouj\Desktop\targetdirectory(“快捷方式”) d:\sourcedirectory

# linux
ln -s /mnt/c/biosoft/ ~/biosoft(“快捷方式”)
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






