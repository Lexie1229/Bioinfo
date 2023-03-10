# Commands
## Linux commands

### Linux bc
bc(binary calculator)：用于任意精度的计算.
* bc [options] [file]
  * -l/--mathlib：use the predefined math routines(定义使用的标准数学库).

### Linux bg
bg(background)：用于将后台暂停的工作恢复到后台执行.
* fg [job_spec]

### Linux cut
cut:剪切文件中选定的行写至标准输出.
* cut OPTION [FILE]
  * -f/--fields=LIST:select only these fields(以区域为单位进行分割，仅显示选定的区域).
  * -b/--bytes=LIST:select only these bytes(以字节为单位进行分割，仅显示选定的字节).
  * -c/--characters=LIST:select only these characters(以字符为单位进行分割，仅显示选定的字符).
  * -d/--delimiter=DELIM：use DELIM instead of TAB for field delimiter(指定分隔符).

### Linux fg
fg(foreground)：用于将后台暂停的工作恢复到前台执行.
* fg [job_spec]

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
  * -v/--invert-match：select non-matching lines(反向查找，仅显示不匹配的行).
  * -x/--line-regexp：match only whole lines(精确匹配，匹配整行).
  * -r/--recursive：like --directories=recurse(递归查找子目录中的文件).

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

### Linux jobs
jobs：用于显示当前终端的后台的工作状态.
* jobs [-lnprs] [jobspec] or jobs -x command [args]
  * -l：lists process IDs in addition to the normal information(显示进程的PID号).
  * -n：lists only processes that have changed status since the last notification(仅列出上次通知后状态改变的进程).
  * -p：lists process IDs only(仅列出进程的PID号).
  * -r：restrict output to running jobs(仅列出运行中的进程).
  * -s：restrict output to stopped jobs(仅列出已停止的进程).

### Linux nohup
nohup(no hang up):用于不挂断地运行命令，退出终端不影响运行.
* nohup COMMAND [ARG]
* 区别：
  * &：后台运行，关闭终端，任务终止，`Ctrl+C`，任务继续；前台接收标准输入，终止会丢失标准输出和标准错误信息；忽略SIGINT信号。
  * nohup：不挂断运行，关闭终端，任务继续，`Ctrl+C`，任务终止；关闭标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件；忽略SIGHUP信号。
  * nohup &：永久在后台执行，接受标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件。

### paste
paste：用于将多个文件的行逐行合并成一个输出.
* paste [OPTION] [FILE]
  * -d/--delimiters=LIST：reuse characters from LIST instead of TABs(指定分隔符).
  * -s/--serial：paste one file at a time instead of in parallel(将所有输入文件合并成单个文件，并将所有行连接在一起).

### Linux ps
ps(process status):用于显示当前进程的状态.
* ps [options]
  * -A/-e：all processes(显示所有进程).
  * -a：all with tty, except session leaders.
  * a：all with tty, including other users(显示所有进程，包括其他用户的进程).
  * u: user-oriented format(面向用户的格式).
  * x：processes without controlling ttys.

### Linux pwd
pwd(print work directory):用于显示当前工作目录.
* pwd [OPTION]
  * -P：print the physical directory, without any symbolic links(显示物理路径，而不带任何软链接).

### Linux rm
rm(remove):用于删除一个文件或者目录.
* rm [option] [file]
  * rm filename:删除指定文件.
  * -r/-R,--recursive,递归:remove directories and their contents recursively(删除当前目录下的所有文件及目录).
  * -f/--force: ignore nonexistent files and arguments, never prompt(忽略不存在的文件和参数，从不提示).

### Linux rsync
rsync(remote sync):用于远程同步数据.
* rsync [OPTION] SRC [SRC] DEST
  * -a/--archive:archive mode; equals -rlptgoD (no -H,-A,-X)(归档模式，包括递归复制、保留链接、保留文件权限、保留时间戳、保留所有者和组、保留设备文件).
  * -v/--verbose:increase verbosity(增加详细程度).
  * --partial:keep partially transferred files(保留不完整的文件).
  * --progress:show progress during transfer(显示传输进度).
  * -r/--recursive：recurse into directories(递归复制目录和子目录).
  * -l/--links:copy symlinks as symlinks(保留文件链接).
  * -p/--perms:preserve permissions(保留文件权限).
  * -t/--times:preserve modification times(保留文件时间时间).
  * -g/--group：preserve group(保留文件属组).
  * -o/--owner：preserve owner(super-user only)(保留文件属者).
  * --devices：preserve device files(super-user only)(保留设备文件，如/dev/).
  * --specials：preserve special files(保留特殊文件，如/proc/).
  * -P：same as --partial --progress.
  * -D：same as --devices --specials.

