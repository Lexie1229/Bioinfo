# Commands
## 目录
* [Linux commands](#linux-commands)
  * [Linux apt](#linux-apt)
  * [Linux basename](#linux-basename)
  * [Linux bc](#linux-bc)
  * [Linux bg](#linux-bg)
  * [Linux cp](#linux-cp)
  * [Linux cut](#linux-cut)
  * [Linux dirname](#linux-dirname)
  * [Linux fg](#linux-fg)
  * [Linux find](#linxu-find)
  * [Linux grep](#linux-grep)
  * [Linux gzip](#linux-gzip)
  * [Linux head](#linux-head)
  * [Linux jobs](#linux-jobs)
  * [Linux mktemp](#linux-mktemp)
  * [Linux nohup](#linxu-nohup)
  * [Linux paste](#linux-paste)
  * [Linux ps](#linux-ps)
  * [Linux pwd](#linux-pwd)
  * [Linux rm](#linux-rm)
  * [Linux rsync](#linux-rsync)
  * [Linux sed](#linux-sed)
  * [Linux shopt](#linux-shopt)
  * [Linux sort](#linux-sort)
  * [Linux split](#linux-split)
  * [Linux tar](#linux-tar)
  * [Linux tr](#linux-tr)
  * [Linux uniq](linux-uniq)
  * [Linux wc](linux-wc)
  * [Linux xargs](linux-xargs)
* [Other commands](#other-commands)
  * [aria2c](#aria2)
  * [bismark](#bismark)
  * [conda](#conda)
  * [echo](#echo)
  * [egaz](#egaz)
  * [fastqc](#fastqc)
  * [parallel](#parallel)
  * [samtools](#samtools)
  * [trim_galore](#trim_galore)
  * [datamash](#datamash)

## Linux commands

### [Linux apt](#linux-apt)
apt：是一个在Debian和Ubuntu中的Shell前端软件包管理器.
* apt [options] command
  * most used commands:
    * list：list packages based on package names(列出所有软件包).
    * search：search in package descriptions(搜索指定的软件包).
    * show：show package details(显示指定软件包的详细信息，包括依赖关系).
    * install：install packages(安装指定的软件包).
    * reinstall：reinstall packages(重新安装指定的软件包).
    * remove：remove packages(删除指定的软件包).
    * autoremove：Remove automatically all unused packages(自动删除所有未使用的包).
    * update：update list of available packages(列出所有可更新的软件列表).
    * upgrade：upgrade the system by installing/upgrading packages(升级系统).
    * full-upgrade：upgrade the system by removing/installing/upgrading packages(全面升级系统).
    * edit-sources：edit the source information file(编辑源信息文件).
    * satisfy：satisfy dependency strings(满足依赖关系).
  * -y：自动确认所有的提示和警告，避免安装过程中需要手动确认操作.

### [Linux basename](#linux-basename)
basename：用于返回路径中的文件名部分.
* basename OPTION NAME [SUFFIX]
  * -s/--suffix=SUFFIX：remove a trailing SUFFIX; implies -a(删除后缀).

### [Linux bc](#linux-bc)
bc(binary calculator)：用于任意精度的计算.
* bc [options] [file]
  * -l/--mathlib：use the predefined math routines(定义使用的标准数学库).

### [Linux bg](#linux-bg)
bg(background)：用于将后台暂停的工作恢复到后台执行.
* fg [job_spec]

### [Linux cp](#linux-cp)
cp(copy file)：用于复制文件或目录.
* cp [OPTION] SOURCE DIRECTORY
  * -S/--suffix=SUFFIX：override the usual backup suffix(覆盖通常使用的备份后缀，默认后缀为~).

### [Linux cut](#linux-cut)
cut：剪切文件中选定的行写至标准输出.
* cut OPTION [FILE]
  * -f/--fields=LIST:select only these fields(以区域为单位进行分割，仅显示选定的区域).
  * -b/--bytes=LIST:select only these bytes(以字节为单位进行分割，仅显示选定的字节).
  * -c/--characters=LIST:select only these characters(以字符为单位进行分割，仅显示选定的字符).
  * -d/--delimiter=DELIM：use DELIM instead of TAB for field delimiter(指定分隔符).

### [Linux dirname](#linux-dirname)
dirname：用于返回路径中的目录部分.
* dirname [OPTION] NAME
  * -z/--zero：end each output line with NUL, not newline(每行以NUL结束).

### [Linux fg](#linux-fg)
fg(foreground)：用于将后台暂停的工作恢复到前台执行.
* fg [job_spec]

### [Linux find](#linxu-find)
find：用于查找文件和目录.
* find [-H] [-L] [-P] [-Olevel] [-D debugopts] [path] [expression]
  * -maxdepth LEVELS：限制递归搜索深度，即指定搜索多少级子目录.
  * -type [bcdpflsD]：按文件类型搜索.
    * f：表示一般文件.
    * d：表示目录.
  * -name PATTERN：按文件名搜索.
  * -size N[bcwkMG]：按文件大小搜索.

### [Linux grep](#linux-grep)
grep：用于查找文件里符合条件的字符串.
* grep [OPTION] PATTERNS [FILE]
  * -i/--ignore-case:ignore case distinctions in patterns and data(忽略字符大小写的差别).
  * -q/--quiet, --silent: suppress(抑制) all normal output(不显示任何信息).
  * -v/--invert-match：select non-matching lines(反向查找，仅显示不匹配的行).
  * -x/--line-regexp：match only whole lines(精确匹配，匹配整行).
  * -r/--recursive：like --directories=recurse(递归查找子目录中的文件).
  * -A/--after-context=NUM：print NUM lines of trailing context(显示匹配行后的NUM行).

### [Linux gzip](#linux-gzip)
gzip：用于压缩或解压文件,扩展名为.gz.
* gzip [OPTION] [FILE]
  * -d/--decompress：decompress.
  * -c/--stdout:write on standard output, keep original files unchanged.
  * -f/--force:force overwrite of output file and compress links.

### [Linux head](#linux-head)
head:用于查看文件开头部分的内容.
* head [OPTION] [FILE]
  * -n/--lines=[-] NuM:print the first NUM lines instead of the first 10（显示前NUM行的内容）；with the leading '-', print all but the last NUM lines of each file(显示所有的内容，除后NUM行).
  * -c/--bytes=[-] NUM:print the first NUM bytes of each file(显示前NUM字节的内容);with the leading '-', print all but the last NUM bytes of each file.
  * -q/--quiet,--silent:never print headers giving file names(隐藏文件名).
  * -v/--verbose:always print headers giving file names(显示文件名).

### [Linux jobs](#linux-jobs)
jobs：用于显示当前终端的后台的工作状态.
* jobs [-lnprs] [jobspec] or jobs -x command [args]
  * -l：lists process IDs in addition to the normal information(显示进程的PID号).
  * -n：lists only processes that have changed status since the last notification(仅列出上次通知后状态改变的进程).
  * -p：lists process IDs only(仅列出进程的PID号).
  * -r：restrict output to running jobs(仅列出运行中的进程).
  * -s：restrict output to stopped jobs(仅列出已停止的进程).

### [Linux mktemp](#linux-mktemp)
mktemp：用于创建临时文件或目录，并打印文件名.
* mktemp [OPTION] [TEMPLATE]
  * -d/--directory：create a directory, not a file(创建一个临时目录，例如/tmp/tmp.WIZCU2vxne).
  * -t：interpret TEMPLATE as a single file name component,relative to a directory: $TMPDIR, if set; else the directory specified via -p; else /tmp [deprecated] (指定临时目录或文件的前缀，例如mytempdirXXX).

### [Linux nohup](#linxu-nohup)
nohup(no hang up):用于不挂断地运行命令，退出终端不影响运行.
* nohup COMMAND [ARG]
* 区别：
  * &：后台运行，关闭终端，任务终止，`Ctrl+C`，任务继续；前台接收标准输入，终止会丢失标准输出和标准错误信息；忽略SIGINT信号。
  * nohup：不挂断运行，关闭终端，任务继续，`Ctrl+C`，任务终止；关闭标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件；忽略SIGHUP信号。
  * nohup &：永久在后台执行，接受标准输入，重定向标准输出和标准错误到当前目录的nohup.out文件。

### [Linux paste](#linux-paste)
paste：用于将多个文件以列对列的形式合并，行数保持不变.
* paste [OPTION] [FILE]
  * -d/--delimiters=LIST：reuse characters from LIST instead of TABs(指定分隔符).
  * -s/--serial：paste one file at a time instead of in parallel(将所有输入文件合并成单个文件，并将所有行连接在一起).

### [Linux ps](#linux-ps)
ps(process status):用于显示当前进程的状态.
* ps [options]
  * -A/-e：all processes(显示所有进程).
  * -a：all with tty, except session leaders.
  * a：all with tty, including other users(显示所有进程，包括其他用户的进程).
  * u: user-oriented format(面向用户的格式).
  * x：processes without controlling ttys.

### [Linux pwd](#linux-pwd)
pwd(print work directory):用于显示当前工作目录.
* pwd [OPTION]
  * -P：print the physical directory, without any symbolic links(显示物理路径，而不带任何软链接).

### [Linux rm](#linux-rm)
rm(remove):用于删除一个文件或者目录.
* rm [option] [file]
  * rm filename:删除指定文件.
  * -r/-R,--recursive,递归:remove directories and their contents recursively(删除当前目录下的所有文件及目录).
  * -f/--force: ignore nonexistent files and arguments, never prompt(忽略不存在的文件和参数，从不提示).

### [Linux rsync](#linux-rsync)
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

### [Linux sed](#linux-sed)
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
  * -E/-r/--regexp-extended：use extended regular expressions in the script(for portability use POSIX -E)(使用扩展的正则表达式).

### [Linux shopt](#linux-shopt)
shopt(shell option)：用于显示或修改shell的选项设置.
* shopt [-pqsu] [-o] [optname]
  * shopt：Without any option arguments, list each supplied OPTNAME, or all shell options if no OPTNAMEs are given, with an indication of whether or not each is set(显示所有可以设置的shell操作选项).
  * -s：enable (set) each OPTNAME(启用OPTNAME).

### [Linux sort](#linux-sort)
sort:用于对文本文件的内容排序.
* sort [OPTION] [FILE]:读取文件内容，进行排序.
  * -n/--numeric-sort:compare according to string numerical value(根据字符串数值进行排序,从小到大).
  * -r/--reverse:reverse the result of comparisons(以相反的顺序排序,从大到小).
  * -k/--key=KEYDEF:sort via a key; KEYDEF gives location and type.KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position, where F is a field number and C a character position in the field; both are origin 1, and the stop position defaults to the line's end.(按指定的列进行排序).
    * 例如：-k 1.2，3.3  表示从第一个字段的第二个字符开始，到第三个字段的第三个字符结束进行排序.
  * -t/--field-separator=SEP:use SEP instead of non-blank to blank transition(指定排序时所用的栏位分隔字符).
* sort [OPTION]:读取标准输入，进行排序.

### [Linux split](#linux-split)
split:用于分割文件。
* split [OPTION] [FILE [PREFIX]]
  * -l/--lines=NUMBER：put NUMBER lines/records per output file(指定每个文件分割的行数).
  * -a/--suffix-length=N：generate suffixes of length N (default 2)(生成长度为N的后缀，默认值为2).
  * -d：use numeric suffixes starting at 0, not alphabetic(使用从0开始的数字后缀，而非字母).


### [Linux tar](#linux-tar)
tar(tape archive)：用于文件的打包压缩及解压.
* tar [OPTION] [FILE]
  * -x/--extract/--get：extract files from an archive(解压缩归档文件，从备份文件/存档中还原文件)。
  * -z/--gzip/--gunzip/--ungzip：filter the archive through gzip(通过gzip指令处理备份文件)。
  * -v/--verbose:verbosely list files processed(在操作过程中显示详细信息，详细列出已处理的文件,显示指令执行过程)。
  * -f/--file=ARCHIVE：use archive file or device ARCHIVE(指定要操作的归档文件，指定备份文件)。
  * -j/--bzip2:filter the archive through bzip2(通过bzip2指令处理备份文件)。

### [Linux tr](#linux-tr)
tr(text replacer)：用于转换或删除文件中的字符.
* tr [OPTION] SET1 [SET2]
  * [:blank:]：all horizontal whitespace(所有水平空格).
  * \n：new line(新行).

### [Linux uniq](linux-uniq)
uniq：用于检查及删除文本文件中重复出现的行列.
* uniq [OPTION] [INPUT [OUTPUT]]
  * -c/--count：prefix lines by the number of occurrences(在每行前面显示每个行出现的次数).
  * -d/--repeated：only print duplicate lines, one for each group(只显示重复的行).
  * -u/--unique：only print unique lines(只显示不重复的行).

### [Linux wc](linux-wc)
wc(word count):用于计算字数.
* wc [OPTION] [FILE]
  * wc filename：print newline, word, and byte counts for each FILE(显示行数、字数和字节数).
  * -l/lines：print the newline counts(显示行数).
  * -c/--bytes：print the byte counts(显示字节数).
  * -m/--chars：print the character counts(显示字符数).
  * -w/--words：print the word counts(显示字数).

### [Linux xargs](linux-xargs)
* xargs(eXtended ARGuments):用于构建和执行命令行命令,从标准输入或文件中读取一系列参数，将其转换为命令行参数.
  * xargs [OPTION] COMMAND [INITIAL-ARGS]
  * -I R：same as --replace=R.
  * -i/--replace[=R]:replace R in INITIAL-ARGS with names read from standard input, split at newlines;if R is unspecified, assume {}(将INITIAL-ARGS中的R替换为从标准输入读取的名称，在换行符处拆分;如果未指定R，则假设{}).

---------------------------------------------------------------------
## [Other commands](#other-commands)

### [aria2c](#aria2)
aria2c：用于从互联网下载文件，支持通过HTTP、HTTPS、FTP、SFTP、BitTorrent和Metalink协议下载文件.
* aria2c [OPTIONS] [URI | MAGNET | TORRENT_FILE | METALINK_FILE]
  * -d/--dir=DIR：The directory to store the downloaded file(指定下载文件的保存路径).
  * -Z/--force-sequential[=true|false]：Fetch URIs in the command-line sequentially and download each URI in a separate session, like the usual command-line download utilities(按顺序在命令行中获取URI，并在单独的会话中下载每个URI).

### [bismark](#bismark)
bismark：用于高效分析亚硫酸氢盐测序的数据.
* bismark [options] genome_folder {-1 mates1 -2 mates2 | singles}：用于将序列与指定的亚硫酸氢盐基因组比对.
  * -o/--output_dir dir：Write all output files into this directory. By default the output files will be written into the same folder as the input file(s)(指定输出目录).
  * --parallel/--multicore int：Sets the number of parallel instances of Bismark to be run concurrently(设置Bismark并行运行个数).
  * --genome_folder：The path to the folder containing the unmodified reference genome as well as the subfolders created by the Bismark_Genome_Preparation script (/Bisulfite_Genome/CT_conversion/ and /Bisulfite_Genome/GA_conversion/)(设置基因组文件夹的路径，包含未修改的参考基因组和亚硫酸氢盐处理生成的子目录的路径).
* bismark_genome_preparation [options] arguments：用于将参考基因组转换为两种不同的亚硫酸氢盐转化
版本(C->T，G->A)并为比对建立索引.
  * --bowtie2：This will create bisulfite indexes for use with Bowtie 2. Recommended for most bisulfite sequencing applications(建立用于Bowtie2的亚硫酸氢盐索引).
  * --hisat2：This will create bisulfite indexes for use with HISAT2. This is recommended for specialist applications such as RNA methylation analyses or SLAM-seq type applications(建立用于Hisat2的亚硫酸氢盐索引).
  * --parallel INT：Use several threads for each indexing process to speed up the genome preparation step. Remember that the indexing is run twice in parallel already (for the top and bottom strand separately)(每个索引使用多个线程，加快基因组索引过程，索引默认分别针对顶部链和底部链并行运行两次).
* deduplicate_bismark [options] filename(s)：用于从Bismark比对结果中删除比对到基因组中相同位置的比对.
  * --bam：The output will be written out in BAM format(结果输出BAM格式文件).
  * --output_dir [path]：Output directory, either relative or absolute. Output is written to the current directory if not specified explicitly(指定输出目录).
* bismark_methylation_extractor [options] filenames：用于提取单个胞嘧啶的甲基化信息.
  * -s/--single-end: Input file(s) are Bismark result file(s) generated from single-end read data(输入由单端测序数据生成的Bismark结果文件).
  * --gzip:The methylation extractor files (CpG_OT_..., CpG_OB_... etc) will be written out in a GZIP compressed form to save disk space. This option is also passed on to the genome-wide cytosine report. BedGraph and coverage files will be written out as .gz by default(甲基化提取文件(CpG_OT_...，CpG_OB_... etc)以GZIP压缩形式输出以节省磁盘空间，包括全基因组胞嘧啶甲基化报告、BedGraph和coverage文件).
  * --parallel/--multicore int：Sets the number of cores to be used for the methylation extraction process. Please note that a typical process of extracting a BAM file and writing out '.gz' output streams will in fact use ~3 cores per value of --parallel int specified (1 for the methylation extractor itself, 1 for a Samtools stream, 1 for GZIP stream)(设置甲基化提取过程使用的内核数，实际每次提取BAM文件并写入.gz文件的过程约使用3核，因此设置使用N int而实际使用3N int资源).
  * --bedGraph：After finishing the methylation extraction, the methylation output is written into a sorted bedGraph file that reports the position of a given cytosine and its methylation state (in %, see details below)(甲基化输出写入排序的bedGraph文件，提供胞嘧啶的位置及其甲基化状态).
  * --cytosine_report：After the conversion to bedGraph has completed, the option '--cytosine_report' produces a genome-wide methylation report for all cytosines in the genome(bedGraph转换完成后，生成全基因组所有胞嘧啶甲基化报告).
  * --genome_folder path：Enter the genome folder you wish to use to extract sequences from (full path only)(指定用于甲基化提取的基因组的路径，只能全路径).
  * -o/--output_dir DIR: Allows specification of a different output directory (absolute or relative path)(指定输出目录).

### [conda](#conda)
conda:用于管理和部署应用程序、环境和软件包的工具.
* conda [-h] [-V] command
  * conda config：Modify configuration values in .condarc(修改.condarc文件中的配置值).
    * --add channels conda-canary：Add the conda-canary channel(添加软件源，具有优先级).
  * conda create：Create a new conda environment from a list of specified packages(创建新的conda环境).
    * -n ENVIRONMET (--name ENVIRONMENT)：Name of environment(设置环境名称).
  * conda info：Display information about current conda install(显示当前conda安装的信息).

### [echo](#echo)
echo：用于输出字符串.
* echo [-neE] [ARGUMENTS]
  * -e：启用转义字符的解释.
  * -n：不输出结尾的换行符.

### [egaz](#egaz)
egaz(Easy Genome Aligner)：用于处理基因组组装和注释数据.
* egaz command [long options]
  * template: create executing bash files(创建正在执行的bash文件).
    * egaz template [options] path/seqdir [more path/seqdir]
    * --multi：multiple genome alignments, orthologs(将多基因组比对，直系同源物).
    * -p/--parallel INT：number of threads(并行处理的线程数).
    * --order：multiple alignments with original order(using fake_tree.nwk)(按顺序组装输入文件中的序列).
    * -o/--outdir STR：Output directory(default value:.)(指定输出路径).

### [fastqc](#fastqc)
fastqc：用于质量控制和评估高通量测序数据.
* fastqc [-o output dir] [--(no)extract] [-f fastq|bam|sam] [-c contaminant file] seqfile1 .. seqfileN
  * -o/--outdir：Create all output files in the specified output directory(指定输出目录).
  * -t/--threads：Specifies the number of files which can be processed simultaneously(指定可以同时处理的文件数).

### [parallel](#parallel)
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

### [samtools](#samtools)
samtools：用于操作SAM和BAM文件，包括二进制查看、格式转换、排序及合并等.
* samtools command [options]
  * cat：concatenate BAMs(连接BAMs文件).
    * samtools cat [options] in1.bam [... inN.bam]
    * -o FILE：output BAM/CRAM(指定输出的文件类型为BAM/CRAM).
    * -@/--threads INT：Number of additional threads to use [0](指定额外使用的线程数).
  * sort：sort alignment file(对比对文件进行排序)
    * samtools sort [options] [in.bam]
    * -@/--threads INT：Number of additional threads to use [0](指定额外使用的线程数).
  * index：index alignment(对比对文件建立索引)
    * samtools index [-bc] [-m INT] in.bam [out.index]
    * -b：Generate BAI-format index for BAM files[default](为BAM文件生成BAI格式索引).
    * -@ INT：Sets the number of threads [none](指定使用的线程数).

### [trim_galore](#trim_galore)
trim_galore：用于预处理高通量测序数据，包括质量控制、去除低质量序列、去除接头序列和寡聚核苷酸等.
* trim_galore [options] filename(s)
  * -o/--output_dir DIR：If specified all output will be written to this directory instead of the current directory. If the directory doesn't exist it will be created for you(指定所有输出写入特定的目录而不是当前目录，如果指定的目录不存在，则自动新建).
  * --fastqc：Run FastQC in the default mode on the FastQ file once trimming is complete(修剪完成后，在FastQ文件的默认模式下运行FastQC).

### [datamash](#datamash)
datamash：用于对文本文件中的数据进行处理和统计分析.
* datamash [OPTION] op [fld] [op fld]
  * op：the operation to perform.
    * Primary operations：基础操作
      * groupby：根据指定列进行分组.
      * crosstab：生成交叉表格.
      * transpose：转置行和列.
      * reverse：
      * check：检查数据是否符合要求.
    * Numeric Grouping operations：
      * sum：sum(计算总和).
      * min：minimum(找到最小值).
      * max：maximum(找到最大值).
      * absmin
      * absmax
      * range：range(计算值域).
    * Line-Filtering operations：rmdup.
    * Per-Line operations：
      * base64, debase64, md5, sha1, sha224, sha256, sha384, sha512, bin, strbin, round, floor, ceil, trunc, frac, dirname, basename, barename, extname, getnum
      * cut：提取指定的列.
    * Textual/Numeric Grouping operations：
      * count(计算行数), first, last, rand, unique,
      * collapse：将一列多行数据合并成一行.
      countunique.
    * Statistical Grouping operations：统计分组操作
      * mean：mean(计算平均值).
      * geomean
      * harmmean
      * trimmean, median, q1, q3, iqr, perc, mode, antimode, pstdev, sstdev, pvar, svar, ms, rms,
      * mad：mean absolute deviation(计算平均绝对离差).
        madraw, pskew, sskew, pkurt, skurt, dpo, jarque, scov, pcov, spearson, ppearson.
  * --header-in：first input line is column headers(输入首行是为列标题).
  * --header-out：print column headers as first line(将列标题打印为首行).
  * -H/--headers；same as '--header-in --header-out'.
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
* ls [OPTION] [FILE]
  * -l：use a long listing format(使用长格式显示当前目录中的文件和子目录).
  * -a/--all：do not ignore entries starting with . (显示当前目录中的所有文件和子目录，包括隐藏文件).
  * -h/--human-readable：with -l and -s, print sizes like 1K 234M 2G etc.
  * -F/--classify：append indicator (one of */=>@|) to entries.

### mv
mv
* mv [OPTION] SOURCE DIRECTORY
  * -t/--target-directory=DIRECTORY：move all SOURCE arguments into DIRECTORY.






### bowtie

### hista



> count
> chomd
> ssh
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
> sh
> gunzip -d
> test -d
> curl -fsSL
> bash -c
> wget -O

Linux:   
man
ls
cd
pwd
mkdir
rmdir
mv
cp
open
touch
find
ln
gzip
gunzip
tar
alias
cat(catenate)
less




awk
anchor