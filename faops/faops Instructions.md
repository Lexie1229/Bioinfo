# [`faops` 使用说明](https://github.com/wang-q/faops)

## 安装 faops

```bash
# 使用brew安装
brew install wang-q/tap/faops
```

```shell
# compiling 编译
git clone https://github.com/wang-q/faops
cd faops
make
```

## 使用 faops

* faops：用于处理fasta格式的测序数据.

```bash
faops <command> [options] <arguments>

# 举例
faops filter -l 0 <in.fq> <out.fa>
## 每条序列的碱基写入一行(例如>read12所示区别)，并将fastq格式转变为fasta格式
## >read12
## AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaAgacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCaGCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAgacgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGCtGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCTgtTACctCtagGTAGaGggcTaaatCca
## >read12
## AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaA
## gacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCa
## GCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAg
## acgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGC
## tGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCT
## gtTACctCtagGTAGaGggcTaaatCca
```

### 01.faops count

* faops count：count base statistics in FA file(s).
    * faops count <in.fa> [more_files.fa]  计算FA文件中每个reads的碱基组成(len、A、T、G、C、N)

```bash
# read from file
faops count ~/test/ufasta.fa | head -n 2
# #seq    len     A       C       G       T       N
# read0   359     99      89      92      79      0

# read from gzipped file
faops count ~/test/ufasta.fa.gz | head -n 2
# #seq    len     A       C       G       T       N
# read0   359     99      89      92      79      0

# read from stdin
cat ~/test/ufasta.fa | faops count stdin | head -n 2
# #seq    len     A       C       G       T       N
# read0   359     99      89      92      79      0

# lines of result
faops count ~/test/ufasta.fa | wc -l
# 52
## 行数包含标题行和汇总行
## #seq    len     A       C       G       T       N
## ……
## total   9317    2318    2305    2373    2321    0

# mixture of stdin and actual file
cat ~/test/ufasta.fa | faops count stdin ~/test/ufasta.fa | wc -l
# 102

# sum of sizes
faops count ~/test/ufasta.fa | perl -ne '/^total\t(\d+)/ and print "$1\n"'
# 9317
## (\d+)表示匹配一个或多个数字，并将捕获值储存在$1中
```

### 02.faops size

* faops size：count total bases in FA file(s).
    * faops size <in.fa> [more_files.fa]  计算FA文件中每个reads的碱基数

```bash
# read from file
faops size ~/test/ufasta.fa | head -n 2
# read0   359
# read1   106

# read from gzipped file
faops size ~/test/ufasta.fa.gz | head -n 2
# read0   359
# read1   106

# read from stdin
cat ~/test/ufasta.fa | faops size stdin | head -n 2
# read0   359
# read1   106

# lines of result
faops size ~/test/ufasta.fa | wc -l
# 50

# mixture of stdin and actual file
cat ~/test/ufasta.fa | faops size stdin ~/test/ufasta.fa | wc -l
# 100

# sum of sizes
faops size ~/test/ufasta.fa | perl -ane '$c += $F[1]; END { print qq{$c\n} }'
# 9317
## qq{}表示""
```

### 03.faops frag

* faops frag：extract sub-sequences(a piece of DNA) from a FA file.
    * faops frag [options] <in.fa> <start> <end> <out.fa>  从FA文件中提取子序列
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# from first sequence
faops frag ~/test/ufasta.fa 1 10 stdout | grep -v "^>"
# tCGTTTAACC
## faops frag ~/test/ufasta.fa 1 10 stdout
## >read0:1-10
## tCGTTTAACC

# from specified sequence
faops some ~/test/ufasta.fa <(echo read12) stdout | faops frag stdin 1 10 stdout | grep -v "^>"
# AGCgCcccaa
```

### 04.faops rc

* faops rc：reverse complement a FA file.
    * faops rc [options] <in.fa> <out.fa>  将FA文件中的序列反向互补
    * -n: keep name identical (don't prepend RC_)(保持序列名称不变，序列名称无前置RC_).
    * -r: just Reverse, prepends R_ (仅反向，序列名称前置R_).
    * -c: just Complement, prepends C_ (仅互补，序列名称前置C_).
    * -f STR: only RC sequences in this list.file(仅处理list.file中的序列). 
    * -l INT: sequence line length [80] (序列每行显示INT个碱基).

```bash
# output same length
faops rc -n ~/test/ufasta.fa stdout | faops size stdin
faops size ~/test/ufasta.fa
# read0   359
# read1   106
# ……

