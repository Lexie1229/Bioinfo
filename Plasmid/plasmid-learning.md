# [Classifying Plasmids](https://github.com/wang-q/withncbi/blob/master/taxon/plasmid.md)
## 1 NCBI RefSeq（参考序列）

```bash
mkdir -p ~/biodata/plasmid
cd ~/biodata/plasmid

# 下载数据
rsync -avP ftp.ncbi.nlm.nih.gov::refseq/release/plasmid/ RefSeq/
gzip -dcf RefSeq/*.genomic.gbff.gz > genomic.gbff  ##因内存问题，仅使用部分数据

perl ~/Scripts/withncbi/taxon/gb_taxon_locus.pl genomic.gbff > refseq_id_seq.csv
rm genomic.gbff

# 查看fna文件
gzip -dcf RefSeq/plasmid.1.1.genomic.fna.gz | grep "^>" | head -n 3
# >NZ_PYUR01000034.1 Salmonella enterica subsp. enterica serovar Typhimurium strain OLF-FSR1-ST-44 plasmid unnamed1 40, whole genome shotgun sequence
# >NZ_PYUR01000035.1 Salmonella enterica subsp. enterica serovar Typhimurium strain OLF-FSR1-ST-44 plasmid unnamed1 18, whole genome shotgun sequence
# >NZ_PYUR01000036.1 Salmonella enterica subsp. enterica serovar Typhimurium strain OLF-FSR1-ST-44 plasmid unnamed1 24, whole genome shotgun sequence

faops n50 -S -C RefSeq/*.genomic.fna.gz
## N50     216181         N50
## S       2776005905     SUM
## C       43673          COUNT

gzip -dcf RefSeq/*.genomic.fna.gz > RefSeq/plasmid.fa
```

NOTE
* RefSeq:NCBI Reference Sequence Databased
    * \>NC_(chromosomes):表示该序列来自于NCBI的RefSeq数据库，提供一些可靠和经过认证的核酸和蛋白质序列记录,有固定的版本号，表示每个序列的特定版本。
    * \>NZ_:表示该序列来自于GenBank序列数据库的非RefSeq部分，这是一个由NCBI维护的公共数据库，包含大量未经认证的核酸和蛋白质序列记录，版本号不是固定的，因此同一条记录可能在不同的时间点有不同的版本号。
