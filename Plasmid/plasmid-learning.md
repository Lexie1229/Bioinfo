# [Classifying Plasmids](https://github.com/wang-q/withncbi/blob/master/taxon/plasmid.md)
## 1 NCBI RefSeq（参考序列）

```bash
mkdir -p ~/biodata/plasmid
cd ~/biodata/plasmid

# 下载数据
rsync -avP ftp.ncbi.nlm.nih.gov::refseq/release/plasmid/ RefSeq/
gzip -dcf RefSeq/*.genomic.gbff.gz > genomic.gbff  ##因内存问题，仅使用部分数据
## FTP URL 格式：ftp://[user[:password]@]host[:port]/url-path

# 提取genomic.gbff中每个序列的taxon(分类单元)ID和locus(位点)名称，并写入refseq_id_seq.csv
perl ~/Scripts/withncbi/taxon/gb_taxon_locus.pl genomic.gbff > refseq_id_seq.csv
rm genomic.gbff

# 查看fna文件
gzip -dcf RefSeq/plasmid.1.1.genomic.fna.gz | grep "^>" | head -n 3
# >NZ_PYUR01000034.1 Salmonella enterica subsp. enterica serovar Typhimurium strain OLF-FSR1-ST-44 plasmid unnamed1 40, whole genome shotgun sequence
# >NZ_PYUR01000035.1 Salmonella enterica subsp. enterica serovar Typhimurium strain OLF-FSR1-ST-44 plasmid unnamed1 18, whole genome shotgun sequence
# >NZ_PYUR01000036.1 Salmonella enterica subsp. enterica serovar Typhimurium strain OLF-FSR1-ST-44 plasmid unnamed1 24, whole genome shotgun sequence

# 计算*.genomic.fna.gz的N50、总碱基数、序列个数
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
    * [gbff(GenBank Flat File) 格式](https://www.ncbi.nlm.nih.gov/datasets/docs/v1/reference-docs/file-formats/about-ncbi-gbff/)：NCBI的GenBank数据库(核酸序列数据库)中的标准格式，表示核苷酸序列，包括元数据(metadata,主要是描述数据属性信息的数据)、注释和序列本身，以//表示结束。
    * gpff(GenPept Flat File) 格式：NCBI的GenPept数据库(蛋白质序列数据库)中的标准格式，表示蛋白质序列及其注释信息。
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
    mash sketch -k 21 -s 1000 -i -p 8 - -o refseq.plasmid.k21s1000.msh
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
    parallel -j 8 --line-buffer '
        echo >&2 "==> {}"                        
        faops some refseq.fa {} stdout |
            mash sketch -k 21 -s 1000 -i -p 10 - -o {}.msh
    '
## 以{}.msh为参考，估算refseq.plasmid.k21s1000.msh的遗传距离，并写入{}.tsv
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 8 --line-buffer '
        echo >&2 "==> {}"
        mash dist -p 10 {}.msh refseq.plasmid.k21s1000.msh > {}.tsv
    '
## 结果格式：reference-ID;query-ID distance(越小,距离越近);p-value(越小，越可信);shared-hashes(匹配数越多，距离越小，物种相似度越高).

# distance < 0.01(遗传距离<0.01)
## 筛选{}.tsv中第一列和第二列字符串不一样的行中，第三列的数值≤0.01的行，并写入redundant.tsv
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 8 '
        cat {}.tsv |
            tsv-filter --ff-str-ne 1:2 --le 3:0.01
    ' \
    > redundant.tsv

# 查看redundant.tsv的内容
head -n 3 redundant.tsv
# NZ_WXYR01000017.1       NZ_PYUR01000035.1       0.00960897      0       691/1000
# NZ_WXYS01000016.1       NZ_PYUR01000035.1       0.00956826      0       692/1000
# NZ_JAKRCQ010000032.1    NZ_JAIVEG010000047.1    0.000458924     0       981/1000

# 查看redundant.tsv的行数
cat redundant.tsv | wc -l
## 602222

# 查看redundant.tsv，每行以\t为分隔符分割为数组并执行循环体中的代码
# 提取所有连通分量，写入connected_components.tsv
cat redundant.tsv |
    perl -nla -F"\t" -MGraph::Undirected -e '
        BEGIN {
            our $g = Graph::Undirected->new;     
            # 创建一个名为$g的无向图对象
            # our声明私有变量，但其指向同名全局变量对应的内存数据，在作用域内修改的全局数据会持久生效
        }
        # BEGIN在Perl编译后，程序运行前执行，用于初始化变量、加载模块等

        $g->add_edge($F[0], $F[1]);
        # 添加以$F[0]和$F[1]为顶点的一条边

        END {
            for my $cc ( $g->connected_components ) {
            # 计算$g无向图的所有连通分量
                print join qq{\t}, sort @{$cc};
                # qq{\t}是perl中用于创建带有双引号的字符串的一种方式，表示"\t"
                # 每个连通分量中的顶点排序后，使用\t连接成字符串，并输出到标准输出
            }
        }
        # END在程序执行完毕后运行，用于释放资源、打印信息等
    ' \
    > connected_components.tsv

# 查看connected_components.tsv，每行以\t为分隔符分割为数组并执行循环体中的代码
# 打印数组中每个元素，每行一个，并写入components.list
cat connected_components.tsv |
    perl -nla -F"\t" -e 'printf qq{%s\n}, $_ for @F' \
    > components.list

# 查看connected_components.tsv和components.list的行数
wc -l connected_components.tsv components.list
##   3484   connected_components.tsv
##  21155   components.list

# 从refseq.fa中提取不在components.list中的序列，写入refseq.nr.fa
# 从connected_components.tsv提取第一列序列，添加到refseq.nr.fa
# 每个连通分量的所有节点的质粒序列相似，仅保留其中一个节点的序列，去除冗余
faops some -i refseq.fa components.list stdout > refseq.nr.fa
faops some refseq.fa <(cut -f 1 connected_components.tsv) stdout >> refseq.nr.fa

rm -fr job
```