# double rc
faops rc -n ~/test/ufasta.fa stdout | faops rc -n stdin stdout
faops filter ~/test/ufasta.fa stdout
# >read0
# tCGTTTAACCCAAatcAAGGCaatACAggtGggCCGccCatgTcAcAAActcgatGAGtgGgaAaTGgAgTgaAGcaGCA
# tCtGctgaGCCCCATTctctAgCggaaaATGgtatCGaACcGagataAGtTAAacCgcaaCgGAtaagGgGcgGGctTCA
# aGtGAaGGaAGaGgGgTTcAaaAgGccCgtcGtCaaTcAaCtAAggcGgaTGtGACactCCCCtAtTtcaaGTCTTctaC
# ccTtGaTaCGaTtcgCGTtcGaGGaGcTACaTTAaccaaGtTaatgCGAGCGcCtgCGaAcTTGccAAgTCaGCtgctCT
# gttCtcAggTaCAcAaGTcagccAtTGTGTCGaCGCTCT
# >read1
# taGGCGcGGgCggtgTgGATTAaggCAGaggtTgCGCGCtTgaTAaAACTacgtaACatcggGAAcTtcgaccGgtCTCg
# GccCtatAtgaTtCcGatcGCaTaTC
# ……

# double rc (gz)
faops rc -n ~/test/ufasta.fa.gz stdout | faops rc -n stdin stdout
faops filter ~/test/ufasta.fa stdout
# >read0
# tCGTTTAACCCAAatcAAGGCaatACAggtGggCCGccCatgTcAcAAActcgatGAGtgGgaAaTGgAgTgaAGcaGCA
# tCtGctgaGCCCCATTctctAgCggaaaATGgtatCGaACcGagataAGtTAAacCgcaaCgGAtaagGgGcgGGctTCA
# aGtGAaGGaAGaGgGgTTcAaaAgGccCgtcGtCaaTcAaCtAAggcGgaTGtGACactCCCCtAtTtcaaGTCTTctaC
# ccTtGaTaCGaTtcgCGTtcGaGGaGcTACaTTAaccaaGtTaatgCGAGCGcCtgCGaAcTTGccAAgTCaGCtgctCT
# gttCtcAggTaCAcAaGTcagccAtTGTGTCGaCGCTCT
# >read1
# taGGCGcGGgCggtgTgGATTAaggCAGaggtTgCGCGCtTgaTAaAACTacgtaACatcggGAAcTtcgaccGgtCTCg
# GccCtatAtgaTtCcGatcGCaTaTC
# ……

# perl regex
paste <(faops rc -l 0 ~/test/ufasta.fa stdout | grep -v '^>')\
    <(faops filter -l 0 ~/test/ufasta.fa stdout | grep -v '^>')\
    | perl -ane '
        $F[0] = uc($F[0]);
        $F[1] =~ tr/ACGTacgt/TGCATGCA/;
        $F[1] = reverse($F[1]);
        exit(1) unless $F[0] eq $F[1];
     '
echo $？
## 测试是否反向互补，即反转后是否一致
## $uc_str = uc($str)，用于将字符串转换为大写(perl函数)
## $str =~ tr/hw/HW，用于对字符串中的字符进行替换或删除，hw表示要替换或删除的字符集，HW表示替换或删除后的字符集(perl函数)
## $rev_str = reverse($str)，用于反转一个字符串或者一个列表中的元素顺序(perl函数)
## $F[0] = cccagTt
## $F[1] = aActggg
## $F[0] = uc($F[0]) --> $F[0] = CCCAGTT
## $F[1] =~ tr/ACGTacgt/TGCATGCA/ --> $F[1] =TTGACCC
## $F[1] = reverse($F[1]) --> $F[1] = CCCAGTT
## echo $？显示上一个命令的状态，0表示执行成功

