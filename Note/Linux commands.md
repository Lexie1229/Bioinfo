# Linux commands
### Linux cut
cut:剪切文件中选定的行写至标准输出.
* cut OPTION [FILE]
  * -f/--fields=LIST:select only these fields(以区域为单位进行分割，仅显示选定的区域).
  * -b/--bytes=LIST:select only these bytes(以字节为单位进行分割，仅显示选定的字节).
  * -c/--characters=LIST:select only these characters(以字符为单位进行分割，仅显示选定的字符).

### Linux find
find：用于查找文件和目录.
* find [-H] [-L] [-P] [-Olevel] [-D debugopts] [path] [expression]
  * -maxdepth LEVELS：限制递归搜索深度，即指定搜索多少级子目录.
  * -type [bcdpflsD]：按文件类型搜索.
    * f：表示一般文件.
    * d：表示目录.
  * -name PATTERN：按文件名搜索.
  * -size N[bcwkMG]：按文件大小搜索.

### Linux grep
grep：用于查找文件里符合条件的字符串.
* grep [OPTION] PATTERNS [FILE]
  * -i/--ignore-case:ignore case distinctions in patterns and data(忽略字符大小写的差别).
  * -q/--quiet, --silent: suppress(抑制) all normal output(不显示任何信息).

### Linux gzip
gzip：用于压缩或解压文件,扩展名为.gz.
* gzip [OPTION] [FILE]
  * -d/--decompress：decompress.
  * -c/--stdout:write on standard output, keep original files unchanged.
  * -f/--force:force overwrite of output file and compress links.

### Linux head
head:用于查看文件开头部分的内容.
* head [OPTION] [FILE]
  * -n/--lines=[-] NuM:print the first NUM lines instead of the first 10（显示前NUM行的内容）；with the leading '-', print all but the last NUM lines of each file(显示所有的内容，除后NUM行).
  * -c/--bytes=[-] NUM:print the first NUM bytes of each file(显示前NUM字节的内容);with the leading '-', print all but the last NUM bytes of each file.
  * -q/--quiet,--silent:never print headers giving file names(隐藏文件名).
  * -v/--verbose:always print headers giving file names(显示文件名).

### Linux nohup
nohup(no hang up):用于不挂断地运行命令，退出终端不影响运行.
* nohup COMMAND [ARG]
* 区别：
  * &：后台运行，关闭终端，任务终止，`Ctrl+C`，任务继续；前台接收标准输入，终止会丢失标准输出和标准错误信息；忽略SIGINT信号。
  * nohup：不挂断运行，关闭终端，任务继续，`Ctrl+C`，任务终止；关闭标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件；忽略SIGHUP信号。
  * nohup &：永久在后台执行，接受标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件。

### Linux pwd
pwd(print work directory):用于显示当前工作目录.
* pwd [OPTION]
  * -P：print the physical directory, without any symbolic links(显示物理路径，而不带任何软链接).

### Linux rm
rm(remove):用于删除一个文件或者目录.
* rm [option] [file]
  * rm filename:删除指定文件.
  * -r/-R,--recursive,递归:remove directories and their contents recursively（删除当前目录下的所有文件及目录).
  * -f/--force: ignore nonexistent files and arguments, never prompt(忽略不存在的文件和参数，从不提示).

### Linux rsync
rsync(remote sync):用于远程同步数据.
* rsync [OPTION] SRC [SRC] DEST
  * -a/--archive:archive mode; equals -rlptgoD (no -H,-A,-X)（归档模式，表示以递归方式传输文件，并保持所有属性.
  * -v/--verbose:increase verbosity（增加详细程度).
  * --partial:keep partially transferred files
  * --progress:show progress during transfer.
  * -r/--recursive：recurse into directories(递归到目录中).
  * -l/--links:copy symlinks as symlinks.
  * -p/--perms:preserve permissions(保留文件权限).
  * -t/--times:preserve modification times(保留修改时间).
  * -P:same as --partial --progress.

### Linux sort
sort:用于对文本文件的内容排序.
* sort [OPTION] [FILE]:读取文件内容，进行排序.
  * -n/--numeric-sort:compare according to string numerical value（根据字符串数值进行排序,从小到大).
  * -r/--reverse:reverse the result of comparisons（以相反的顺序排序,从大到小).
  * -k/--key=KEYDEF:sort via a key; KEYDEF gives location and type.KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position, where F is a field number and C a character position in the field; both are origin 1, and the stop position defaults to the line's end.（按指定的列进行排序).
    * 例如：-k 1.2，3.3  表示从第一个字段的第二个字符开始，到第三个字段的第三个字符结束进行排序.
  * -t/--field-separator=SEP:use SEP instead of non-blank to blank transition(指定排序时所用的栏位分隔字符).
* sort [OPTION]:读取标准输入，进行排序.

### Linux split
split:用于分割文件。
* split [OPTION] [FILE [PREFIX]]
  * -l/--lines=NUMBER：put NUMBER lines/records per output file(指定每个文件分割的行数).
  * -a/--suffix-length=N：generate suffixes of length N (default 2)(生成长度为N的后缀，默认值为2).
  * -d：use numeric suffixes starting at 0, not alphabetic(使用从0开始的数字后缀，而非字母).

### Linux tar
tar(tape archive)：用于文件的打包压缩及解压.
* tar [OPTION] [FILE]
  * -x/--extract/--get：extract files from an archive(从备份文件/存档中还原文件)。
  * -z/--gzip/--gunzip/--ungzip：filter the archive through gzip(通过gzip指令处理备份文件)。
  * -v/--verbose:verbosely list files processed(详细列出已处理的文件,显示指令执行过程)。
  * -f/--file=ARCHIVE：use archive file or device ARCHIVE（指定备份文件）。
  * -j/--bzip2:filter the archive through bzip2（通过bzip2指令处理备份文件）。

### Linux wc
wc(word count):用于计算字数.
* wc [OPTION] [FILE]
  * wc filename：print newline, word, and byte counts for each FILE(显示行数、字数和字节数).
  * -l/lines：print the newline counts(显示行数).
  * -c/--bytes：print the byte counts(显示字节数).
  * -m/--chars：print the character counts(显示字符数).
  * -w/--words：print the word counts(显示字数).

---------------------------------------------------------------------


### Linux mount
mount:用于挂载
* mount [options] <source> <directory>
  * -a/--all:mount all filesystems mentioned in fstab(将/etc/fstab)
  * -o




### Linux sed
sed:用于利用脚本处理文本文件。/ 替换


### sync
* sync(synchronize):用于同步数据。



### Linux code
code:
* code.exe [options][paths]


### ls
ls(list directory contents):用于显示指定工作目录下的内容.
* -l:use a long listing format(使用长格式显示当前目录中的文件和子目录).
* -a/--all：do not ignore entries starting with .(显示当前目录中的所有文件和子目录，包括隐藏文件).
* -h

### mv
mv
* mv [OPTION] SOURCE DIRECTORY
* -t/--target-directory=DIRECTORY：move all SOURCE arguments into DIRECTORY.



### Linux mkdir





> count
> chomd
> ssh
> cat
> tldr
> jobs
> dos2unix


