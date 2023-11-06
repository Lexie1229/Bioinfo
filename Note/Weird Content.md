# To Remember
## 1 Symbol

* [[ ]] 表示条件测试语句，用于测试条件是否为真。
* (( )) 通常用于数学计算和变量赋值操作，它会将圆括号内的数学表达式计算出结果，并将结果存储到指定的变量中。
* . 表示当前工作目录(命令行）；隐藏文件(Linux系统)；匹配换行符外的任意字符(正则表达式)。
* \- 表示标准输入（STDIN）或标准输出（STDOUT)。
* < 表示输入重定向符号，用于将文件或命令的输出重定向为另一个命令或程序的输入。
* \> 表示输出重定向符，用于将一个命令的输出重定向为另一个文件。
* \\ 表示转义字符，用于转义特殊字符。
* {} 表示执行某个命令时，将要操作的文件名或目录名。
* & 表示后台运行；命令的分隔符。
* 重定向
    * 1>&2 表示把标准输出重定向到标准错误。
    * 2>&1 表示把标准错误输出重定向到标准输出。
    * &>filename 表示把标准输出和标准错误输出都重定向到文件filename。
    * 2>/dev/null 表示将标准错误输出重定向到/dev/null，即丢弃错误信息，不显示在终端上。
* $? $0 $1 $2
    * echo $?：返回上一个命令的状态，0表示执行成功，其它任何值表明执行错误。
    * echo $0：返回sell脚本本身的名字。
    * echo $1：返回shell的第一个参数。
    * echo $2：返回shell的第二个参数。



## 2 File type

```txt
The file type is one of the following characters:  
    -  regular file  普通文件
    b  block special file  块设备文件
    c  character special file  字符设备文件
    C  high performance ("contiguous data") file  高性能（"连续数据"）文件
    d  directory  目录
    D  door (Solaris 2.5 and up)  门
    l  symbolic link  符号链接
    M  off-line ("migrated") file (Cray DMF)  离线（"迁移"）文件（仅适用于 Cray DMF）
    n  network special file (HP-UX)  网络设备文件（仅适用于 HP-UX）
    p  FIFO (named pipe)  命名管道
    P  port (Solaris 10 and up)  端口（仅适用于 Solaris 10 及以上版本）
    s  socket  套接字
    ?  some other file type  其他一些文件类型
```

## 3 Command

config:设置参数
makefile

## 4 Abbreviation
* DDR(Double Data Rate)：一种内存类型，是同步动态随机存取存储器（SDRAM，synchronous dynamic random-access memory）的一种类型。      








( )：指令群组(command group).
第一性原理