# with list.file
faops rc -l 0 -f <(echo read47) ~/test/ufasta.fa stdout | grep '^>RC_'
# >RC_read47
```

### 05.faops one

* faops one：extract one fa sequence.
    * faops one [options] <in.fa> <name> <out.fa>  提取一个fa序列
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# inline names
faops one -l 0 ~/test/ufasta.fa read12 stdout
faops filter -l 0 ~/test/ufasta.fa stdout | grep -A 1 '^>read12'
# >read12
# AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaAgacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCaGCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAgacgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGCtGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCTgtTACctCtagGTAGaGggcTaaatCca
```

### 06.faops some

* faops some：extract multiple fa sequences.
    * faops some [options] <in.fa> <list.file> <out.fa>  提取多个fa序列  
    * -i: invert, output sequences not in the list(反转,即输出不在list中的序列).
    * -l INT: sequence line length [80] (序列每行显示INT个碱基).

```bash
# inline names
faops some -l 0 ~/test/ufasta.fa <(echo read12) stdout
faops filter -l 0 ~/test/ufasta.fa stdout | grep -A 1 '^>read12'
# >read12
# AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaAgacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCaGCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAgacgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGCtGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCTgtTACctCtagGTAGaGggcTaaatCca

# exclude
faops some -i ~/test/ufasta.fa <(echo read12) stdout | grep '^>' | wc -l
# 49
```

### 07.faops filter

* faops filter：filter fa records. 
    * faops filter [options] <in.fa> <out.fa>  按照条件筛选序列
    * -a INT：pass sequences at least this big ('a'-smallest)(保留碱基数大于等于INT的序列).
    * -z INT：pass sequences this size or smaller ('z'-biggest)(保留碱基数小于等于INT的序列).
    * -n INT：pass sequences with fewer than this number of N's(保留'N'的数量小于INT的序列).
    * -u：unique, removes duplicated ids, keeping the first(删除重复id的序列，仅保留第一次出现的序列).
    * -U：upper case, converts all sequences to upper cases(将所有序列的碱基转换为大写).
    * -b：pretend to be a blocked fasta file(假装成一个封闭的fasta文件，即将每条序列的碱基写入一行并在每条序列间插入空行).
    * -N：convert IUPAC ambiguous codes to 'N'(将IUPAC不确定的代码转换为'N').
    * -d：remove dashes '-'(删除破折号).
    * -s：simplify sequence names(简化序列名称).
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# as formatter, sequence in one line
faops filter -l 0 ~/test/ufasta.fa stdout | wc -l
# 100
faops size ~/test/ufasta.fa | wc -l
# 50

# as formatter, blocked fasta files
faops filter -b ~/test/ufasta.fa stdout | wc -l
# 150
faops size ~/test/ufasta.fa | wc -l
# 50

# as formatter, identical headers
faops filter -l 0 ~/test/ufasta.fa stdout | grep '^>'
grep '^>' ~/test/ufasta.fa
# >read0
# >read1
# >read2
# >read3
# >read4
# >read5
# ……

# as formatter, identical sequences
faops filter -l 0 ~/test/ufasta.fa stdout | grep -v '^>' | perl -ne 'chomp; print'
grep -v '^>' ~/test/ufasta.fa | perl -ne 'chomp; print'
# tCGTTTAACCCAAatcAAGGCaatACAggtGggCCGccCatgTcAcAAActcgatGAGtgGgaAaTGgAgTgaAGcaGCAtCtGctgaGCCCCATTctctAgCggaaaATGgtatCGaACcGagataAGtTAAacCgcaaCgGAtaagGgGcgGGctTCAaGtGAaGGaAGaGgGgTTcAaaAgGccCgtcGtCaaTcAaCtAAggcGgaTGtGACactCCCCtAtTtcaaGTCTTctaCccTtGaTaCGaTtcgCGT……

# as formatter, identical sequences (gz)
faops filter -l 0 ~/test/ufasta.fa.gz stdout | grep -v '^>' | perl -ne 'chomp; print'
grep -v '^>' ~/test/ufasta.fa | perl -ne 'chomp; print'
# tCGTTTAACCCAAatcAAGGCaatACAggtGggCCGccCatgTcAcAAActcgatGAGtgGgaAaTGgAgTgaAGcaGCAtCtGctgaGCCCCATTctctAgCggaaaATGgtatCGaACcGagataAGtTAAacCgcaaCgGAtaagGgGcgGGctTCAaGtGAaGGaAGaGgGgTTcAaaAgGccCgtcGtCaaTcAaCtAAggcGgaTGtGACactCCCCtAtTtcaaGTCTTctaCccTtGaTaCGaTtcgCGT……

