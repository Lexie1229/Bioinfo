# `faops` operates fasta files

`faops` is a lightweight tool for operating sequences in the fasta format.

This tool can be regarded as a combination of `faCount`, `faSize`,
`faFrag`, `faRc`, `faSomeRecords`, `faFilter` and `faSplit` from
[UCSC Jim Kent's utilities](http://hgdownload.cse.ucsc.edu/admin/exe/).

Comparing to Kent's `fa*` utilities, `faops` is:

* much smaller (kilo vs mega bytes)
* easy to compile (only one external dependency)
* well tested
* contains only one executable file
* can operate gzipped (bgzipped) files
* and can be run under all major OSes (including Windows).

`faops` is also inspired/influenced/stealing from
[`seqtk`](https://github.com/lh3/seqtk) and
[`ufasta`](http://www.genome.umd.edu/masurca.html).

```text
$ ./faops

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

* Reverse complement 反补

        faops rc test/ufasta.fa out.fa       # prepend RC_ to names
        faops rc -n test/ufasta.fa out.fa    # keep original names

* Extract sequences with names in `list.file`, one name per line

        faops some test/ufasta.fa list.file out.fa

* Same as above, but from stdin and to stdout

        cat test/ufasta.fa | faops some stdin list.file stdout

* Sort by header strings

        faops order test/ufasta.fa \
            <(cat test/ufasta.fa | grep '>' | sed 's/>//' | sort) \
            out.fa

* Sort by lengths

        faops order test/ufasta.fa \
            <(faops size test/ufasta.fa | sort -n -r -k2,2 | cut -f 1) \
            out2.fa

* Tidy fasta file to 80 characters of sequence per line

        faops filter -l 80 test/ufasta.fa out.fa

* All content written on one line

        faops filter -l 0 test/ufasta.fa out.fa

* Convert fastq to fasta

        faops filter -l 0 in.fq out.fa

* Compute N50, clean result

        faops n50 -H test/ufasta.fa

* Compute N75

        faops n50 -N 75 test/ufasta.fa

* Compute N90, sum and average of contigs with estimated genome size

        faops n50 -N 90 -S -A -g 10000 test/ufasta.fa

## Compiling 编译

`faops` can be compiled under Linux, macOS (gcc or clang) and Windows (MinGW).

```shell
git clone https://github.com/wang-q/faops
cd faops
make
```

## Installing with Homebrew or Linuxbrew

```shell
brew install wang-q/tap/faops
```

## Tests

Done with [bats](https://github.com/bats-core/bats-core). Useful articles:

* https://blog.engineyard.com/2014/bats-test-command-line-tools
* http://blog.spike.cx/post/60548255435/testing-bash-scripts-with-bats

```shell
# brew install bats-core
make test
```

## Dependency

* `zlib`
* `kseq.h` and `khash.h` from
  [`klib`](https://github.com/attractivechaos/klib) (bundled)

# AUTHOR

Qiang Wang &lt;wang-q@outlook.com&gt;

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Qiang Wang.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5
programming language system itself.


# NOTE
> * faops rc [options] <in.fa> <out.fa> 反补序列
>> * -n(name) : keep name identical (don't prepend RC_) 
>> * -r(reverse) : just Reverse, prepends R_  
>> * -c(complement) : just Complement, prepends C_  
>> * -f STR : only RC sequences in this list.file  
>> * -l INT : sequence line length [80]
> * faops some [options] <in.fa> <list.file> <out.fa> 提取多个序列  
>> * -i(invert) : Invert, output sequences not in the list  
>> * -l INT : sequence line length [80]  
> * faops order [options] <in.fa> <list.file> <out.fa> 按给定顺序提取多个序列  
>> * -l INT：sequence line length [80]  
> * faops size <in.fa> [more_files.fa] 计算每一个reads的总碱基数
>> * faops filter [options] <in.fa> <out.fa> 按照条件对序列进行筛选
>> * -a INT：pass sequences at least this big ('a'-smallest)
>> * -z INT：pass sequences this size or smaller ('z'-biggest)
>> * -n INT：pass sequences with fewer than this number of N's
>> * -u：Unique, removes duplicated ids, keeping the first(删除重复序列)。
>> * -U：Upper case, converts all sequences to upper cases(将所有序列转换为大写)。
>> * -b：pretend to be a blocked fasta file
>> * -N：convert IUPAC ambiguous codes to 'N'
>> * -d：remove dashes '-'
>> * -s：simplify sequence names(简化序列名称)。
>> * -l INT：sequence line length [INT]
>>> * 例如：faops filter -l 0 <in.fq> <out.fa>，将所有内容写在一行上，并将fastq格式转变为fasta格式。
> * faops n50 [options] <in.fa> [more_files.fa] 计算n50和其他数据
>> * -H：do not display header（不显示标题-N50）。
>> * -N INT：compute Nx statistic [INT] (计算N[INT])。
>> * -S：compute sum of size of all entries（计算所有序列的总碱基数）。
>> * -A：compute average length of all entries（计算序列的平均碱基数）。
>> * -E：compute the E-size (from GAGE)
>> * -C：count entries（计算序列条数）。
>> * -g INT：size of genome, instead of total size in files（基于组装的基因组大小进行N[INT]预测）。

> * ( )：指令群组（command group).
> * < ：读入。
> * \ ：换行。