* 文件格式：
    * [gbff(GenBank Flat File) 格式](https://www.ncbi.nlm.nih.gov/datasets/docs/v1/reference-docs/file-formats/about-ncbi-gbff/)：NCBI的GenBank数据库(核酸序列数据库）中的标准格式，表示核苷酸序列，包括元数据(metadata,主要是描述数据属性信息的数据）、注释和序列本身。
    * gpff(GenPept Flat File) 格式：NCBI的GenPept数据库(蛋白质序列数据库）中的标准格式，表示蛋白质序列及其注释信息。
    * fna:FASTA格式DNA和蛋白质序列比对文件,其存储可被分子生物学软件使用的DNA信息。   
    * faa：储存蛋白质序列的文本格式。

## 2 MinHash to get non-redundant plasmids（获得非冗余质粒）

```bash
mkdir ~/biodata/plasmid/nr
cd ~/biodata/plasmid/nr

# 计算plasmid.fa中每个序列的碱基数，并写入refseq.sizes
faops size ../RefSeq/plasmid.fa > refseq.sizes

# 查看refseq.sizes中碱基数≤2000的行数
tsv-filter refseq.sizes --le 2:2000 | wc -l
## 9006

# 提取plasmid.fa中碱基数>2000(refseq.sizes)的序列，并写入refseq.fa
faops some ../RefSeq/plasmid.fa <(tsv-filter refseq.sizes --gt 2:2000) refseq.fa

# 构建 mash sketch 数据库
cat refseq.fa | 
    mash sketch -k 21 -s 1000 -i -p 4 - -o refseq.plasmid.k21s1000.msh
## 检查构建的数据库
mash info refseq.plasmid.k21s1000.msh | head -20

# split（分割）
mkdir -p job
## 将refseq.fa的第一列每1000行分割为一个文件，并以000开始命名
faops size refseq.fa |                  # 计算碱基数
    cut -f 1 |                          # 显示第一列
    split -l 1000 -a 3 -d - job/        # 分割文件
## 寻找job目录下文件名符合"数字开头的三字符"模式的文件，并从小到大排序
## 将标准输出重定向到标准错误，并输出格式化的文本字符串==> {}
## 提取refseq.fa中{}包含的序列，并构建 mash sketch 数据库
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"                        
        faops some refseq.fa {} stdout |
            mash sketch -k 21 -s 1000 -i -p 4 - -o {}.msh
    '
## 寻找job目录下文件名符合"数字开头的三字符"模式的文件，并从小到大排序
## 
## 以{}.msh为参考，估算refseq.plasmid.k21s1000.msh的遗传距离，并写入{}.tsv
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"
        mash dist -p 4 {}.msh refseq.plasmid.k21s1000.msh > {}.tsv
    '

# distance < 0.01(距离<0.01)
## 寻找job目录下文件名符合"数字开头的三字符"模式的文件，并从小到大排序
## 并写入redundant.tsv
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 8 '
        cat {}.tsv |
            tsv-filter --ff-str-ne 1:2 --le 3:0.01
    ' \
    > redundant.tsv

# 查看redundant.tsv的内容
head -n 3 redundant.tsv
#NZ_CP034776.1   NC_005249.1     0.000730741     0       970/1000
#NZ_CP034416.1   NC_005249.1     0.00580821      0       794/1000
#NZ_LR745046.1   NC_005249.1     0.0010072       0       959/1000

# 查看redundant.tsv的行数
cat redundant.tsv | wc -l
## 129384

cat redundant.tsv |
    perl -nla -F"\t" -MGraph::Undirected -e '
        BEGIN {
            our $g = Graph::Undirected->new;
        }

        $g->add_edge($F[0], $F[1]);

        END {
            for my $cc ( $g->connected_components ) {
                print join qq{\t}, sort @{$cc};
            }
        }
    ' \
    > connected_components.tsv

cat connected_components.tsv |
    perl -nla -F"\t" -e 'printf qq{%s\n}, $_ for @F' \
    > components.list

# 查看connected_components.tsv和components.list的行数
wc -l connected_components.tsv components.list
##  2073   connected_components.tsv
##  9800   components.list

faops some -i refseq.fa components.list stdout > refseq.nr.fa
faops some refseq.fa <(cut -f 1 connected_components.tsv) stdout >> refseq.nr.fa

rm -fr job
```

NOTE  
tsvTSV (Tab-Separated Values)  
* tsv-filter [options] [file]
    * --le|gt|eq|ne|lt|ge FIELD:NUM：Compare a field to a number (integer or float)(FIELE列：数字≤|>|=|≠|<|≥NUM).
    * --ff-eq|ff-ne|ff-lt|ff-le|ff-gt|ff-ge FIELD1:FIELD2:Field to field comparisons - Similar to field vs literal comparisons, but field vs field(字段与字段的比较).

Mash(MinHash)   
* mash command [options] [arguments]
    * sketch：构建草图，用于快速进行遗传距离分析。
        * mash sketch [options] [input]
        * -k int：K-mer size. Hashes will be based on strings of this many nucleotides(K-mer大小，核苷酸的字符串大小).
        * -s int：Seed to provide to the hash function(种子，用作随机数生成器或哈希函数的输入，以产生一系列随机或伪随机数，用于初始化哈希函数的内部状态).
        * -i：Sketch individual sequences, rather than whole files, e.g. for multi-fastas of single-chromosome genomes or pair-wise gene comparisons(绘制单个序列).
        * -p int：Parallelism. This many threads will be spawned for processing(并行性，使用int线程处理).
        * -o path：Output prefix (first input file used if unspecified). The suffix '.msh' will be appended(输出前缀，附加后缀.msh). 
    * dist：估算比对序列到参考序列的遗传距离。
        * mash dist [options] [reference] [query]
        * -p int：Parallelism. This many threads will be spawned for processing(并行性，使用int线程处理).
    * info：显示草图文件的信息。
        * mash info [options] <sketch>
* Mash的原理:借用MinHash搜索引擎常用的判断重复文档的技术，并增加了计算两两之间突变距离和P值显著性检验。
    * 将序列集合打碎成固定长度的短片段，称为k-mer；
    * 在大多数真核生物基因组中，21-mer是一种适合于组装长序列的长度，同时可以最大化重叠区域，并提高组装的准确性；
    * 将每个k-mer经哈希函数转换成哈希值，得到由哈希值组成的集合；
    * 计算序列集相似度的问题，即转化成集合的运算。
    


## 3 Grouping by MinHash（分组）

```bash
mkdir ~/data/plasmid/grouping
cd ~/data/plasmid/grouping

cat ../nr/refseq.nr.fa |
    mash sketch -k 21 -s 1000 -i -p 8 - -o refseq.nr.k21s1000.msh

# split
mkdir -p job
faops size ../nr/refseq.nr.fa |
    cut -f 1 |
    split -l 1000 -a 3 -d - job/

find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"
        faops some ../nr/refseq.nr.fa {} stdout |
            mash sketch -k 21 -s 1000 -i -p 6 - -o {}.msh
    '

find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"
        mash dist -p 6 {}.msh refseq.nr.k21s1000.msh > {}.tsv
    '

find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 1 '
        cat {}.tsv
    ' \
    > dist_full.tsv

# distance < 0.05
cat dist_full.tsv |
    tsv-filter --ff-str-ne 1:2 --le 3:0.05 \
    > connected.tsv

head -n 5 connected.tsv
#NC_019347.1     NC_000906.2     0.0321972       0       341/1000
#NC_004847.1     NC_000906.2     0.0458408       0       236/1000
#NC_002111.1     NC_002130.1     0.0375603       0       294/1000
#NC_002636.1     NC_006994.1     0.0284057       0       380/1000
#NC_002524.1     NC_006994.1     0.0444041       0       245/1000

cat connected.tsv | wc -l
#60618

mkdir -p group
cat connected.tsv |
    perl -nla -F"\t" -MGraph::Undirected -MPath::Tiny -e '
        BEGIN {
            our $g = Graph::Undirected->new;
        }

        $g->add_edge($F[0], $F[1]);

        END {
            my @rare;
            my $serial = 1;
            my @ccs = $g->connected_components;
            @ccs = map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [ $_, scalar( @{$_} ) ] } @ccs;
            for my $cc ( @ccs ) {
                my $count = scalar @{$cc};
                if ($count < 50) {
                    push @rare, @{$cc};
                }
                else {
                    path(qq{group/$serial.lst})->spew(map {qq{$_\n}} @{$cc});
                    $serial++;
                }
            }
            path(qq{group/00.lst})->spew(map {qq{$_\n}} @rare);

            path(qq{grouped.lst})->spew(map {qq{$_\n}} $g->vertices);
        }
    '

# get non-grouped
# this will no be divided to subgroups
faops some -i ../nr/refseq.nr.fa grouped.lst stdout |
    faops size stdin |
    cut -f 1 \
    > group/lonely.lst

wc -l group/*
#  3333 group/00.lst
#  1644 group/1.lst
#   359 group/2.lst
#    94 group/3.lst
#    69 group/4.lst
#    65 group/5.lst
#    55 group/6.lst
#    51 group/7.lst
#    51 group/8.lst
#  6477 group/lonely.lst
# 12198 total

find group -maxdepth 1 -type f -name "[0-9]*.lst" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"

        faops some ../nr/refseq.nr.fa {} stdout |
            mash sketch -k 21 -s 1000 -i -p 6 - -o {}.msh

        mash dist -p 6 {}.msh {}.msh > {}.tsv
    '

find group -maxdepth 1 -type f -name "[0-9]*.lst.tsv" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"

        cat {} |
            tsv-select -f 1-3 |
            Rscript -e '\''
                library(readr);
                library(tidyr);
                library(ape);
                pair_dist <- read_tsv(file("stdin"), col_names=F);
                tmp <- pair_dist %>%
                    pivot_wider( names_from = X2, values_from = X3, values_fill = list(X3 = 1.0) )
                tmp <- as.matrix(tmp)
                mat <- tmp[,-1]
                rownames(mat) <- tmp[,1]

                dist_mat <- as.dist(mat)
                clusters <- hclust(dist_mat, method = "ward.D2")
                tree <- as.phylo(clusters)
                write.tree(phy=tree, file="{.}.tree.nwk")

                group <- cutree(clusters, h=0.2) # k=3
                groups <- as.data.frame(group)
                groups$ids <- rownames(groups)
                rownames(groups) <- NULL
                groups <- groups[order(groups$group), ]
                write_tsv(groups, "{.}.groups.tsv")
            '\''
    '

# subgroup
mkdir -p subgroup
cp group/lonely.lst subgroup/

find group -name "*.groups.tsv" | sort |
    parallel -j 1 -k '
        cat {} | sed -e "1d" | xargs -I[] echo "{/.}_[]"
    ' |
    sed -e 's/.lst.groups_/_/' |
    perl -na -F"\t" -MPath::Tiny -e '
        path(qq{subgroup/$F[0].lst})->append(qq{$F[1]});
    '

# ignore small subgroups
find subgroup -name "*.lst" | sort |
    parallel -j 1 -k '
        lines=$(cat {} | wc -l)

        if (( lines < 5 )); then
            echo -e "{}\t$lines"
            cat {} >> subgroup/lonely.lst
            rm {}
        fi
    '

# append ccs
cat ../nr/connected_components.tsv |
    parallel -j 1 --colsep "\t" '
        file=$(rg -F -l  "{1}" subgroup)
        echo {} | tr "[:blank:]" "\n" >> ${file}
    '

# remove duplicates
find subgroup -name "*.lst" | sort |
    parallel -j 1 '
        cat {} | sort | uniq > tmp.lst
        mv tmp.lst {}
    '

wc -l subgroup/* |
    sort -nr |
    head -n 100

wc -l subgroup/* |
    perl -pe 's/^\s+//' |
    tsv-filter -d" " --le 1:10 |
    wc -l
#132

wc -l subgroup/* |
    perl -pe 's/^\s+//' |
    tsv-filter -d" " --ge 1:50 |
    tsv-filter -d " " --regex '2:\d+' |
    sort -nr \
    > next.tsv

wc -l next.tsv
#53

# rm -fr job

```

## 4 Plasmid: prepare

* Split sequences

```bash
mkdir ~/data/plasmid/GENOMES
mkdir ~/data/plasmid/taxon

cd ~/data/plasmid/grouping

echo -e "#Serial\tGroup\tCount\tTarget" > ../taxon/group_target.tsv

cat next.tsv |
    cut -d" " -f 2 |
    parallel -j 4 -k --line-buffer '
        echo >&2 "==> {}"

        GROUP_NAME={/.}
        TARGET_NAME=$(head -n 1 {} | perl -pe "s/\.\d+//g")

        SERIAL={#}
        COUNT=$(cat {} | wc -l)

        echo -e "${SERIAL}\t${GROUP_NAME}\t${COUNT}\t${TARGET_NAME}" >> ../taxon/group_target.tsv

        faops order ../nr/refseq.fa {} stdout |
            faops filter -s stdin stdout \
            > ../GENOMES/${GROUP_NAME}.fa
    '

cat next.tsv |
    cut -d" " -f 2 |
    parallel -j 4 -k --line-buffer '
        echo >&2 "==> {}"
        GROUP_NAME={/.}
        faops size ../GENOMES/${GROUP_NAME}.fa > ../taxon/${GROUP_NAME}.sizes
    '

# Optional: RepeatMasker
#egaz repeatmasker -p 16 ../GENOMES/*.fa -o ../GENOMES/

# split-name
find ../GENOMES -maxdepth 1 -type f -name "*.fa" | sort |
    parallel -j 4 '
        faops split-name {} {.}
    '

# mv to dir of basename
find ../GENOMES -maxdepth 2 -mindepth 2 -type f -name "*.fa" | sort |
    parallel -j 4 '
        mkdir -p {.}
        mv {} {.}
    '

```

* `prepseq`

```bash
cd ~/data/plasmid/

cat taxon/group_target.tsv |
    sed -e '1d' |
    parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 4 '
        echo -e "==> Group: [{2}]\tTarget: [{4}]\n"

        for name in $(cat taxon/{2}.sizes | cut -f 1); do
            egaz prepseq GENOMES/{2}/${name}
        done
    '

```

* Check outliers of lengths

```bash
cd ~/data/plasmid/

cat taxon/*.sizes | cut -f 1 | wc -l
#4816

cat taxon/*.sizes | cut -f 2 | paste -sd+ | bc
#466119084

cat taxon/group_target.tsv |
    sed -e '1d' |
    parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 4 '
        echo -e "==> Group: [{2}]\tTarget: [{4}]"

        median=$(cat taxon/{2}.sizes | datamash median 2)
        mad=$(cat taxon/{2}.sizes | datamash mad 2)
        lower_limit=$( bc <<< " (${median} - 2 * ${mad}) / 2" )

#        echo $median $mad $lower_limit
        lines=$(tsv-filter taxon/{2}.sizes --le "2:${lower_limit}" | wc -l)

        if (( lines > 0 )); then
            echo >&2 "    $lines lines to be filtered"
            tsv-join taxon/{2}.sizes -e -f <(
                    tsv-filter taxon/{2}.sizes --le "2:${lower_limit}"
                ) \
                > taxon/{2}.filtered.sizes
            mv taxon/{2}.filtered.sizes taxon/{2}.sizes
        fi
    '

cat taxon/*.sizes | cut -f 1 | wc -l
#4780

cat taxon/*.sizes | cut -f 2 | paste -sd+ | bc
#464908146

```

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/plasmid/ \
    wangq@202.119.37.251:data/plasmid

# rsync -avP wangq@202.119.37.251:data/plasmid/ ~/data/plasmid

```

## 5 Plasmid: run

```bash
cd ~/data/plasmid/

cat taxon/group_target.tsv |
    sed -e '1d' | grep "^53" |
    parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 1 '
        echo -e "==> Group: [{2}]\tTarget: [{4}]\n"

        egaz template \
            GENOMES/{2}/{4} \
            $(cat taxon/{2}.sizes | cut -f 1 | grep -v -x "{4}" | xargs -I[] echo "GENOMES/{2}/[]") \
            --multi -o groups/{2}/ \
            --order \
            --parallel 24 -v

#        bash groups/{2}/1_pair.sh
#        bash groups/{2}/3_multi.sh

        bsub -q mpi -n 24 -J "{2}-1_pair" "bash groups/{2}/1_pair.sh"
        bsub -w "ended({2}-1_pair)" \
            -q mpi -n 24 -J "{2}-3_multi" "bash groups/{2}/3_multi.sh"
    '

# clean
find groups -mindepth 1 -maxdepth 3 -type d -name "*_raw" | parallel -r rm -fr
find groups -mindepth 1 -maxdepth 3 -type d -name "*_fasta" | parallel -r rm -fr
find . -mindepth 1 -maxdepth 3 -type f -name "output.*" | parallel -r rm

echo \
    $(find groups -mindepth 1 -maxdepth 1 -type d | wc -l) \
    $(find groups -mindepth 1 -maxdepth 3 -type f -name "*.nwk.pdf" | wc -l)

```