# identical sequences (gz) with -N
faops filter -l 0 -N ~/test/ufasta.fa.gz stdout | grep -v '^>' | perl -ne 'chomp; print'
grep -v '^>' ~/test/ufasta.fa | perl -ne 'chomp; print'
# tCGTTTAACCCAAatcAAGGCaatACAggtGggCCGccCatgTcAcAAActcgatGAGtgGgaAaTGgAgTgaAGcaGCAtCtGctgaGCCCCATTctctAgCggaaaATGgtatCGaACcGagataAGtTAAacCgcaaCgGAtaagGgGcgGGctTCAaGtGAaGGaAGaGgGgTTcAaaAgGccCgtcGtCaaTcAaCtAAggcGgaTGtGACactCCCCtAtTtcaaGTCTTctaCccTtGaTaCGaTtcgCGT……

# convert IUPAC to N
faops filter -l 0 -N <(printf ">read\n%s\n" AMRG) stdout
printf ">read\n%s\n" ANNG
# >read
# ANNG

# remove dashes
faops filter -l 0 -d <(printf ">read\n%s\n" A-RG) stdout
printf ">read\n%s\n" ARG
# >read
# ARG

# Upper cases
faops filter -l 0 -U <(printf ">read\n%s\n" AtcG) stdout
printf ">read\n%s\n" ATCG
# >read
# ATCG

# simplify seq names
faops filter -l 0 -s <(printf ">read.1\n%s\n" ANNG) stdout
printf ">read\n%s\n" ANNG
# >read
# ANNG

# fastq to fasta
faops filter ~/test/test.seq stdout | wc -l
# 6

# minsize
faops filter -a 10 ~/test/ufasta.fa stdout | grep '^>' | wc -l
# 44

# maxsize
faops filter -a 1 -z 50 ~/test/ufasta.fa stdout | grep '^>'
# >read20
# >read30
# >read31
# >read36
# >read42
# >read43
# >read46

# minsize maxsize
faops filter -a 10 -z 50 ~/test/ufasta.fa stdout | grep '^>'
# >read20
# >read30
# >read31
# >read42
# >read43
# >read46

# uniq
faops filter -u -a 1 <(cat ~/test/ufasta.fa ~/test/ufasta.fa) stdout | grep '^>' | wc -l
# 45
```

### 08.faops split-name

* faops split-name：splitting by sequence names(split an fa file into several files，using sequence names as file names).
    * faops split-name [options] <in.fa> <outdir>  根据序列名称拆分FA文件
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# all sequences
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops split-name ~/test/ufasta.fa $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 50
rm -fr ${mytmpdir}
## echo ${mytmpdir}
## /tmp/tmp.**********
## mktemp 指定前缀时需要有足够多的XXXXXX，以确保生成的文件名或目录名足够唯一

# size restrict
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops filter -a 10 ~/test/ufasta.fa stdout \
| faops split-name stdin $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 44
rm -fr ${mytmpdir}
```

### 09.faops split-about

* faops split-about：splitting to chunks about specified size(Split an fa file into several files of about approx_size bytes each by record)
    * faops split-about [options] <in.fa> <approx_size> <outdir>  根据序列大小拆分FA文件
    * -e：sequences in one file should be EVEN(每个文件中的序列数是偶数，即成对的).
    * -m INT：max parts(最多拆分INT个模块).
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# 2000 bp
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops split-about ~/test/ufasta.fa 2000 $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 5
rm -fr ${mytmpdir}

# max parts
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops split-about -m 2 ~/test/ufasta.fa 2000 $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 2
rm -fr ${mytmpdir}

# 2000 bp and size restrict
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops filter -a 100 ~/test/ufasta.fa stdout \
| faops split-about stdin 2000 $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 4
rm -fr ${mytmpdir}

# 1 bp
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops split-about  ~/test/ufasta.fa 1 $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 50
rm -fr ${mytmpdir}