NOTE    
tsv(Tab Separated Values)  
* tsv-filter [options] [file]
    * --le|gt|eq|ne|lt|ge FIELD:NUM：Compare a field to a number (integer or float)(FIELE列：数字≤|>|=|≠|<|≥NUM).
    * --ff-eq|ff-ne|ff-lt|ff-le|ff-gt|ff-ge FIELD1:FIELD2:Field to field comparisons - Similar to field vs literal comparisons, but field vs field(字段与字段的数值的比较).
    * --ff-str-eq|ff-str-ne|ff-istr-eq|ff-istr-ne  FIELD1:FIELD2:Field to field comparisons - Similar to field vs literal comparisons, but field vs field(字段与字段的字符串的比较).
    * --regex|iregex|not-regex|not-iregex  FIELD:REGEX：Test if a field matches a regular expression(测试字段是否与正则表达式匹配).
    * --d|delimiter CHR：Field delimiter. Default: TAB(指定字段分隔符).
* tsv-select [options] [file]
    * -f/--fields field-list：Fields to retain. Fields are output in the order listed(保留字段,字段按列出的顺序输出).
    * -H/--header：Treat the first line of each file as a header(指定输入文件是否包含标题行,若包含，则默认使用标题行中的列名来选择列).
    * -e/--exclude field-list：Fields to exclude(排除字段).
    * -r/--rest first|last：Output location for fields not included in '--f|fields'.

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
        * mash info [options] sketch
* Mash的原理:借用MinHash搜索引擎常用的判断重复文档的技术，并增加了计算两两之间突变距离和P值显著性检验。
    * 将序列集合打碎成固定长度的短片段，称为k-mer；
    * 在大多数真核生物基因组中，21-mer是一种适合于组装长序列的长度，同时可以最大化重叠区域，并提高组装的准确性；
    * 将每个k-mer经哈希函数转换成哈希值，得到由哈希值组成的集合；
    * 计算序列集相似度的问题，即转化成集合的运算。
    * Jaccard距离：J(A,B) = |A ∩ B| / |A ∪ B|
    
