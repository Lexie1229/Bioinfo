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







### Linux tar
tar：
* tar [OPTION] [FILE]
  * -x, --extract, --get       extract files from an archive
  * -f, --file=ARCHIVE         use archive file or device ARCHIVE
jxvf





### Linux gzip
gzip：
* gzip [OPTION] [FILE]
  * -d：



### Linux pwd
pwd


### Linux mkdir

