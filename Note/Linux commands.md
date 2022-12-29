# Linux commands
### Linux sort
sort:用于对文本文件的内容排序.
* sort [OPTION] [FILE]:读取文件内容，进行排序.
  * -n(--numeric-sort):compare according to string numerical value（根据字符串数值进行排序,从小到大).
  * -r(--reverse):reverse the result of comparisons（以相反的顺序排序,从大到小).
  * -k(--key=KEYDEF):sort via a key; KEYDEF gives location and type.KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position, where F is a field number and C a character position in the field; both are origin 1, and the stop position defaults to the line's end.（按指定的列进行排序).
    * 例如：-k 1.2，3.3  表示从第一个字段的第二个字符开始，到第三个字段的第三个字符结束进行排序.
  * -t(--field-separator=SEP):use SEP instead of non-blank to blank transition(指定排序时所用的栏位分隔字符).
* sort [OPTION]:读取标准输入，进行排序.

### Linux cut
cut:剪切文件中选定的行写至标准输出.
* cut OPTION [FILE]
  * -f(--fields=LIST):select only these fields(以区域为单位进行分割，仅显示选定的区域).
  * -b(--bytes=LIST):select only these bytes(以字节为单位进行分割，仅显示选定的字节).
  * -c(--characters=LIST):select only these characters(以字符为单位进行分割，仅显示选定的字符).

### Linux grep
grep：用于查找文件里符合条件的字符串.
* grep [OPTION] PATTERNS [FILE]
  * -i(--ignore-case):ignore case distinctions in patterns and data(忽略字符大小写的差别).
  * -q(--quiet, --silent): suppress(抑制) all normal output(不显示任何信息).

### Linux rm
rm(remove):用于删除一个文件或者目录.
* rm [option] [file]
  * rm filename:删除指定文件.
  * -r(-R,--recursive,递归):remove directories and their contents recursively（删除当前目录下的所有文件及目录).
  * -f(--force): ignore nonexistent files and arguments, never prompt(忽略不存在的文件和参数，从不提示).

### Linux nohup
nohup(no hang up):用于不挂断地运行命令，退出终端不影响运行。
* nohup COMMAND [ARG]
* 区别：
  * &：后台运行，关闭终端，任务终止，`Ctrl+C`，任务继续；前台接收标准输入，终止会丢失标准输出和标准错误信息；忽略SIGINT信号。
  * nohup：不挂断运行，关闭终端，任务继续，`Ctrl+C`，任务终止；关闭标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件；忽略SIGHUP信号。
  * nohup &：永久在后台执行，接受标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件。

### Linux gzip
gzip：用于压缩或解压文件,扩展名为.gz.
* gzip [OPTION] [FILE]
  * -d(--decompress)：decompress.
  * -c(--stdout):write on standard output, keep original files unchanged.

## Linux head
head:用于查看文件开头部分的内容。
* head [OPTION] [FILE]
  * -n(--lines=[-] NuM):print the first NUM lines instead of the first 10（显示前NUM行的内容）；with the leading '-', print all but the last NUM lines of each file(显示所有的内容，除后NUM行).
  * -c(--bytes=[-] NUM):print the first NUM bytes of each file(显示前NUM字节的内容);with the leading '-', print all but the last NUM bytes of each file.
  * -q(--quiet,--silent):never print headers giving file names(隐藏文件名).
  * -v(--verbose):always print headers giving file names(显示文件名).



### Linux tar
tar：
* tar [OPTION] [FILE]
  * -x, --extract, --get       extract files from an archive
  * -f, --file=ARCHIVE         use archive file or device ARCHIVE
jxvf








### Linux pwd
pwd


### Linux mkdir