## 3 Grouping by MinHash（分组）

```bash
mkdir ~/biodata/plasmid/grouping
cd ~/biodata/plasmid/grouping

# 构建 mash sketch 数据库
cat ../nr/refseq.nr.fa |
    mash sketch -k 21 -s 1000 -i -p 8 - -o refseq.nr.k21s1000.msh

# split(分割)
mkdir -p job
faops size ../nr/refseq.nr.fa |
    cut -f 1 |
    split -l 1000 -a 3 -d - job/

# 序列分割后，构建 mash sketch 数据库
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 8 --line-buffer '
        echo >&2 "==> {}"
        faops some ../nr/refseq.nr.fa {} stdout |
            mash sketch -k 21 -s 1000 -i -p 6 - -o {}.msh
    '

# 估算遗传距离
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 8 --line-buffer '
        echo >&2 "==> {}"
        mash dist -p 8 {}.msh refseq.nr.k21s1000.msh > {}.tsv
    '

# 查看遗传距离的计算结果，并写入dist_full.tsv
find job -maxdepth 1 -type f -name "[0-9]??" | sort |
    parallel -j 8 '
        cat {}.tsv
    ' \
    > dist_full.tsv

# distance < 0.05 (遗传距离<0.05)
## 筛选dist_full.tsv中第一列和第二列字符串不一样的行中，第三列的数值≤0.05的行，并写入connected.tsv
cat dist_full.tsv |
    tsv-filter --ff-str-ne 1:2 --le 3:0.05 \
    > connected.tsv

# 查看connected.tsv的内容
head -n 3 connected.tsv
# NZ_CP072269.1   NZ_LAUP01000082.1       0.0487413       0       219/1000
# NC_025008.1     NZ_AUPT01000023.1       0.0482105       0       222/1000
# NC_013034.2     NZ_AUPT01000023.1       0.041003        0       268/1000

# 查看connected.tsv的行数
cat connected.tsv | wc -l
# 158724

mkdir -p group
# 按照每个连通分量的节点个数，进行分组
# 注意函数执行的顺序
cat connected.tsv |
    perl -nla -F"\t" -MGraph::Undirected -MPath::Tiny -e '
        BEGIN {
            our $g = Graph::Undirected->new;
        }

        $g->add_edge($F[0], $F[1]);

        END {
            my @rare;
            my $serial = 1;
            # 定义$serial初始值为1，用于给每个连通分量分配一个唯一的数字序号

            my @ccs = $g->connected_components;
            # 获取$g无向图的所有连通分量，并存入@ccs数组

            @ccs = map { $_->[0] }
            # map函数用于将一个数组中的元素进行转换，map {} @，{}内的部分是对原列表的每个元素进行的操作
            # 提取数组2的每个列表的第一个元素（连通分量），生成新的数组@ccs

                sort { $b->[1] <=> $a->[1] }
                # sort函数用于对列表进行排序，map {} @，{}内的部分是用于排序的比较函数，参数$a和$b表示要比较的两个元素
                # 如果$a应该在$b前面，则返回负数；如果$a和$b无所谓顺序，则返回0；如果$b应该在$a前面，则返回正数
                # 按照scalar(@{$_})（每个连通分量的节点个数）将数组1进行降序排列，生成新的数组2

                map { [ $_, scalar( @{$_} ) ] } @ccs;
                # 提取@ccs数组中的每个列表（连通分量）存入$_，并计算其元素（节点）个数，生成新的列表[$_, scalar(@{$_})]，生成新的数组1

            for my $cc ( @ccs ) {
                my $count = scalar @{$cc};
                # 计算@{$cc}列表中元素的个数

                if ($count < 50) {
                    push @rare, @{$cc};
                    # 如果$count < 50，将连通分量的每个节点的数组存入@rare数组
                }
                else {
                    path(qq{group/$serial.lst})->spew(map {qq{$_\n}} @{$cc});
                    # 否则，将连通分量的每个节点以\n为分隔符生成新的数组，并将数组内的文本存入group/$serial.lst文件
                    # spew函数用于将字符串或数组中的文本写入文件，$filepath->spew(@lines)，$filepath表示写入的文件路径，@lines表示要写入的字符串或数组中的文本

                    $serial++;
                    # $serial的值加1
                }
            }
            path(qq{group/00.lst})->spew(map {qq{$_\n}} @rare);
            # 将@rare的每个元素以\n为分隔符生成新的数组，并将数组内的文本存入group/00.lst文件
            
            path(qq{grouped.lst})->spew(map {qq{$_\n}} $g->vertices);
            # 将$g的所有节点按行转换为字符串数组，并将数组内的文本存入grouped.lst文件
            # $g->vertices用于返回图中所有节点的列表
        }
    '

# get non-grouped(获取非分组)，this will no be divided to subgroups（这些将不被分组）
# 从refseq.nr.fa中提取不在grouped.lst中的序列
# 计算每个序列的碱基数，显示第一列，并写入group/lonely.lst
faops some -i ../nr/refseq.nr.fa grouped.lst stdout |
    faops size stdin |
    cut -f 1 \
    > group/lonely.lst

# 查看group/*文件的行数
wc -l group/*
#  3862 group/00.lst
#  5484 group/1.lst
#   217 group/2.lst
#    79 group/3.lst
#    73 group/4.lst
#    70 group/5.lst
#    68 group/6.lst
#  7150 group/lonely.lst
# 17003 total

# 寻找group目录下文件名符合"数字开头.lst"模式的文件，并从小到大排序
# 计算组内的遗传距离，并写入{}.tsv
find group -maxdepth 1 -type f -name "[0-9]*.lst" | sort |
    parallel -j 4 --line-buffer '
        echo >&2 "==> {}"

        faops some ../nr/refseq.nr.fa {} stdout |
            mash sketch -k 21 -s 1000 -i -p 3 - -o {}.msh

        mash dist -p 3 {}.msh {}.msh > {}.tsv
    '

# 将每个"[0-9]*.lst.tsv"文件聚类，并将结果树写入{.}.tree.nwk，分组结果写入{.}.groups.tsv
find group -maxdepth 1 -type f -name "[0-9]*.lst.tsv" | sort |
    parallel -j 8 --line-buffer '
        echo >&2 "==> {}"

        cat {} |
            tsv-select -f 1-3 |
            Rscript -e '\''
            # R脚本的内容使用单引号''括起来，防止shell解释任何字符

                library(readr);
                library(tidyr);
                library(ape);
                pair_dist <- read_tsv(file("stdin"), col_names=F);
                # read_tsv(file, col_names = TRUE, col_types = NULL, ... )函数，用于从TSV文件中读取数据，file表示要读取的文件路径
                # 使用read_tsv函数从标准输入中读取数据，并将其赋值给变量pair_dist,col_names=F表示数据中不包含列名

                tmp <- pair_dist %>%
                # %>% 是R中的管道操作符，即链式操作符（pipe operator），将左侧的输出作为右侧的输入
                    pivot_wider( names_from = X2, values_from = X3, values_fill = list(X3 = 1.0) )
                    # pivot_wider(data, names_from, values_from, values_fill)函数，用于将数据从“长格式”变成“宽格式”，data表示要变换的数据框，names_from表示新数据框的列名，values_from表示新数据框的值，values_fill是可选的参数，用于指定缺失值的填充方式
                    # list(...)函数，用于创建列表

                tmp <- as.matrix(tmp)
                # as.matrix(x)函数，用于将R中的某些数据类型转换为矩阵（matrix）类型，x表示要转换为矩阵的R对象

                mat <- tmp[,-1]
                # 矩阵和数组、数据框：使用[i, j]的形式来访问第i行、第j列的元素；使用负数下标可以排除指定的行或列
                # 将tmp的所有行，除去第一列后的所有列（从第2列到最后一列）赋值给变量mat

                rownames(mat) <- tmp[,1]
                # rownames(x) <- row_names函数，用于设置或获取矩阵或数据框的行名，x表示要设置行名的矩阵或数据框，row_names是一个字符向量，包含要设置的行名

                dist_mat <- as.dist(mat)
                # as.dist(x, diag = FALSE, upper = FALSE, ... )函数，用于将矩阵转换为“距离矩阵”，其中每个元素都表示两个对象之间的距离或相似度，x表示输入的矩阵

                clusters <- hclust(dist_mat, method = "ward.D2")
                # hclust(d, method = "complete")函数，用于进行层次聚类，d表示一个距离矩阵或可转化为距离矩阵的对象，method表示指定的聚类方法
                # 可以通过 plot() 函数将聚类结果进行可视化
                # ward.D2：采用方差最小化方法进行聚类

                tree <- as.phylo(clusters)
                # as.phylo(hclust_object)函数，用于将聚类树转化为phylo对象，hclust_object是用hclust()函数得到的聚类对象

                write.tree(phy=tree, file="{.}.tree.nwk")
                # write.tree(phy, file)函数，用于将树对象写入文件，phy表示需要写入的树对象，file 表示需要写入的文件名，默认写入的文件格式是.nwk格式的Newick树文件
                # {.}表示命令行中输入的最后一个参数的文件名（不包括扩展名)，{.}作为输出文件名的占位符

                group <- cutree(clusters, h=0.2) # k=3
                # cutree(tree, h = NULL, k = NULL, order_clusters = FALSE)函数，用于将聚类结果切分成指定数量的簇
                # tree表示一棵聚类树对象，通常由hclust函数产生；h表示一个阈值，决定聚类树的高度，确定簇的数量，如果为NULL，则将聚类树切成指定数量的簇（由参数k指定）；k表示要生成的簇的数量，如果h不为NULL，则此参数将被忽略；order_clusters表示是否按照聚类树的顺序对簇进行编号

                groups <- as.data.frame(group)
                # 将聚类分组转换为数据框，每个序列都被分配到一个组中，并被标记为在第几个组中
                # as.data.frame(x, row.names = NULL, optional = FALSE, ...)函数，用于将其他数据类型（如矩阵、数组等）转换为数据框
                # x表示要转换为数据框的对象，如矩阵、数组等；row.names表示数据框中是否使用原对象的行名，默认为 NULL，即使用 1 到 n 的行号作为行名；optional表示是否将原对象的属性也包括在数据框中，默认为 FALSE

                groups$ids <- rownames(groups)
                # 给groups数据框添加了一列ids，并将行名赋值给这一列
                # $符号用于从数据框或列表中提取具有给定名称的列或元素

                rownames(groups) <- NULL
                # 将groups数据框的行名（即行索引）设为NULL，清除原来的行名并重新生成默认的行索引

                groups <- groups[order(groups$group), ]
                # 将 groups 数据框按照 group 列进行升序排列
                # order(..., na.last = TRUE, decreasing = FALSE)，用于根据一个或多个向量的值的大小对一个向量进行排序，并返回排序后的下标
                # ...表示需要排序的向量，可以是多个向量；na.last表示是否将NA值放在最后；decreasing表示排序顺序是否为降序

                write_tsv(groups, "{.}.groups.tsv")
                # 将groups数据框保存为.tsv格式的文件，文件名以原始输入文件名为基础，并在文件名结尾添加“.groups.tsv”作为文件扩展名
                # write_tsv(x,file = "",append = FALSE,col_names = TRUE,quote_escape = "double",na = "NA",eol = "\n")
                # x表示要写入到文件中的数据框或矩阵；file表示写入数据的文件路径；append如果为 TRUE，则追加数据到文件末尾，如果为FALSE，则覆盖原有文件；col_names如果为TRUE，则写入列名；quote_escape表示如果写入的数据包含引号，如何处理，可以为 "double"（默认）表示用双引号包围字符串，或 "backslash" 表示用反斜杠进行转义；na表示缺失值的表示方式，默认为 "NA"；eol表示行结束符的表示方式，默认为 "\n"
            '\''
    '

# subgroup(亚群)
mkdir -p subgroup
cp group/lonely.lst subgroup/

# 寻找group目录下名为"*.groups.tsv"的文件，并从小到大排序
# 对每个{}文本，删除文本的第一行，将每行内容[]，按照{/.}_[]的格式输出，并将.lst.groups_替换为_
# 每行以\t为分隔符分割为数组并执行循环体中的代码
# 将属于同一个分组的序列名称写入同一个.lst文件
find group -name "*.groups.tsv" | sort |
    parallel -j 1 -k '
        cat {} | sed -e "1d" | xargs -I[] echo "{/.}_[]"
    ' |
    # {/.}是parallel命令中的占位符，表示当前处理的文件名（不包括路径和扩展名）
    # -I[]指定替换字符串[]，代表从输入中读取的每个参数，在执行命令时，将[]替换为输入中的每个参数，从而构建一个完整的命令行
    sed -e 's/.lst.groups_/_/' |
    perl -na -F"\t" -MPath::Tiny -e '
        path(qq{subgroup/$F[0].lst})->append(qq{$F[1]});
        # $path = path($filename)函数，用于创建或操作文件或目录的路径
        # append($content)函数，用于将指定的字符串或者字符串引用（scalar reference）追加到一个文件中
    '

# ignore small subgroups(忽略小的亚群)
# 如果*.lst的行数＜5，将其内容写入subgroup/lonely.lst
find subgroup -name "*.lst" | sort |
    parallel -j 1 -k '
        lines=$(cat {} | wc -l)

        if (( lines < 5 )); then
            echo -e "{}\t$lines"
            cat {} >> subgroup/lonely.lst
            rm {}
        fi
    '

# append ccs(追加连通分量)
# 以\t分隔输入行,在subgroup中查找包含字符串"{1}"的文件，并将所有水平空格转换为换行符后追加到${file}指定的文件中
cat ../nr/connected_components.tsv |
    parallel -j 1 --colsep "\t" '
        file=$(rg -F -l  "{1}" subgroup)
        # {1}是占位符，表示parallel命令中的第一个变量，即每个输入行的第一列

        echo {} | tr "[:blank:]" "\n" >> ${file}
        # ${file}用于表示文件名或文件路径等字符串，通常用于向命令中传递文件名或路径等参数
    '

# remove duplicates(去除重复)
# 将每个*.lst排序去重后，重新写入*.lst
find subgroup -name "*.lst" | sort |
    parallel -j 8 '
        cat {} | sort | uniq > tmp.lst
        mv tmp.lst {}
    '

# 查看subgroup目录下所有文件的行数，并从大到小排序
wc -l subgroup/* |  
    sort -nr |
    head -n 3
# 68408 total
# 15812 subgroup/lonely.lst
# 14397 subgroup/6_2.lst

# 去除行首的空格，计算subgroup目录下文件中第一列数值≤10的行数
wc -l subgroup/* |
    perl -pe 's/^\s+//' |
    # \s+表示匹配一个或多个空白字符
    tsv-filter -d " " --le 1:10 |
    wc -l
## 159

# 去除行首的空格，将subgroup目录下文件中第一列数值≥50并满足正则表达式的行以从大到小的顺序写入next.tsv
wc -l subgroup/* |
    perl -pe 's/^\s+//' |
    tsv-filter -d " " --ge 1:50 |
    tsv-filter -d " " --regex '2:\d+' |
    # 筛选第二列满足正则表达式\d+的行
    sort -nr \
    > next.tsv

wc -l next.tsv
## 124

rm -fr job
```