# 1 bp even
mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdirXXXXXX')
faops split-about -e ~/test/ufasta.fa 1 $mytmpdir \
&& find $mytmpdir -name '*.fa' | wc -l
# 26
rm -fr ${mytmpdir}
```

### 10.faops n50

* faops n50：compute N50 and other statistics.
    * faops n50 [options] <in.fa> [more_files.fa] 计算n50和其他数据
    * -H：do not display header(不显示标题，即不显示N50等).
    * -N INT：compute Nx statistic [50] (计算N[INT]).
    * -S：compute sum of size of all entries(计算所有序列的总碱基数).
    * -A：compute average length of all entries(计算所有序列的平均碱基数).
    * -E：compute the E-size (from GAGE)(计算E-size).
    * -C：count entries(计算序列条数).
    * -g INT：size of genome, instead of total size in files(基于INT大小的基因组，预测n50等).

```bash
# display header
faops n50 ~/test/ufasta.fa
# N50     314

# don't display header
faops n50 -H ~/test/ufasta.fa
# 314

# set genome size (NG50)
faops n50 -H -g 10000 ~/test/ufasta.fa
# 297

# sum of size
faops n50 -H -S ~/test/ufasta.fa
# 314
# 9317

# sum and average of size
faops n50 -H -S -A ~/test/ufasta.fa
# 314
# 9317
# 186.34

# E-size
faops n50 -H -E ~/test/ufasta.fa
# 314
# 314.70

# n10
faops n50 -H -N 10 ~/test/ufasta.fa
# 516

# n90 with header
faops n50 -N 90 ~/test/ufasta.fa
# N90     112

# only count of sequences
faops n50 -N 0 -C ~/test/ufasta.fa
# C       50

# calculate N50 values for a two column file
faops size ~/test/ufasta.fa | perl ~/test/n50.pl stdin
# #       reading: stdin
# #       contig count: 50, total size: 9317, one half size: 4658
# # cumulative    N50 count       contig  contig size
# 4417    10      read49  358
# 4658 one half size
# 4731    11      read39  314
```

### 11.faops order

* faops order：extract some(multiple) fa records by the given order.
    * faops order [options] <in.fa> <list.file> <out.fa> 按给定顺序提取多个序列  
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# inline names
faops order -l 0 ~/test/ufasta.fa <(echo read12) stdout
faops filter -l 0 ~/test/ufasta.fa stdout | grep -A 1 '^>read12'
# >read12
# AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaAgacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCaGCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAgacgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGCtGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCTgtTACctCtagGTAGaGggcTaaatCca

# correct orders
faops order -l 0 ~/test/ufasta.fa <(echo read12 read5) stdout
faops filter -l 0 ~/test/ufasta.fa stdout | grep -A 1 -e '^>read12'
faops filter -l 0 ~/test/ufasta.fa stdout | grep -A 1 -e '^>read5'
# >read12
# AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaAgacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCaGCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAgacgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGCtGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCTgtTACctCtagGTAGaGggcTaaatCca
# >read5
# AatcccAgAttcttCcTaTAGgGTagTaAcgcggTgGAgCTGCagAGGTaAgccGtcgGaGGGgagGcAagtGCCggtTGcGAGtcCaTgCcTtCAGgccCtcGCgCTgAcCCtaCgtTtAAaTacAggGttggTccTcaAgcGtcTTCGAtGcTcTaggAGGgaGcCTGgcTAaCTGttCTtGatTGtCgATTtCgAaggAGattagcTTgccg

# compare with some
faops order ~/test/ufasta.fa <(faops size ~/test/ufasta.fa | sort -n -r -k2,2 | cut -f 1) stdout | grep '^>'
faops some ~/test/ufasta.fa <(faops size ~/test/ufasta.fa | sort -n -r -k2,2 | cut -f 1) stdout | grep '^>'
# >read28
# >read13
# >read18
# >read41
# >read14
# ……
```

### 12.faops replace

* faops replace：replace headers from a FA file.
    * faops replace [options] <in.fa> <replace.tsv> <out.fa>  替换FA文件的序列标题
    * <replace.tsv>格式：original_name  replace_name
    * -s：only output sequences in the list, like `faops some`(仅输出list中的序列).
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
## create replace.tsv
faops size ~/test/ufasta.fa | perl -nl -e "/\s+0$/ or print" > ~/test/replace.tsv