### Linux sed
sed:用于利用脚本处理文本文件，对文本进行编辑和替换.
* sed [OPTION] {script-only-if-no-other-script} [input-file]
  * -e script/--expression=script：add the script to the commands to be executed(指定脚本处理输入的文本文件).
    * a：新增，在当前行后添加一行或多行。
    * c：替换，用c后面的字符串替换原数据行。
    * i：插入，在当前行前插入一行或多行。
    * d：删除，删除指定的行。
    * p：打印，输出指定的行。
    * s：字符串替换，用一个字符串替换另一个字符串。
    * 说明：动作中，数字可以代表行号，逗号表示连续的行范围，"$"可以表示最后一行；当添加/替换/插入多行时，除最后一行外，每行末尾需要用"\"表示数据未完结。
  * -f script-file/--file=script-file：add the contents of script-file to the commands to be executed(指定脚本文件处理输入的文本文件).
  * -i[SUFFIX]/--in-place[=SUFFIX]：edit files in place (makes backup if SUFFIX supplied)(直接修改读取数据的文件，如果使用SUFFIX，则备份；默认不会修改原始文件).
  * -n/--quiet/--silent：suppress automatic printing of pattern space(仅显示处理后的行,其他不显示).

### Linux shopt
shopt(shell option)：用于显示或修改shell的选项设置.
* shopt [-pqsu] [-o] [optname]
  * shopt：Without any option arguments, list each supplied OPTNAME, or all shell options if no OPTNAMEs are given, with an indication of whether or not each is set(显示所有可以设置的shell操作选项).
  * -s：enable (set) each OPTNAME(启用OPTNAME).

### Linux sort
sort:用于对文本文件的内容排序.
* sort [OPTION] [FILE]:读取文件内容，进行排序.
  * -n/--numeric-sort:compare according to string numerical value(根据字符串数值进行排序,从小到大).
  * -r/--reverse:reverse the result of comparisons(以相反的顺序排序,从大到小).
  * -k/--key=KEYDEF:sort via a key; KEYDEF gives location and type.KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position, where F is a field number and C a character position in the field; both are origin 1, and the stop position defaults to the line's end.(按指定的列进行排序).
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

### Linux tr
tr(text replacer)：用于转换或删除文件中的字符.
* tr [OPTION] SET1 [SET2]
  * [:blank:]：all horizontal whitespace(所有水平空格).
  * \n：new line(新行).

### Linux uniq
uniq：用于检查及删除文本文件中重复出现的行列.
* uniq [OPTION] [INPUT [OUTPUT]]
  * -c/--count：prefix lines by the number of occurrences(在每行前面显示每个行出现的次数).
  * -d/--repeated：only print duplicate lines, one for each group(只显示重复的行).
  * -u/--unique：only print unique lines(只显示不重复的行).

### Linux wc
wc(word count):用于计算字数.
* wc [OPTION] [FILE]
  * wc filename：print newline, word, and byte counts for each FILE(显示行数、字数和字节数).
  * -l/lines：print the newline counts(显示行数).
  * -c/--bytes：print the byte counts(显示字节数).
  * -m/--chars：print the character counts(显示字符数).
  * -w/--words：print the word counts(显示字数).

### Linux xargs
* xargs(eXtended ARGuments):用于构建和执行命令行命令,从标准输入或文件中读取一系列参数，将其转换为命令行参数.
  * xargs [OPTION] COMMAND [INITIAL-ARGS]
  * -I R：same as --replace=R.
  * -i/--replace[=R]:replace R in INITIAL-ARGS with names read from standard input, split at newlines;if R is unspecified, assume {}(将INITIAL-ARGS中的R替换为从标准输入读取的名称，在换行符处拆分;如果未指定R，则假设{}).