## 4 Plasmid: prepare（准备质粒）

* Split sequences(分割序列)

```bash
mkdir ~/biodata/plasmid/GENOMES
mkdir ~/biodata/plasmid/taxon

cd ~/biodata/plasmid/grouping

# 将"#Serial Group Count Target"标题写入group_target.tsv
echo -e "#Serial\tGroup\tCount\tTarget" > ../taxon/group_target.tsv


cat next.tsv |
    cut -d" " -f 2 |
    parallel -j 8 -k --line-buffer '
        echo >&2 "==> {}"

        GROUP_NAME={/.}
        TARGET_NAME=$(head -n 1 {}   | perl -pe "s/\.\d+//g")
        # \d+表示匹配一个或多个数字，\.表示匹配.

        SERIAL={#}
        # {#}表示当前循环的计数器值
        COUNT=$(cat {} | wc -l)

        echo -e "${SERIAL}\t${GROUP_NAME}\t${COUNT}\t${TARGET_NAME}" >> ../taxon/group_target.tsv

        faops order ../nr/refseq.fa {} stdout |
            faops filter -s stdin stdout \
            # 简化序列名称， >NC_000937.1 变为 >NC_000937
            > ../GENOMES/${GROUP_NAME}.fa
    '

cat next.tsv |
    cut -d" " -f 2 |
    parallel -j 8 -k --line-buffer '
        echo >&2 "==> {}"
        GROUP_NAME={/.}
        faops size ../GENOMES/${GROUP_NAME}.fa > ../taxon/${GROUP_NAME}.sizes
    '

# Optional: RepeatMasker
#egaz repeatmasker -p 12 ../GENOMES/*.fa -o ../GENOMES/

# split-name
find ../GENOMES -maxdepth 1 -type f -name "*.fa" | sort |
    parallel -j 8 '
        faops split-name {} {.}
    '

# mv to dir of basename
find ../GENOMES -maxdepth 2 -mindepth 2 -type f -name "*.fa" | sort |
    parallel -j 8 '
        mkdir -p {.}
        mv {} {.}
    '

```