# inline names
faops replace ~/test/ufasta.fa <(printf "%s\t%s\n" read12 428) stdout | grep '^>428'
# >428

# -s
faops replace -s ~/test/ufasta.fa <(printf "%s\t%s\n" read12 428) stdout
# >428
# AGCgCcccaaaaGGaTgCGTGttagaCACTAAgTtCcAtGgctGTatccTtgTgtcACagcGTGaaCCCAaTAagatCaA
# gacTCCGCcCAcCTAttagccaGcCGtCtGcccCacCaGgGgcTtAtaAGAGgaGGCtttCtaGGTcCcACTtGgggTCa
# GCCcccaTGCgTGGtCtGTGTcCatgTCCtCCTCTaGCaCCCCTCgCAgctCCtAataCgAAGGaGCAtcaCAgGacgAg
# acgAcAtTcTcCaACcgtGGctCgGTCGGaCCcCGTAAcATTgCGgcAaAtGagCTaTtagGGATCGacTatgatCcGGC
# tGagtgAgaAtAtgGAcCtATcGtggGAgCACCtAtagTtcTaTAGGacgGgcAtcTCGCGcCaaggGcTggGaTTgTCT
# gtTACctCtagGTAGaGggcTaaatCca

# with replace.tsv
faops replace ~/test/ufasta.fa ~/test/replace.tsv stdout | grep '^>' | grep -v 'read' | sed 's/>//'
cat ~/test/replace.tsv | cut -f 2
# 359
# 106
# 217
# 73
# 76
# ……
```

### 13.faops dazz

* faops dazz：rename records for dazz_db.
    * faops dazz [options] <in.fa> <out.fa>  重命名序列名称，标准化为>read/50/0_358
    * -p STR：prefix of names [read] (指定前缀名称，默认为read，>STR/1/0_359).
    * -s INT：start index [1] (指定开始的索引值，默认为1，>read/INT/0_359).
    * -a：don't drop duplicated ids(保留重复id的序列).
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# empty seqs count
faops dazz -a ~/test/ufasta.fa stdout | grep "0_0" | wc -l
faops size ~/test/ufasta.fa | grep "\s0" | wc -l
# 5

# deduplicate seqs
gzip -dcf ~/test/ufasta.fa ~/test/ufasta.fa.gz | faops dazz stdin stdout | grep "0_0" | wc -l
# 5
faops size ~/test/ufasta.fa ~/test/ufasta.fa.gz | grep "\s0" | wc -l
# 10

# duplicated seqs
gzip -dcf ~/test/ufasta.fa ~/test/ufasta.fa.gz | faops dazz -a stdin stdout | grep "0_0" | wc -l
faops size ~/test/ufasta.fa ~/test/ufasta.fa.gz | grep "\s0" | wc -l
# 10
```

### 14.faops interleave

* faops interleave：interleave two PE files.
    * faops interleave [options] <R1.fa> [R2.fa]  合并两个测序文件
    * -q：write FQ，the inputs must be FQs(输出fastq格式文件).
    * -p STR：prefix of names [read] (指定前缀名称，默认为read，>STR1/2).
    * -s INT：start index [0] (指定开始的索引值，默认为0，>readINT/1).

```bash
# empty seqs count
faops interleave ~/test/ufasta.fa ~/test/ufasta.fa.gz | grep "^$" | wc -l
# 10
faops size ~/test/ufasta.fa | grep "\s0" | wc -l
# 5
## "^$" 表示匹配空行

# empty seqs count (single)
faops interleave ~/test/ufasta.fa | grep "^$" | wc -l
faops size ~/test/ufasta.fa | grep "\s0" | wc -l
# 5

# fq
faops interleave -q ~/test//R1.fq.gz ~/test//R2.fq.gz | grep '^!$' | wc -l
# 0
## "^$" 表示匹配"!"，FASTQ文件中，以"!"开头和结尾的行表示无效的质量分数记录

# fq (single)
faops interleave -q ~/test//R1.fq.gz | grep '^!$' | wc -l
# 25
```

### 15.faops region