---------------------------------------------------------------------
## Other commands

### echo
echo：用于输出字符串.
* echo [-neE] [ARGUMENTS]
  * -e：启用转义字符的解释.
  * -n：不输出结尾的换行符.

### parallel
parallel:用于构建并行运行命令.
* parallel [options] [command [arguments]] (::: arguments参数|:::: argfile(s)文件)
  * -j(--jobs) n：run n jobs in parallel(并行任务数).
  * -k：keep same order(保持顺序不变).
  * -d delim：Input items are terminated by delim(指定分隔符).
  * --pipe：split stidn to multiple jobs(将输入分为多块).
  * --line-buffer：(输出缓冲模式设置为行缓冲，指定并行执行的每个任务的输出应立即发送到控制台，而不是缓冲输出直到任务完成，不会在磁盘上缓冲，可以处理无限量的数据).
  * --colsep regexp：Split input on regexp for positional replacements()(指定输入行中字段的分隔符（或正则表达式），把行切分成列).
  * --no-run-if-empty
  * -r：Do not run empty input.
  * {} {.} {/} {/.} {#} {%} {= perl code =}：Replacement strings(替换字符串).
    * {}：Input line(输入行).
    * {.}：Input line without extension(输入行，不带扩展名).
    * {/}：Basename of input line(输入行，不带路径，仅显示文件名).
    * {//}：Dirname of input line(输入行，仅保留路径).
    * {/.}：Basename of input line without extension(输入行，不带扩展名和路径).
    * {#}：Sequence number of the job to run(输出任务编号).
    * {%}：Job slot number(输出任务槽号).
  * {3} {3.} {3/} {3/.} {=3 perl code =}：Positional replacement strings(替换特定位置的字符串).
    * {n}：Argument from input source n or the n'th argument.
    * {n.}：Argument from input source n or the n'th argument without extension.
    * {n/}：Basename of argument from input source n or the n'th argument.
    * {n//}：Dirname of argument from input source n or the n'th argument.
    * {n/.}：Basename of argument from input source n or the n'th argument without extension.
    * {=perl expression=}：Replace with calculated perl expression.

### egaz
egaz(Easy Genome Aligner)：用于处理基因组组装和注释数据.
* egaz command [long options]
  * template: create executing bash files.
    * egaz template [options] path/seqdir [more path/seqdir]
    * --multi：multiple genome alignments, orthologs(将)
    * -p/--parallel INT：number of threads(并行处理的线程数).
    * --order：multiple alignments with original order(using fake_tree.nwk)(按顺序组装输入文件中的序列).
    * -o/--outdir STR：Output directory(default value:.)(指定输出路径).

-----------------------------------------------------------------------
### rg
rg(ripgrep)
  * -F/--fixed-strings：Treat the pattern as a literal string instead of a regular expression. When this flag is used, special regular expression meta characters such as .(){}*+ do not need to be escaped(使用字符串而不是正则表达式进行匹配,特殊正则表达式元字符不需要转义).
  * -l/--files-with-matches：Print the paths with at least one match and suppress match contents(只显示文件名而不显示匹配行).



### Linux mount
mount:用于挂载
* mount [options] source directory
  * -a/--all:mount all filesystems mentioned in fstab(将/etc/fstab)
  * -o

### sync
* sync(synchronize):用于同步数据。




### Linux code
code:
* code.exe [options][paths]


### ls
ls(list files):用于显示指定工作目录下的内容.
* -l:use a long listing format(使用长格式显示当前目录中的文件和子目录).
* -a/--all：do not ignore entries starting with .(显示当前目录中的所有文件和子目录，包括隐藏文件).
* -h/--human-readable：with -l and -s, print sizes like 1K 234M 2G etc.
* -F/--classify：append indicator (one of */=>@|) to entries.

### mv
mv
* mv [OPTION] SOURCE DIRECTORY
* -t/--target-directory=DIRECTORY：move all SOURCE arguments into DIRECTORY.







> alias
> count
> cp
> chomd
> ssh
> cat(catenate)
> tldr
> jobs
> as
> dos2unix
> kill
> mkdir
> pigz
> ln
> set
> tail