* `prepseq`

```bash
cd ~/biodata/plasmid/

cat taxon/group_target.tsv |
    sed -e '1d' |
    parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 8 '
        echo -e "==> Group: [{2}]\tTarget: [{4}]\n"

        for name in $(cat taxon/{2}.sizes | cut -f 1); do
            egaz prepseq GENOMES/{2}/${name}
        done
    '
```

* Check outliers of lengths(检查长度的异常值)

```bash
cd ~/biodata/plasmid/

cat taxon/*.sizes | cut -f 1 | wc -l
# 43629


cat taxon/*.sizes | cut -f 2 | paste -sd+ | bc
# 3476125393

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
# 43235

cat taxon/*.sizes | cut -f 2 | paste -sd+ | bc
# 3467737064

```

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/plasmid/ \
    wangq@202.119.37.251:data/plasmid    # 未执行

# rsync -avP wangq@202.119.37.251:data/plasmid/ ~/data/plasmid
```

## 5 Plasmid: run（处理质粒）

```bash
cd ~/biodata/plasmid/

cat taxon/group_target.tsv |
    sed -e '1d' | grep "^53" |
    # 删除标题行，过滤"53"开头的行

    parallel --colsep '\t' --no-run-if-empty --linebuffer -k -j 1 '
        echo -e "==> Group: [{2}]\tTarget: [{4}]\n"

        egaz template \
            GENOMES/{2}/{4} \
            $(cat taxon/{2}.sizes | cut -f 1 | grep -v -x "{4}" | xargs -I[] echo "GENOMES/{2}/[]") \
            --multi -o groups/{2}/ \
            --order \
            --parallel 8 -v

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