* faops region：extract regions from a FA file.
    * faops region [options] <in.fa> <region.txt> <out.fa>  提取FA文件中序列的部分区域
    * <region.txt>格式：seq_name:begin-end[,begin-end]
    * -s：add strand '(+)' to headers(将链 '(+)' 添加到序列名称中).
    * -l INT：sequence line length [80] (序列每行显示INT个碱基).

```bash
# from file
faops region -l 0 ~/test/ufasta.fa ~/test/region.txt stdout | wc -l
# 4
cat ~/test/region.txt | wc -l
# 2

# frag
faops region -l 0 ~/test/ufasta.fa <(echo read0:1-10) stdout
faops frag ~/test/ufasta.fa 1 10 stdout
# >read0:1-10
# tCGTTTAACC

# 1 base
faops region -l 0 ~/test/ufasta.fa <(echo read0:10) stdout
faops frag ~/test/ufasta.fa 10 10 stdout
# >read0:10
# C

# strand
faops region -s -l 0 ~/test/ufasta.fa <(echo read0:10) stdout
# >read0(+):10
# C

# regions
faops region -l 0 ~/test/ufasta.fa <(echo read1:1-10,50-60) stdout
# >read1:1-10
# taGGCGcGGg
# >read1:50-60
# TacgtaACatc
```

### 16.faops masked

* faops masked：masked (or gaps) regions in FA file(s).
    * faops masked [options] <in.fa> [more_files.fa] 屏蔽(或跳过)FA文件中的区域，即依次显示每条序列小写的区域
    * -g：only record regions of N/n(仅保留N/n区域).

```bash
# masked
faops masked ~/test/ufasta.fa | grep '^read46' | head -n 1
# read46:3-4

# masked
faops masked ~/test/ufasta.fa | grep '^read0' | head -n 1
# read0:1
```

### 17.faops help

* faops masked：print this message.

```bash
# help
faops help
```

```txt
Usage:     faops <command> [options] <arguments>
Version:   0.8.21

Commands:
    help          print this message
    count         count base statistics in FA file(s)
    size          count total bases in FA file(s)
    masked        masked (or gaps) regions in FA file(s)
    frag          extract sub-sequences from a FA file
    rc            reverse complement a FA file
    one           extract one fa record
    some          extract some fa records
    order         extract some fa records by the given order
    replace       replace headers from a FA file
    filter        filter fa records
    split-name    splitting by sequence names
    split-about   splitting to chunks about specified size
    n50           compute N50 and other statistics
    dazz          rename records for dazz_db
    interleave    interleave two PE files
    region        extract regions from a FA file

Options:
    There're no global options.
    Type "faops command-name" for detailed options of each command.
    Options *MUST* be placed just after command.
```

## Examples

```bash
# Reverse complement 反向互补
faops rc ~/test/ufasta.fa out.fa       # prepend RC_ to names
faops rc -n ~/test/ufasta.fa out.fa    # keep original names

# Extract sequences with names in `list.file`, one name per line
faops some ~/test/ufasta.fa list.file out.fa

# Same as above, but from stdin and to stdout
cat ~/test/ufasta.fa | faops some stdin list.file stdout

# Sort by header strings
faops order ~/test/ufasta.fa \
    <(cat ~/test/ufasta.fa | grep '>' | sed 's/>//' | sort) \
    out.fa

# Sort by lengths
faops order ~/test/ufasta.fa \
    <(faops size ~/test/ufasta.fa | sort -n -r -k2,2 | cut -f 1) \
    out2.fa

# Tidy fasta file to 80 characters of sequence per line
faops filter -l 80 ~/test/ufasta.fa out.fa

# All content written on one line
faops filter -l 0 ~/test/ufasta.fa out.fa

# Convert fastq to fasta
faops filter -l 0 in.fq out.fa

# Compute N50, clean result
faops n50 -H ~/test/ufasta.fa
# 314

# Compute N75
faops n50 -N 75 ~/test/ufasta.fa
# N75     172

# Compute N90, sum and average of contigs with estimated genome size
faops n50 -N 90 -S -A -g 10000 ~/test/ufasta.fa
# N90     73
# S       9317
# A       186.34
```

## Tests

* 使用[bats](https://github.com/bats-core/bats-core)完成测试，有用的文章：http://blog.spike.cx/post/60548255435/testing-bash-scripts-with-bats

```shell
brew install bats-core
make test
```
