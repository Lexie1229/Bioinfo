# [RNA-seq 分析](https://github.com/eternal-bug/RNA)
## 0 介绍
```
    read                                     ----
*   read              ----                 ----
*   read             ----                 ----
*   read      :    ----       ----       ----
+   genome    : =======================================
+   annotation:   |-gene1-|  |-gene2-|  |-gene3-|
```
RNA-seq 的功能：  
① 获得差异表达基因(最为常见)；  
② 分析SNP、新颖的转录本、可变剪接、RNA编辑等。

* 分析流程的结构仿照[`Tom Battaglia`](https://github.com/twbattaglia)
```bash
      database                   Workflow                        tools
======================================================================================
  
+=================+     +-------------------------+                               
|     database    |     |      Quality Analysis   |---------------> fastqc 
+=================+     +-------------------------+                                
|+------+         |                 v                                      
|| rRNA |---------|--+  +-------------------------+
|+------+         |  |  | Base Quality Filtering  |------------> TrimGalore
|  +------+       |  |  +-------------------------+
|  |genome|-------|-+|              v
|  +------+       | ||  +-------------------------+
|     +----------+| |+->| rRNA Sequence Filtering |------------> SortMeRNA
|     |  Genome  || |   +-------------------------+
|     |Annotation|| |               v
|     +----------+| |   +-------------------------+
|          |      | +-->|   Genome Alignment      |------------> hisat2
+----------|------+     +-------------------------+
           |                        v
           |            +-------------------------+
           +----------->|  Count Mapped Reads     |------------> HTseq
                        +-------------------------+
                                    v
                        +-------------------------+
                        | Differential Expression |------------> DESeq2
                        +-------------------------+
                                    v
                        +-------------------------+
                        |     Pathway analysis    |------------> ClusterProfiler
                        +-------------------------+
```

## 1 目录创建
进行数据处理之前，先生成整体的目录结构，便于数据存放及查找文件，并且程序运行时能明确地填写文件路径。  

```bash
# 切换用户目录
cd ~

# 新建bisoft文件夹存放生物软件工具
mkdir biosoft

# 新建project文件夹（包含大鼠文件夹）
mkdir -p project/rat

# 进入rat目录
cd project/rat

# 新建多个文件夹存放各类文件
mkdir annotation genome sequence output script
```
| 文件夹名 | 说明 |
| ---| --- |
| annotation | 存放注释文件(.gff .bed .gff3) |
| genome | 存放基因组与索引文件(.fa .bt)|
| sequence | 存放测序数据(.fastq.gz) |
| output | 存放各种处理的输出文件 |
| script | 存放脚本的位置 |

使用`tree`命令查看设置的目录结构
```bash
# 进入rat目录
cd ~/project/rat

# 安装tree
sudo apt install tree

# 更新apt
sudo apt update  

# 查看目录结构
tree  

.
├── annotation  用于存放大鼠的基因组注释信息(.gff/gtf)
├── genome      用于存放大鼠的基因组数据(.fasta)
├── output      用于存放处理后的数据
├── script      用于部分脚本
└── sequence    用于存放测序原始数据
```

## 2 工具下载
### 2.0 生信管理工具

* Linuxbrew
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

if grep -q -i linuxbrew $HOME/.bashrc; then
    echo "==> .bashrc already contains linuxbrew"
else
    echo "==> Update .bashrc"

    echo >> $HOME/.bashrc
    echo '# Linuxbrew' >> $HOME/.bashrc
    echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >> $HOME/.bashrc
    echo "export MANPATH='$(brew --prefix)/share/man'":'"$MANPATH"' >> $HOME/.bashrc
    echo "export INFOPATH='$(brew --prefix)/share/info'":'"$INFOPATH"' >> $HOME/.bashrc
    echo "export HOMEBREW_NO_ANALYTICS=1" >> $HOME/.bashrc
    echo "export HOMEBREW_NO_AUTO_UPDATE=1" >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source $HOME/.bashrc
```

* conda：用于安装和管理生信相关的工具。    
```bash
# 下载脚本
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh

# 安装conda
bash miniconda.sh

# 配置conda
conda config --add channels conda-forge
conda config --add channels defaults
conda config --add channels r
conda config --add channels bioconda

# 建立python3.6的环境 
conda create --name python36 python=3.6
```

NOTE   
conda：管理和部署应用程序、环境和软件包的工具。
* conda command
     * config：修改.condarc文件中的配置值。
       * --add channels conda-canary：添加软件源，具有优先级。
     * create：创建新的conda环境。
       * -n ENVIRONMET (--name ENVIRONMENT) Name of environment
    * info：显示当前conda安装的信息。

### 2.1 sratoolkit
SRA Toolkit：NCBI提供的用于下载数据(.sra)及转换数据格式（.fastq.gz)的工具，整合了prefetch、fastq-dump、sam-dump工具.

```bash
# 使用brew安装
brew install sratoolkit
```

|      | 站点 |
| --- | --- |
| 官网 | https://www.ncbi.nlm.nih.gov/sra/ |

### 2.2 fastqc
FastQC：用于测序数据的质量控制。

```bash
# 使用brew安装
brew install fastqc
```

|     | 站点 |
| --- | --- |
| 官网 | http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ |
| 手册 | http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/ |
| 中文解释 | https://www.plob.org/article/5987.html |

### 2.3 multiqc
MultiQC:将测序数据的fastqc统计结果整合成一个HTLM可视化文件，并可以导出pdf文件，便于查看测序数据的质控结果。

```bash
# 使用Python的安装器安装
pip install multiqc
```

|      | 站点 |
| --- | --- |
| 官网 |  https://multiqc.info/ |
| 文档 | https://multiqc.info/docs/ |

### 2.4 cutadapt
cutadapt：用于去除任意指定的接头和序列，同时可以用于质量过滤。

```bash
# 使用Python的安装器安装
pip install cutadapt
```

|      | 站点 |
| --- | --- |
| 手册 | https://cutadapt.readthedocs.io/en/stable/guide.html |

### 2.5 质量修剪
* Trim Galore
Trim Galore：使用perl脚本编写的工具，是对`cutapat`和`fastqc`命令的封装，可以自动检测接头并调用`cutapat`去除。

```bash
cd ~/biosoft

wget https://github.com/FelixKrueger/TrimGalore/archive/0.6.3.tar.gz -O TrimGalore.gz

gzip -d TrimGalore.gz
```

| Trim Galore | 站点                                                         |
| ----------- | ------------------------------------------------------------ |
| 官网        | https://github.com/FelixKrueger/TrimGalore/blob/master/Docs/Trim_Galore_User_Guide.md |
| 手册        | https://github.com/FelixKrueger/TrimGalore/blob/master/Docs/Trim_Galore_User_Guide.md |

* trimmomatic
trimmomatic：是多线程命令行工具，用来修剪Illumina (FASTQ)数据以及删除接头，是目前使用最多的高通量测序数据清洗的工具。

```bash
cd ~/biosoft

wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip

unzip Trimmomatic-0.38.zip

cd Trimmomatic-0.38

# 导入临时环境变量
export PATH="$(pwd):$PATH"
```

|   | 站点 |
| --- | --- |
| 官网 |  http://www.usadellab.org/cms/index.php?page=trimmomatic |
| 手册 | http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf |

* fastp

### 2.6 hisat2
hisat2：取代bowtie2和tophat程序，能够将RNA-Seq的读取与基因组进行快速比对，在RNA-seq中使用较多。

* 安装
  * 浏览器进入`hisat2`[官网](https://ccb.jhu.edu/software/hisat2/index.shtml)，根据系统版本选择对应的安装版本；
  * 选择[Linux_x86_64 HISAT2 2.2.1](https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download)，右键复制链接。
  * 参考文献：Kim D, Langmead B and Salzberg SL. [**HISAT: a fast spliced aligner with low memory requirements**](http://www.nature.com/nmeth/journal/vaop/ncurrent/full/nmeth.3317.html). _[Nature Methods](http://www.nature.com/nmeth)_2015

```bash
# 下载
cd ~/biosoft/
wget https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download

# 解压
unzip downlosd
cd hisat2-2.2.1

# 导入临时环境变量
export PATH="~/biosoft/hisat2-2.2.1:$PATH"

# 测试是否可用
hisat2 -h
```

|        | 站点 |
| --- | --- |
| 官网 | https://ccb.jhu.edu/software/hisat2/index.shtml |
| 手册 | https://ccb.jhu.edu/software/hisat2/manual.shtml |

### sortmerna [选做]
sortmerna：RNA测序中有很多是rRNA，sortmerna是将高通量的测序中的rRNA进行剔除的软件。

```bash
# 下载
cd ~/biosoft/
wget https://github.com/biocore/sortmerna/archive/2.1.tar.gz -O sortmerna-2.1.tar.gz

# 解压
tar -xzvf sortmerna-2.1.tar.gz
cd sortmerna-2.1

# 配置相关信息
./configure --prefix=$PWD

# 编译
make -j 4

# 查看是否成功
./sortmerna --help

# 导入到环境变量
export PATH="$(pwd):$PATH"

# 将数据库文件移动到方便寻找的位置
mkdir -p ~/project/rat/database/sortmerna_db/rRNA_databases
mv ./rRNA_databases/ ~/project/rat/database/sortmerna_db/rRNA_databases

# 相关库文件
cd ~/biosoft/sortmerna-2.1
sortmerna_ref_data=$(pwd)/rRNA_databases/silva-bac-16s-id90.fasta,$(pwd)/index/silva-bac-16s-db:\
$(pwd)/rRNA_databases/silva-bac-23s-id98.fasta,$(pwd)/index/silva-bac-23s-db:\
$(pwd)/rRNA_databases/silva-arc-16s-id95.fasta,$(pwd)/index/silva-arc-16s-db:\
$(pwd)/rRNA_databases/silva-arc-23s-id98.fasta,$(pwd)/index/silva-arc-23s-db:\
$(pwd)/rRNA_databases/silva-euk-18s-id95.fasta,$(pwd)/index/silva-euk-18s-db:\
$(pwd)/rRNA_databases/silva-euk-28s-id98.fasta,$(pwd)/index/silva-euk-28s-db:\
$(pwd)/rRNA_databases/rfam-5s-database-id98.fasta,$(pwd)/index/rfam-5s-db:\
$(pwd)/rRNA_databases/rfam-5.8s-database-id98.fasta,$(pwd)/index/rfam-5.8s-db

# 真核生物的rRNA不需要那么多(5s, 5.8s, 18s, 28s)
euk_rNRA_ref_data=$(pwd)/rRNA_databases/silva-euk-18s-id95.fasta,$(pwd)/index/silva-euk-18s-db:\
$(pwd)/rRNA_databases/silva-euk-28s-id98.fasta,$(pwd)/index/silva-euk-28s-db:\
$(pwd)/rRNA_databases/rfam-5s-database-id98.fasta,$(pwd)/index/rfam-5s-db:\
$(pwd)/rRNA_databases/rfam-5.8s-database-id98.fasta,$(pwd)/index/rfam-5.8s-db

# 建立数据库索引
indexdb_rna --ref $data
```
|   |  站点 |
| --- | --- |
| 官网 | https://bioinfo.lifl.fr/RNA/sortmerna/ |
| 手册 | https://bioinfo.lifl.fr/RNA/sortmerna/code/SortMeRNA-user-manual-v2.1.pdf |
| github | https://github.com/biocore/sortmerna/blob/master/README.md |
| 中文解读 | https://www.jianshu.com/p/6b7a442d293f |

### 2.7 samtools
samtools：对比对后得到的文件（sam或bam文件）进行二进制查看、格式转换、排序、合并等操作的工具。

```bash
# 使用brew安装
brew install samtools
```

|   |  站点 |
| --- | --- |
| 官网 | http://www.htslib.org/ |
| 手册 | http://quinlanlab.org/tutorials/samtools/samtools.html |
| 中文解读 | https://www.jianshu.com/p/6b7a442d293f |

### 2.8 HTseq
HTseq：对比对后的文件进行reads计数。

```bash
# 使用Python的安装器安装
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple HTseq
```

### 2.9 R
R语言集合了多种生物信息学的分析工具，其中RNA-seq分析的工具更是丰富，R语言最擅长统计学分析，用于后续的基因表达量分析、差异分析以及作图等。

* 安装
  * 进入[R](https://www.r-project.org)官网，点击`CRAN`，找到`china`站点，点击[清华的站点](https://mirrors.tuna.tsinghua.edu.cn/CRAN/)，下载对应系统版本的安装包，然后双击安装包安装。

```bash
# 使用brew安装
brew install r
```

### 2.10 Rstudio
因为R自身的界面使用不方便、不美观，因此使用Rstudio提升R的显示效果以及发挥其他功能。

* 安装
  * 进入[官网](https://www.rstudio.com/products/rstudio/download/),下载对应系统版本的安装包，然后双击安装包安装。

**Tips**：完成`R`的安装后再安装`Rstudio`

### 2.11 parallel
parallel：进行多线程运行的工具，并行运行可以提升效率，节省时间.

```bash
# 使用brew安装
brew install parallel
```

### StringTie[可选]
Stringtie:能够应用流神经网络算法和可选的de novo组装进行转录本组装并预计表达水平，与Cufflinks等程序相比，StringTie实现了更完整、更准确的基因重建，并更好地预测了表达水平。

```bash
# 下载
cd ~/biosoft
wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz

# 解压
tar -xzvf stringtie-2.2.1.Linux_x86_64.tar.gz
mv stringtie-2.2.1.Linux_x86_64 stringtie-2.2.1
cd stringtie-2.2.1

# 导入环境变量
export PATH="$(pwd):$PATH"

# 测试是否可用
stringtie --help
```

|  | 站点 |
| --- | --- |
| 官网 | http://ccb.jhu.edu/software/stringtie/ |
| 手册 | http://ccb.jhu.edu/software/stringtie/index.shtml?t=manual |
| 中文解读 | https://www.plob.org/article/12865.html |

### Ballgown[可选]
Ballgown:R语言中基因差异表达分析的工具，能利用RNA-Seq实验的数据(StringTie, RSEM, Cufflinks)的结果预测基因、转录本的差异表达。

```R
# R<3.5.0
source("http://bioconductor.org/biocLite.R")
biocLite("Ballgown")
# R>3.5.0
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("ballgown")
```

## 3 数据下载
使用大鼠的测序数据进行测试。大鼠又叫大白鼠（Rat，Rattus norvegicus），是非常重要的模式生物之一，因其与人类存在高度的同源性及其优良的品系资源，被广泛应用于毒理学、神经病学，细胞培养等研究。在`ENSEMBL`和`UCSC`中均有其基因组数据。

### 3.1 参考数据
基于`ENSEMBL`平台，下载参考基因组序列及基因组注释文件。
  * 进入[ENSEMBL](https://www.ensembl.org/index.html)网站，在`All genomes`中选择物种`Rat`；
  * 点击[Download DNA sequence (FASTA)](https://ftp.ensembl.org/pub/release-108/fasta/rattus_norvegicus/dna/)，进入基因组序列数据列表，下载[完整的基因组序列](https://ftp.ensembl.org/pub/release-108/fasta/rattus_norvegicus/dna/Rattus_norvegicus.mRatBN7.2.dna.toplevel.fa.gz)；
  * 点击[Download GTF](https://ftp.ensembl.org/pub/release-108/gtf/rattus_norvegicus/) files for genes, cDNAs, ncRNA, proteins，下载[基因组注释文件](https://ftp.ensembl.org/pub/release-108/gtf/rattus_norvegicus/Rattus_norvegicus.mRatBN7.2.108.gtf.gz)。

```bash
# 下载参考基因组序列
cd ~/project/rat/genome
wget https://ftp.ensembl.org/pub/release-108/fasta/rattus_norvegicus/dna/Rattus_norvegicus.mRatBN7.2.dna.toplevel.fa.gz
gzip -d Rattus_norvegicus.mRatBN7.2.dna.toplevel.fa.gz
## 改名（方便使用，避免输错）
mv Rattus_norvegicus.mRatBN7.2.dna.toplevel.fa genome.fa

# 下载基因组注释文件
cd ~/project/rat/annotation
wget https://ftp.ensembl.org/pub/release-108/gtf/rattus_norvegicus/Rattus_norvegicus.mRatBN7.2.108.gtf.gz
gzip -d Rattus_norvegicus.mRatBN7.2.108.gtf.gz
## 改名
mv Rattus_norvegicus.mRatBN7.2.108.gtf annotation.gtf
```

* 查看基因组文件(包含的染色体），确认文件是否下载正确。除`1-20`+`X`+`Y`+`MT`之外还有很多别的ID名，均为`scaffold`。

```bash
cat genome.fa | grep "^>" 

>1 dna:primary_assembly primary_assembly:mRatBN7.2:1:1:260522016:1 REF
>2 dna:primary_assembly primary_assembly:mRatBN7.2:2:1:249053267:1 REF
...
>20 dna:primary_assembly primary_assembly:mRatBN7.2:20:1:54435887:1 REF
>X dna:primary_assembly primary_assembly:mRatBN7.2:X:1:152453651:1 REF
>Y dna:primary_assembly primary_assembly:mRatBN7.2:Y:1:18315841:1 REF
>MT dna:primary_assembly primary_assembly:mRatBN7.2:MT:1:16313:1 REF
>MU150191.1 dna:primary_assembly primary_assembly:mRatBN7.2:MU150191.1:1:1794995:1 REF
>MU150189.1 dna:primary_assembly primary_assembly:mRatBN7.2:MU150189.1:1:1402623:1 REF
>MU150194.1 dna:primary_assembly primary_assembly:mRatBN7.2:MU150194.1:1:648519:1 REF
...
```

* 每条染色体名称后的描述信息是当前的组装版本、长度等，但这些信息会妨碍后续使用脚本进行统计或分析，因此最好去掉这些信息。

```bash
# 更改文件名称
mv genome.fa genome.raw.fa

# 去除染色体名称后的描述信息
cat genome.raw.fa | perl -n -e 'if(m/^>(.+?)(?:\s|$)/){ print ">$1\n";}else{print}' > genome.fa

# 删除原文件
rm genome.raw.fa
```

* 使用脚本统计每条染色体的长度

```bash
cat genome.fa | perl -n -e '
    s/\r?\n//;
    if(m/^>(.+?)\s*$/){
        $title = $1;
        push @t, $title;
    }elsif(defined $title){
        $title_len{$title} += length($_);
    }
    END{
        for my $title (@t){
            print "$title","\t","$title_len{$title}","\n";
        }
    }
'

1       260522016
2       249053267
...
20      54435887
X       152453651
Y       18315841
MT      16313
MU150191.1      1794995
MU150189.1      1402623
MU150194.1      648519
...
```

* 因数据较大，后续则以1号染色体的基因组数据为例，进行比对。

```bash
cat genome.fa | perl -n -e '
  if(m/^>/){
    if(m/>1$/){
      $title = 1;
    }else{
      $title = 0;
    }
  }else{
    push @s, $_ if $title;
  }
  END{
    printf ">1\n%s", join("", @s);
  }
' > genome.chr1.fa
```

* 基因组数据说明

```bash
#  基因组数据的格式为`.fasta`，简单明了，具体为：
>seq_id
AGCTGAGCTAGCTACGGAGCTGAC
ACGACTGATCTGACGTTGATCGTT
# 以 > 开头的为序列名称，接着的AGCT... 为序列信息
# 基因组`fasta`文件记录大鼠所有被测得的染色体序列信息，目前已经更新到`version 6` ，目前一般简称为`rn6`。
```

* 注释数据说明

```bash
# 使用head查看部分基因组注释文件
head -7 annotatin.gtf

#!genome-build mRatBN7.2  
#!genome-version mRatBN7.2  
#!genome-date 2020-11  
#!genome-build-accession GCA_015227675.2  
#!genebuild-last-updated 2021-02  
1       ensembl gene    36112690        36122387        .       -       .       gene_id "ENSRNOG00000066169"; gene_version "1"; gene_source "ensembl"; gene_biotype "protein_coding";  
1       ensembl transcript      36112690        36122387        .       -       .    gene_id "ENSRNOG00000066169"; gene_version "1"; transcript_id "ENSRNOT00000101581"; transcript_version "1"; gene_source "ensembl"; gene_biotype "protein_coding"; transcript_source "ensembl"; transcript_biotype "protein_coding"; tag "Ensembl_canonical";
# 开头描述注释数据的基本信息，如版本号、更新时间，组装的NCBI的Assembly编号等
# 后面每行表示描述信息，说明了在哪条染色体的什么位置是什么东西。例如，第6行表示1号染色体反义链的36112690-36122387位置存在基因编号为ENSRNOG00000066169的基因
```


* 下载基因组索引文件 [**可选**]  

在[`hisat2`](http://daehwankimlab.github.io/hisat2/) 官网可以找到已经建立好索引的大鼠基因组文件，可以直接下载索引文件。

```bash
cd ~/project/rat/genome
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/rn6.tar.gz
gzip -d rn6.tar.gz
```

### 3.2 实验数据
下载NCBI的`RNA-seq`数据，GEO数据库编号`GSE72960`，SRP数据编号`SRP063345`，文献来源：[肝硬化分子肝癌的器官转录组分析和溶血磷脂酸途径抑制 - 《Molecular Liver Cancer Prevention in Cirrhosis by Organ Transcriptome Analysis and Lysophosphatidic Acid Pathway Inhibition》](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5161110/)

* 数据下载流程：  
  * 进入[NCBI-GEO](https://www.ncbi.nlm.nih.gov/geo)页面，`GEO accession`搜索框中输入`GSE72960`，显示该基因表达数据集的描述信息。例如：`SPR SRP063345`表示测序文件的SRA编号；`PMID:27960085`表示PubMed标识码，链接文献。
  * 点击页面下方`SRA Run selector`，显示8个样本的测序信息及对应的`SRA编号`（6个实验组样本+2个对照组样本），通过编号下载测序数据（或点击`Accession List`下载`SRR_Acc_List.txt`文件，包含所有的`SRA编号`）。
  * 根据`SRA编号`或`SRR_Acc_List.txt`文件，使用`SRAToolkit`工具包中的`prefetch`工具下载测序数据，若部分下载失败则重新执行代码。
  * 使用`SRAToolkit`工具包中的`fastq-dump`工具，将下载的数据`.sra`转换为`.fastq.gz`格式。

```bash
# 进入~/project/rat/sequence目录
cd ~/project/rat/sequence

# 直接下载到当前目录(.)
prefetch SRR2190795 SRR224018{2..7} SRR2240228 -O .
# 后台不挂断下载
nohup prefetch SRR2190795 SRR224018{2..7} SRR2240228 -O . &
# 查看下载进度
jobs
# 利用list.txt文件批量下载
prefetch --option-file list.txt

# 将sra格式转换为fastq格式后压缩为gz文件,节省内存
parallel -j 4 "
    fastq-dump --split-3 --gzip {1}
" ::: $(ls *.sra)

# 删除sra文件
rm *.sra
```

* fastq格式说明

```bash
cd ~/project/rat/sequence
gzip -d -c SRR2190795.fastq.gz | head -n 4

@SRR2190795.1 HWI-ST1147:240:C5NY7ACXX:1:1101:1320:2244 length=100
ATGCTGGGGGCATTAGCATTGGGTACTGAATTATTTTCAGTAAGAGGGAAAGAATCCATCTCCNNNNNNNNNNNNNNNNNNNNNNAAANAAAAATAAAAT
+SRR2190795.1 HWI-ST1147:240:C5NY7ACXX:1:1101:1320:2244 length=100
CCCFFFFFHHHHHJIJJJJJJJJDHHJJJIJJJJJIJJJJJJJJJJJJJJJJJJJJJJJJJHH#####################################
```

NOTE   
prefetch：用于从NCBI下载SRA文件。
* prefetch [options] [accessions(s)]
  * -o(--output-file) <file>:write file to <file> when downloading
single file. 
  * -O(--output-directory) <directory>:save files to <directory>/.
  * --option-file file：read more options and parameters from the file.
  * -p(--progress):show progress.

fastq-dump：
* fastq-dump [options] [accessions(s)]
  * --split-3:3-way splitting for mate-pairs.
  * --gzip：compress output using gzip.

parallel:用于构建并行运行命令。
* parallel [options] [command [arguments]] (::: arguments|:::: argfile(s))
  * -j(--jobs) n：run n jobs in parallel.
  * -k：keep same order.
  * --pipe：split stidn to multiple jobs.

## 4 质量控制
### 4.1 质量评估
在序列比对之前需要查看测序数据的测序质量，因为不同来源的测序数据的测序质量不同，为保证后续分析的有效性和可靠性，需要进行质量评估，使用`fastqc`进行质量评估。

```bash
cd ~/project/rat/sequence

# 新建目录，用于存放评估结果
mkdir -p ../output/fastqc

# 质量评估
fastqc -t 4 -o ../output/fastqc *.gz
# -t 指定线程数
# -o 指定输出文件夹
# *.gz 表示这个目录下以 .gz 的所有文件
```

* 运行过程中会先显示分析进程，完成之后会生成分析报告。

```bash
cd ~/project/rat/output/fastqc
ls

# 结果
SRR2190795_fastqc.html SRR2240184_fastqc.html SRR2240187_fastqc.html
SRR2190795_fastqc.zip  SRR2240184_fastqc.zip  SRR2240187_fastqc.zip
...

# .html文件使用浏览器打开，查看质量评估结果
firefox SRR2190795_fastqc.html
```

* 因为有多份报告，查看不方便，使用`multiqc`将所有的fastqc检测报告合并为一个文件。

```bash
cd ~/project/rat/output/fastqc
multiqc .
firefox multiqc_report.html
```

* 有关fastq的报告解读，参考[用FastQC检查二代测序原始数据的质量](https://www.plob.org/article/5987.html)。 绿色表示通过，红色表示未通过，黄色表示不太好。一般，RNA-Seq数据在sequence deplication levels未通过是比较正常的，因为一个基因大量表达，则会测到很多遍。
  * 平均GC含量（Per Sequence GC Content)：
    * 查看测序总的GC含量，GC含量说明当前测序是否有很大问题，如果偏差较大，则可能出现测序偏好性（绿色是理论值，黄色是实际值），因为是转录组，所以可能出现部分序列偏多的情况。
  * 所有测序文件的质量（Sequence Quality Histograms）：
    * 开头10bp之前和70bp之后，出现质量值低于30（99.9%）的情况，说明测序的序列两端部分序列质量一般，需要剔除。
  * 查看平均质量值的reads数量（Per Sequence Quality Scores）：
    * 平均质量低于20的reads处可以看到曲线存在，说明其中存在质量很低的reads，后续需要进行剔除。
  * 接头情况（Adapter Content）：
    * 显示通过，但是部分可能包含几个碱基的接头序列，进行剔除接头。

### 4.2 剔除接头以及测序质量差的碱基
fastqc的接头情况显示部分reads有4个碱基与接头序列匹配，属于Illumina的通用接头，并且测序质量显示`5'`端（10 bp之前）存在低质量的测序区域。因此，使用`trimmomatic`去除两端的低质量区域。

```bash
cd ~/project/rat/sequence

# 新建目录
mkdir -p ../output/adapter/

# 循环处理sequence文件夹的文件
for i in $(ls *.fastq.gz);
do
    cutadapt -a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT \
    --minimum-length 30 --overlap 4 --trim-n \
    -o ../output/adapter/${i}  ${i}
    # --minimum-length 如果剔除接头后reads长度低于30，则丢弃该reads
    # --overlap        如果两端的序列与接头有4个碱基的匹配则会被剔除
    # --trim-n         剔除两端的N
done
```

### 4.3 去除低质量区域

```bash
cd ~/project/rat/output/adapter/
mkdir ../trim

parallel -j 4 "
  java -jar ~/biosoft/Trimmomatic-0.38/trimmomatic-0.38.jar \
    SE -phred33 {1} ../trim/{1} \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:5:15 MINLEN:30 \
  # LEADING:20，从序列的开头开始去掉质量值小于20的碱基
  # TRAILING:20，从序列的末尾开始去掉质量值小于20的碱基
  # SLIDINGWINDOW:5:15，从5'端开始以5bp的窗口计算碱基平均质量，如果此平均值低于15，则从这个位置截断reads
  # MINLEN:30，如果reads长度小于30bp，则扔掉整条reads
" ::: $( ls *.gz)
```

### 4.4 查看质量情况
```bash
cd ~/project/rat/output/trim
mkdir ../fastqc_trim
parallel -j 4 "
    fastqc -t 4 -o ../fastqc_trim {1}
" ::: $(ls *.gz)

cd ../fastqc_trim
multiqc .
```

## 5 去除rRNA序列[选做]
在提取RNA的过程中没有对RNA进行筛选的情况下，得到的大部分为`rRNA`，可能影响后续的分析，并且增加分析时间。

**Tips**：使用`sortmerna`时，需要**未压缩的测序文件**。

```bash
cd ~/project/rat/output
mkdir -p ./rRNA/discard

cd trim
parallel -j 4 "
  # 解压测序文件
  gzip -d {1}*.fa.gz
  
  # euk_rNRA_ref_data就是之前安装sortmerna的时候定义的数据库文件
  # --reads  : 测序文件
  # --aligned: 与rRNA数据库能比对上的序列(后续不需要的)
  # --other  : 与rRNA数据库不能比对上的序列(后续需要的)
  # --fastx  : 输出fastq文件
  # --log    : 生成日志文件
  # -a       : 线程数
  # -v       : 吵闹模式
  
  # 注意--aligned和--other后接文件名前缀，不用在加什么 .fq 或者 .fastq之类的，否则将会生成 xxx.fq.fq
  sortmerna \
    --ref $euk_rNRA_ref_data \
    --reads {1}*.fq \
    --aligned ../rRNA/discard/{1} \
    --other ../rRNA/{1} \
    --fastx \
    --log \
    -a 4 \
    -v
  
  # 压缩fastq文件
  gzip ../rRNA/{1}.fq
  gzip ../rRNA/discard/{1}.fq
" ::: $(ls *.fq.gz | perl -n -e 'print $1."\n" if m/(.+?)_/')
```

## 6 序列比对
将reads定位到它在基因组所处的位置，通过比对reads所属的基因，对基因的表达进行定量。此外，RNA-seq的序列与基因组的序列有时可能不一致，因为存在内含子与外显子的差别，而RNA-seq测的是RNA序列，所以会出现跨区段的序列比对。

### 6.1 建立索引
使用`hisat2`的`hisat2-build`工具建立索引。

```bash
cd ~/project/rat/genome
mkdir index
cd index

# 建立索引
hisat2-build -p 4 ../genome.chr1.fa genome.chr1
```

* 运行过程中显示部分信息提示，包含建立索引文件的分块情况及运行时间的统计。完成后，`~/project/rat/genome/index`会生成8个文件，即对基因组进行压缩后的文件，将基因组序列数据分块成了8份，在序列比对的时候直接使用这些文件而不是基因组`genome.chr1.fa`文件。

```
genome.chr1.1.ht2  
genome.chr1.2.ht2
...
genome.chr1.8.ht2
```

### 6.2  序列比对
使用`hasat2`进行序列比对。

```bash
cd ~/project/rat/output
mkdir align
cd trim

# hisat2语法
hisat2 [选项] -x [索引文件] [-1 1测序文件 -2 2测序文件 -U 未成对测序文件] [-S 输出的sam文件]

parallel -k -j 4 "
    hisat2 -t -x ../../genome/index/genome.chr1 \
      -U {1}.fastq.gz -S ../align/{1}.sam \
      2>../align/{1}.log
" ::: $(ls *.gz | perl -p -e 's/.fastq.gz$//')
```

* 比对完成后，可以查看日志信息，显示序列比对的时间和比对情况。

```bash
cd ~/project/rat/output/align
cat SRR2190795.log

# 结果
Time loading forward index: 00:00:01
Time loading reference: 00:00:00
Multiseed full-index search: 00:08:31
14998487 reads; of these:
  14998487 (100.00%) were unpaired; of these:
    13419407 (89.47%) aligned 0 times
    1482355 (9.88%) aligned exactly 1 time
    96725 (0.64%) aligned >1 times
10.53% overall alignment rate
Time searching: 00:08:32
Overall time: 00:08:33
# 比对率为10.53%，一般全基因组比对的比对率可达到95%以上，此处仅比对chr1。
```

* 总结比对情况，写一个脚本统计序列比对率和时间。

```bash
cd ~/project/rat/output/align
file_list=($(ls *.log))

echo -e "sample\tratio\ttime"
for i in ${file_list[@]};
do
    prefix=$(echo ${i} | perl -p -e 's/\.log//')
    echo -n -e "${prefix}\t"
    cat ${i} |
      grep -E "(overall alignment rate)|(Overall time)" |
      perl -n -e '
        if(m/alignment/){
          $hash{precent} = $1 if m/([\d.]+)%/;
        }elsif(m/time/){
          if(m/(\d\d):(\d\d):(\d\d)/){
            my $time = $1 * 60 + $2 + $3 / 60;
            $hash{time} = $time;
          }
        }
        END{
          $hash{precent} = "NA" if not exists $hash{precent};
          $hash{time} = "NA" if not exists $hash{time};
          printf "%.2f\t%.2f\n", $hash{precent}, $hash{time};
        }
      '
done
```

* 格式转化与排序
SAM格式是目前用来存放大量核酸比对结果信息的通用格式，是能够“直接”阅读的格式类型，而BAM和CRAM是为了方便传输，降低存储压力而压缩SAM得到的格式形式。bam文件是sam文件的二进制格式，可以减小文件的存储。利用samtools将sam格式比对文件转换为bam格式并排序，并对其建立索引，生成.bai文件。

```bash
cd ~/project/rat/output/align
parallel -k -j 4 "
    samtools sort -@ 4 {1}.sam > {1}.sort.bam
    samtools index {1}.sort.bam
" ::: $(ls *.sam | perl -p -e 's/\.sam$//')

rm *.sam
ls
```

## 7. 表达量统计
使用HTSEQ-count工具的union模型（HTSEQ-count提供了union，intersection_strict，intersection_nonempty 3 种模型）判断reads所属的基因，具体为给定一个包含比对信息的sam文件和一个包含基因组特征的gff文件，统计每个特征对应的reads数量。

```bash
cd ~/project/rat/output
mkdir HTseq
cd align

# 语法
htseq-count [options] <alignment_files> <gff_file>

parallel -j 4 "
    htseq-count -s no -f bam {1}.sort.bam ../../annotation/annotation.gtf \
      >../HTseq/{1}.count  2>../HTseq/{1}.log
" ::: $(ls *.sort.bam | perl -p -e 's/\.sort\.bam$//')
```

* 参数说明

| 参数 | 说明 |
| --- | --- |
| -f --format | default: sam 设置输入文件的格式，该参数的值可以是sam或bam。|
| -r --order | default: name 设置sam或bam文件的排序方式，该参数的值可以是name或pos。前者表示按read名进行排序，后者表示按比对的参考基因组位置进行排序。若测序数据是双末端测序，当输入sam/bam文件是按pos方式排序的时候，两端reads的比对结果在sam/bam文件中一般不是紧邻的两行，程序会将reads对的第一个比对结果放入内存，直到读取到另一端read的比对结果。因此，选择pos可能会导致程序使用较多的内存，它也适合于未排序的sam/bam文件。而pos排序则表示程序认为双末端测序的reads比对结果在紧邻的两行上，也适合于单端测序的比对结果。很多其它表达量分析软件要求输入的sam/bam文件是按pos排序的，但HTSeq推荐使用name排序，且一般比对软件的默认输出结果也是按name进行排序的。|
| -s --stranded | default: yes 设置是否是链特异性测序。该参数的值可以是yes,no或reverse。no表示非链特异性测序；若是单端测序，yes表示read比对到了基因的正义链上；若是双末端测序，yes表示read1比对到了基因正义链上，read2比对到基因负义链上；reverse表示双末端测序情况下与yes值相反的结果。根据说明文件的理解，一般情况下双末端链特异性测序，该参数的值应该选择reverse。|
| -a --a | default: 10 忽略比对质量低于此值的比对结果。在0.5.4版本以前该参数默认值是0。|
| -t --type | default: exon 程序会对该指定的feature（gtf/gff文件第三列）进行表达量计算，而gtf/gff文件中其它的feature都会被忽略。|
| -i --idattr | default: gene_id 设置feature ID是由gtf/gff文件第9列那个标签决定的；若gtf/gff文件多行具有相同的feature ID，则它们来自同一个feature，程序会计算这些features的表达量之和赋给相应的feature ID。|
| -m --mode | default: union 设置表达量计算模式。该参数的值可以有union, intersection-strict and intersection-nonempty。这三种模式的选择请见上面对这3种模式的示意图。从图中可知，对于原核生物，推荐使用intersection-strict模式；对于真核生物，推荐使用union模式。|
| -o --samout | 输出一个sam文件，该sam文件的比对结果中多了一个XF标签，表示该read比对到了某个feature上。|
| -q --quiet | 不输出程序运行的状态信息和警告信息。|
| -h --help | 输出帮助信息。|

* 查看生成的文件

```bash
cd ~/project/rat/output/HTseq
cat SRR2190795.count | head -n 5

# 结果（基因ID   reads计数）
ENSRNOG00000000001      0
ENSRNOG00000000007      0
ENSRNOG00000000008      0
ENSRNOG00000000009      0
ENSRNOG00000000010      0
```

## 8 合并表达矩阵与标准化
### 8.1 合并
将多个表合并为一个表，作为一个整体输入到后续分析的程序中。

```bash
      样本1 |        样本2 |       样本3
基因1   x   | 基因1    x   | 基因1   x
基因2   x   | 基因2    x   | 基因2   x
基因3   x   | 基因3    x   | 基因3   x
基因4   x   | 基因4    x   | 基因4   x

# 合并
      样本1   样本2  样本3
基因1   x      x      x
基因2   x      x      x
基因3   x      x      x
基因4   x      x      x
```

* 使用`R`语言中的`merge`将表格合并。

```R
R
rm(list=ls())
setwd("C:/Users/19065/project/rat/output/HTseq")

# 得到文件样本编号
files <- list.files(".", "*.count")
f_lists <- list()
for(i in files){
    prefix = gsub("(_\\w+)?\\.count", "", i, perl=TRUE)
    f_lists[[prefix]] = i
}

id_list <- names(f_lists)
data <- list()
count <- 0
for(i in id_list){
  count <- count + 1
  a <- read.table(f_lists[[i]], sep="\t", col.names = c("gene_id",i))
  data[[count]] <- a
}

# 合并文件
data_merge <- data[[1]]
for(i in seq(2, length(id_list))){
    data_merge <- merge(data_merge, data[[i]],by="gene_id")
}

write.csv(data_merge, "merge.csv", quote = FALSE, row.names = FALSE)
```

### 8.2 数据标准化
#### 8.2.1 简介
* 表达量  

一个细胞中某一基因表达得到的所有RNA为**绝对的数量**，即实际多少。但RNA-seq中，不确定用于测序的组织块含有的细胞个数，及提取RNA过程中损失的数量，则通过read count以及标准化后的数值并不表示真实的具体数量，而是**相对定量**，用于数据比较。

* `read count`与相对表达量

原始的read count数目并不能体现出基因与基因之间的相对的表达量的关系。经过HTseq-count得到的数值代表落在基因区域内的reads的数量，但不同基因的长度不同，则对应的reads比对的区域大小不同，因此需要进行样本内不同基因之间的标准化。  
但后续只分析基因的差异表达，所以对**测序深度标准化**后就可以直接比较不同样本同一个基因之间的read count数值，因为不涉及一个样本内不同基因的对比，属于**样本间标准化**，因为不同RNA-seq的测序深度可能存在差异。

```bash
          样本间相同基因的对比（TMM分位数标准化或深度标准化，或还是CPM、RPKM、FPKM、TPM标准化）
                    |
          sample1   |   sample2      sample3
gene1       x    <--+-->  x            x
                                       ^
                                       |
                                       +------ 样本内不同基因对比（RPKM、FPKM、TPM标准化）
                                       |
                                       v
gene2       x             x            x
gene3       x             x            x
```

样本间的标准化会使用`分位数标准化`或`CPM(counts per million)`或者`log-CPM`进行（`log-CPM`的计算为`log2(CPM + 2*10^6/N)`，取对数避免对`0`取对数的情况，取对数是因为使所有样本间的log倍数变化（log-fold-change）向0推移而减小低表达基因间微小计数变化带来的巨大的伪差异性，如果总reads数量有`4千万`，那么`0`的值就是`log2(2 / 40) = -4.32`）。   
因为上述计算方法并不涉及基因长度，所以计算相对方便，如果研究的样本在可变剪接的使用上有较大差异，那么比较时不宜使用上述方法，而需要考虑长度因素。    
因为后续可能需要QPCR实验验证，此处将数据进行一个样本内的标准化计算，但这个数值不用于后续的差异分析，参考[RNA-Seq分析|RPKM, FPKM, TPM, 傻傻分不清楚？](http://www.360doc.com/content/18/0112/02/50153987_721216719.shtml)；[BBQ(生物信息基础问题35，36)：RNA-Seq 数据的定量之RPKM，FPKM和TPM](https://www.jianshu.com/p/30035cae4ee9)，因存在使用`FPKM`还是`TPM`的争议，此处使用两种方法计算。

#### 8.2.2 cufflinks

#### 8.2.3 手动计算
* 计算相关基因的长度

```R
# 安装BiocManager(packages)
install.packages("BiocManager") 

# 安装GenomicFeatures和makeTxDbFromGFF库(bioconductor)
library(BiocManager)
BiocManager::install(c("GenomicFeatures", "makeTxDbFromGFF"))

# 加载R包
library("GenomicFeatures")

# 构建Granges对象
txdb <- makeTxDbFromGFF("annotation.gtf")

# 查找基因的外显子
exons_gene <- exonsBy(txdb, by = "gene")

# 计算总长度
## reduce()、width()是Irange对象的方法
gene_len <- list()
for(i in names(exons_gene)){
    range_info = reduce(exons_gene[[i]])
    width_info = width(range_info)
    sum_len    = sum(width_info)
    gene_len[[i]] = sum_len
}
## 或者写为lapply的形式(快很多)
gene_len <- lapply(exons_gene,function(x){sum(width(reduce(x)))})

data <- t(as.data.frame(gene_len))
# 写入文件
write.table(data, file = "genome_gene_len.tsv", row.names = TRUE, sep="\t", quote = FALSE, col.names = FALSE)
```

* **计算`RPKM` 和 `TPM`**
* `cpm`计算公式

```bash
CPM = (10^6 * nr) / N
# CPM: Counts per million
# nr: 比对至目标基因的reads数量
# N: 有效比对至基因组的reads总数量
```

* `RPKM`计算公式
```bash
RPKM = (10^6 * nr) / (L * N)
# RPKM: Reads Per Kilobase per Million
# L：目标基因的外显子长度之和除以1000(注意L的单位是kb，不是bp)
# nr: 比对至目标基因的reads数量
# N: 有效比对至基因组的reads总数量
```

```R
#!R
# =========== RPKM =============
gene_len_file <- "genome_gene_len.tsv"
count_file <- "SRR2190795.count"

gene_len <- read.table(gene_len_file, header = FALSE, row.name = 1)
colnames(gene_len) <- c("length")

count <- read.table(count_file, header = FALSE, row.name = 1)
colnames(count) <- c("count")
# all read number
all_count <- sum(count["count"])

RPKM <- c()
for(i in row.names(count)){
    count_ = 0
    exon_kb = 1
    rpkm = 0
    count_ = count[i, ]
    exon_kb  = gene_len[i, ] / 1000
    rpkm    = (10 ^ 6 * count_ ) / (exon_kb * all_count )
    RPKM = c(RPKM, rpkm)
}
```

* `TPM`计算公式

```bash
TPM = nr * read_r * 10^6 / g_r * T
   T   = ∑(ni * read_i / g_i)
即 TPM = (nr / g_r) * 10^6 / ∑(ni / gi)
# TPM:Transcripts Per Million
# nr:比对至目标基因的reads数量
# read_r:是比对至基因r的平均reads长度
# g_r:是基因r的外显子长度之和（无需除以1000）
```

```R
# =========== 计算TPM ============
# 首先得到总的结果
sum_ <- 0
for(i in row.names(count)){
    count_ = 0
    exon = 1
    count_ = count[i, ]
    exon  = gene_len[i, ]
    value = count_ / exon
    if(is.na(value)){
        print(paste(i, " is error! please check"))
    }else{
        sum_ = sum_ + value
    }
}

TPM <- c()
for(i in row.names(count)){
    count_ = 0
    exon = 1
    count_ = count[i, ]
    exon  = gene_len[i, ]
    tpm = (10 ^ 6 * count_ / exon ) / sum_
    TPM = c(TPM, tpm)
}

count["RPKM"] <- RPKM
count["TPM"] <- TPM       
           
write.table(count, "123.normalize.count", col.names = TRUE, row.names = TRUE, sep="\t", quote = FALSE)
```

以上两种计算方法默认每个基因所有的外显子都会表达，但实际上并不如此，如果想要较为精确的值，则需`bam`文件联合`gff`注释文件得到真实的基因外显子长度。此过程对`RPKM`的整体计算没有影响，但对`TPM`可能存在微弱差异。   
因为，`RPKM`是单个基因的read count数为分子，分母均和总reads数相关，在一定程度上消除了测序建库大小的差异。但也会引起一定的问题，即不能保证不同的样本中总RNA的表达总量总是保持一致。假如肝细胞比红细胞的RNA总量高，但计算`RPKM`的时候将`nr/N`归一化到`0-1`范围内（此时没有乘`10^6/L`），即按照比例来说一样，但实际上RNA的表达量数值是不等的，只能说表达的占比相等。但是这个数值相等是否能评判不同组织中具体基因的表达量呢？

```
某基因表达量： 
            +----+ 占比0.01
肝细胞总RNA：
            +------------------+


某基因表达量： 
            +--+ 占比0.01
红细胞总RNA： 
            +-------------+


                    归一化

----------------------------------------------

肝细胞某基因表达量：         红细胞某基因表达量：

y^                         y^
1|-------------+           1|-------------+
 |             |            |             |
 |             |            |             |
 |   *         |            |   *         |
 | *           |            | *           |
 +--------------->          +--------------->
               1 x                         1x
```

## 9. 差异表达分析
* 查看管家基因的表达情况。

`GAPDH(ENSRNOG00000018630)`、`beta-actin(ENSRNOG00000034254)`

```bash
cd ~/project/rat/output/HTseq
cat merge.csv | grep -E "ENSRNOG00000018630|ENSRNOG00000034254"

# 两个基因的表达量情况
ENSRNOG00000018630,0,0,0,0,0,0,0
ENSRNOG00000034254,0,0,0,0,0,0,0
# 原因（可能）：管家基因不在1号染色体上
```

### 9.1 数据前处理

* 删除`HTseq-count`的总结行

```R
# 删除gene_id行
dataframe <- read.csv("merge.csv", header=TRUE, row.names = 1)
```

* HTseq-count的结果数据中存在5行总结的内容，影响后续分析，需要删除。

| 项                     | 说明                                   |
| ---------------------- | -------------------------------------- |
| __alignment_not_unique | 比对到多个位置的reads数                |
| __ambiguous            | 不能判断落在哪个单位类型的reads数      |
| __no_feature           | 不能对应到任何单位类型的reads数        |
| __not_aligned          | 存在于SAM文件，但没有比对上的reads数   |
| __too_low_aQual        | 低于-a设定的reads mapping质量的reads数 |

```R
# 删除前5行内容
countdata <- dataframe[-(1:5),]

# 查看数据
head(countdata)
```

* 去除ID的版本号

有时基因名后有`.1`或`.2`等标号，也需要去除。

```R
# 得到行的名
row_names <- row.names(countdata)

# 开始替换
name_replace <- gsub("\\.\\w+","", row.names(countdata))

row.names(countdata) <- name_replace
```

* 去除低表达的基因  

在任何样本中都没有足够多的序列片段的基因应该从下游分析中过滤掉。因为：① 从生物学角度，在任何条件下的表达水平都不具有生物学意义的基因不值得关注，最好忽略；② 从统计学角度，去除低表达计数基因使数据中的均值-方差关系得到更精确的估计，并且减少观察差异表达的下游分析中需要进行的统计检验的数量。

```R
countdata <- countdata[rowSums(countdata) > 0,]
```

### 9.2 差异分析

使用`DESeq2`包进行差异分析，需要输入原始的`read count`，因此输入上述`HTseq`的reads计数后的数据进行分析。`DESeq2`包与`EdgeR`包类似，都是基于负二项分布模型。在转录组分析中有三个分析的水平`基因水平(gene-level)`、`转录本水平(transcript-level)`、`外显子使用水平(exon-usage-level)`。但是原始的`read count`数量并不能代表基因的表达量。


> 表达差异分析只对比不同样本之间的同一个转录本，所以不需要考虑转录本长度，只考虑总读段数。一个**最简单思想**就是，样本测序得到的总读段数（实际上是可以比对到转录组的总读段数）越多，则每个基因分配到的读段越多。因此**最简单的标准化因子**就是总读段数，用总读段数作标准化的前提是大部分基因的表达是非显著变化的，这与基因芯片中的基本假设相同。**但是**实际工作中发现很多情况下总读段数主要是一小部分大量表达的基因贡献的。Bullard等（2010）在比较了几种标准化方法的基础上发现在每个泳道内使用非零计数分布的上四分位数（Q75%）作为标准化因子是一种更稳健的选择，总体表现是所研究方法中最优的。
>
> Bioconductor的edgeR包和DESeq包分别提供了上四分位数和中位数来作为标准化因子，就是出于这个思想。[Bioconductor分析RNA-seq数据](https://www.jianshu.com/p/8f89284c16f8)

* DESeq2的差异分析的步骤

> 1. **构建一个dds(DESeqDataSet)的对象**
> 2. **利用DESeq函数进行标准化处理**
> 3. **用result函数来提取差异比较的结果**

#### 9.2.1 安装与加载包

```R
# 安装
BiocManager::install("DESeq2")
BiocManager::install("pheatmap")
BiocManager::install("biomaRt")
BiocManager::install("org.Rn.eg.db")
BiocManager::install("clusterProfiler")

# 加载
library(DESeq2)
library(pheatmap)
library(biomaRt)
library(org.Rn.eg.db)
library(clusterProfiler)
```

#### 9.2.2 构建对象

把数据导入R，生成对应的数据结构。

```R
# 语法
dds <- DESeqDataSetFromMatrix(countData = cts, colData = coldata, design= ~ batch + condition)
```

* `countData（表达矩阵）`：上面生成的数据框（列对应样本，行对应基因名称，中间对应reads的计数），格式如下：

|       | 样本1 | 样本2 | 样本3 |
| ----- | ----- | ----- | ----- |
| 基因1 | 10    | 20    | 15    | 
| 基因2 | 0     | 0     | 2     |
| 基因3 | 120   | 110   | 20    |

* `colData（样本信息）`：用来描述样本是实验组还是对照组，格式如下：

| sample      | treatment |
| ----------- | --------- |
| Control1    | control   |
| Control2    | control   |
| Experiment1 | treatment |
| Experiment2 | treatment |

treatment不一定指代样本经过什么处理，也可以是`细胞类型`、`基因型`、`表现型`、`样本处理方式`、`批次`等信息，因为如果直接给样本信息程序是不知道究竟是怎样的分组的，而这些信息就是被用于区分样本的性质对样本分组，所以说是很重要的信息，如果分错那么数据比较的时候就会相应的发生变化，最后得到的结果就会发生变化。

* `design（样本差异比较）`：就是指定样本依据什么分为实验组与对照组

上面的`表达矩阵`已经得到了，下面需要生成`样本信息`，下面的表格直接从NCBI的`Run selector`中得到。

| Run | BioSample | Sample name | Experiment | LoadDate | MBases | MBytes | health state | treatment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [SRR2240185](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240185) | [SAMN03975629](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975629) | DEN_1_2__DEN251_255_index7 | [SRX1182156](https://www.ncbi.nlm.nih.gov/sra/SRX1182156) | 2015-09-07 | 2,195 | 1,590 | Liver cirrhosis | DEN |
| [SRR2240186](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240186) | [SAMN03975630](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975630) | DEN_4_5__DEN24_59_index12 | [SRX1182158](https://www.ncbi.nlm.nih.gov/sra/SRX1182158) | 2015-09-07 | 1,128 | 815 | Liver cirrhosis | DEN |
| [SRR2240187](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240187) | [SAMN03975631](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975631) | PBS_1_2__PBS8_9_index13 | [SRX1182166](https://www.ncbi.nlm.nih.gov/sra/SRX1182166) | 2015-09-07 | 1,861 | 1,342 | Healthy control | PBS |
| [SRR2240228](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240228) | [SAMN03975632](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975632) | PBS_3_5__PBS18_19_index14 | [SRX1182170](https://www.ncbi.nlm.nih.gov/sra/SRX1182170) | 2015-09-07 | 1,649 | 1,190 | Healthy control | PBS |

这个表格说明了样本`ID`及其处理的情况，可以看到就是`treatment`那一栏不一样，下面针对

表达数据已经有了，下面是写一下实验组与对照组的信息，打开终端，`cd`到相应位置

```bash
cat <<EOF >./phenotype/phenotype.csv
"ids","state","condition","treatment"
"SRR2240185","Liver cirrhosis","DEN","treatment"
"SRR2240186","Liver cirrhosis","DEN","treatment"
"SRR2240187","Healthy control","PBS","control"
"SRR2240228","Healthy control","PBS","control"
EOF
```

下面将这些数据导入到R中

```R
# 刚才countdata已经得到
countdata

# 读取样本分组信息(注意，需要加上row.names = 1, header = TRUE，将行列名需要看好)
coldata <- read.table("./phenotype/phenotype.csv", row.names = 1, header = TRUE, sep = "," )
# 确认一下行列名是否有（不是简单的数值）
head(coldata)
# 调整数据顺序
countdata <- countdata[row.names(coldata)]

# 构建dds对象
dds <- DESeqDataSetFromMatrix(countData = countdata, colData = coldata, design= ~ treatment)

# 查看dds
dds

# 结果
class: DESeqDataSet 
dim: 2728 4 
metadata(1): version
assays(1): counts
rownames(2728): ENSRNOG00000000417
  ENSRNOG00000001466 ... ENSRNOG00000071167
  ENSRNOG00000071194
rowData names(0):
colnames(4): SRR2240185 SRR2240186 SRR2240187
  SRR2240228
colData names(3): state condition treatment
```

#### 9.2.3 样本相关性

因为存在很多基因的差别等因素，在某些基因上可能样本间几乎没有差别，但是总体来看就会有较大差别了，这里对包含众多的基因这样的因素的情况下进行样本相关性进行评估，评估样本的重复组之间是否很相似或者是否实验组与对照组之间差别明显。

* PCA分析(principal components analysis)

由于上面得到的是最原始的`read count`，但是PCA分析需要对数据进行转化才能进行。一般取对数，但是最原始的数据中有些基因的计数为`0`，这样在取`log`值的时候意味着`−∞`，这样是不行的，所以一般会加上一个常数再取`log`，也就是`log(count + N)`（其中`N`是一个常数），但是也有较好的方法来进行校正，比如`DEseq2`包自带的`rlog`和`vst`函数（全名为[`variance stabilizing transformation`](https://en.wikipedia.org/wiki/Variance-stabilizing_transformation)），它们消除了方差对均值的依赖，尤其是低均值时的高`log counts`的变异。

> 但是在DESeq2包中实际上已经有了归一化的方法，rlog和vst，在使用的需要根据样本量的多少来选择方法。样本量少于30的话，选择rlog，多于30的话，建议选择vst。


```R
# 接续着上面的构建得到的dds对象
# DEseq2包提供了相应的函数
vsdata <- rlog(dds, blind=FALSE)
# intgroup 分组
library(ggplot2)
plotPCA(vsdata, intgroup="treatment") + ylim(-10, 10)
```

距离越近相关性越大，否则越远，如果点单独的偏离，那么这个样本可能不好用。

> **NOTE: 有关主成分分析的意义** - [一文看懂PCA主成分分析](https://mp.weixin.qq.com/s?__biz=MzI5MTcwNjA4NQ==&mid=2247484036&idx=1&sn=22ee356d0c9680d56dada1b777985ed2&scene=21#wechat_redirect)
>
> 1. **简化运算**
>
> 在问题研究中，为了全面系统地分析问题，我们通常会收集众多的影响因素也就是众多的变量。这样会使得研究更丰富，通常也会带来较多的冗余数据和复杂的计算量。
>
> 比如我们我们测序了100种样品的基因表达谱借以通过分子表达水平的差异对这100种样品进行分类。在这个问题中，研究的变量就是不同的基因。每个基因的表达都可以在一定程度上反应样品之间的差异，但某些基因之间却有着调控、协同或拮抗的关系，表现为它们的表达值存在一些相关性，这就造成了统计数据所反映的信息存在一定程度的冗余。另外假如某些基因如持家基因在所有样本中表达都一样，它们对于解释样本的差异也没有意义。这么多的变量在后续统计分析中会增大运算量和计算复杂度，应用PCA就可以在尽量多的保持变量所包含的信息又能维持尽量少的变量数目，帮助简化运算和结果解释。
>
> 2. **去除数据噪音**
>
> 比如说我们在样品的制备过程中，由于不完全一致的操作，导致样品的状态有细微的改变，从而造成一些持家基因也发生了相应的变化，但变化幅度远小于核心基因 (一般认为噪音的方差小于信息的方差）。而PCA在降维的过程中滤去了这些变化幅度较小的噪音变化，增大了数据的信噪比。
>
> 3. **利用散点图实现多维数据可视化**
>
> 在上面的表达谱分析中，假如我们有1个基因，可以在线性层面对样本进行分类；如果我们有2个基因，可以在一个平面对样本进行分类；如果我们有3个基因，可以在一个立体空间对样本进行分类；如果有更多的基因，比如说n个，那么每个样品就是n维空间的一个点，则很难在图形上展示样品的分类关系。利用PCA分析，我们可以选取贡献最大的2个或3个主成分作为数据代表用以可视化。这比直接选取三个表达变化最大的基因更能反映样品之间的差异。（利用Pearson相关系数对样品进行聚类在样品数目比较少时是一个解决办法）
>
> 4. **发现隐性相关变量**
>
> 我们在合并冗余原始变量得到主成分过程中，会发现某些原始变量对同一主成分有着相似的贡献，也就是说这些变量之间存在着某种相关性，为相关变量。同时也可以获得这些变量对主成分的贡献程度。对基因表达数据可以理解为发现了存在协同或拮抗关系的基因。


+ sample-to-sample distances热图

上述的转换数据还可以做样本聚类热图，用`dist`函数来获得sample-to-sample距离，距离矩阵热图中可以清楚看到samples之间的相似与否

```R
# 颜色管理包（不是必须）
library("RColorBrewer")
# 得到数据对象中基因的计数的转化值
gene_data_transform <- assay(vsdata)
# 使用t()进行转置
# 使用dist方法求样本之间的距离
sampleDists <- dist(t(gene_data_transform))
# 转化为矩阵用于后续pheatmap()方法的输入
sampleDistMatrix <- as.matrix(sampleDists)
# 将矩阵的名称进行修改
# rownames(sampleDistMatrix) <- paste(vsdata$treatment, vsdata$condition, vsdata$ids, sep="-")
# colnames(sampleDistMatrix) <- paste(vsdata$treatment, vsdata$condition, vsdata$ids, sep="-")
# 设置色盘
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
# 绘制热图与聚类
pheatmap(sampleDistMatrix,
         clustering_distance_rows=sampleDists,
         clustering_distance_cols=sampleDists,
         col=colors)
```



可以看到样本与样本之间的距离，颜色越深，距离越近。

> 如果实验组与对照组之间差别不明显，那么后续的分析结果就需要考虑一下。另外如果重复之间差异较大，那么在后续分析的时候就需要谨慎考虑了偏离的组别是否能被用于后续分析了

#### 9.2.4 差异基因

* 使用`DESeq()`方法计算不同组别间基因的表达差异，其输入为`9.2.2`构建的`dss`数据对象。

```R
# 改变样本组别顺序
dds$treatment <- factor(as.vector(dds$treatment), levels = c("control","treatment"))

# 基于统计学方法进行计算
dds <- DESeq(dds)
```

输出，下面的输出的说明了分析的过程

> 1. 估计样本大小（消除测序深度的影响）
>
> 2. 对每一个基因的表达量的离散度做计算
>
> 3. 拟合广义的线性模型（generalized linear model）

使用的`Wald test`

```
estimating size factors
estimating dispersions
gene-wise dispersion estimates
mean-dispersion relationship
final dispersion estimates
fitting model and testing
```

* 查看实验组和对照组的对比结果

```R
result <- results(dds, pAdjustMethod = "fdr", alpha = 0.05)

# 查看结果
head(result)
```

```
log2 fold change (MLE): treatment treatment vs control 
Wald test p-value: treatment treatment vs control 
DataFrame with 6 rows and 6 columns

                    baseMean log2FoldChange     lfcSE
                   <numeric>      <numeric> <numeric>
ENSRNOG00000000417   636.407      0.4486687  0.217484
ENSRNOG00000001466   597.112      4.9329106  0.285266
ENSRNOG00000001488  2146.862     -0.1196395  0.182813
ENSRNOG00000001489   101.899     -0.0843860  0.333376
ENSRNOG00000001490   123.953      0.0337919  0.309519
ENSRNOG00000001492   215.430     -0.7128240  0.254208
                        stat      pvalue        padj
                   <numeric>   <numeric>   <numeric>
ENSRNOG00000000417  2.062996 3.91130e-02 1.04317e-01
ENSRNOG00000001466 17.292336 5.37299e-67 1.46817e-64
ENSRNOG00000001488 -0.654437 5.12830e-01 6.74111e-01
ENSRNOG00000001489 -0.253125 8.00171e-01 8.89044e-01
ENSRNOG00000001490  0.109176 9.13063e-01 9.54090e-01
ENSRNOG00000001492 -2.804095 5.04580e-03 1.81417e-02




                             baseMean     log2FoldChange            lfcSE               stat            pvalue              padj
                            <numeric>          <numeric>        <numeric>          <numeric>         <numeric>         <numeric>
ENSRNOG00000000001   1.17994640466912   2.82050381813686 2.03998348785486   1.38261110196669 0.166784143097929                NA
ENSRNOG00000000007   3.21818763108968   1.03282812936483 1.19212587975669  0.866375058962425   0.3862845167692 0.588801446064814
ENSRNOG00000000008 0.0736487075696094 0.0408142674500467 4.08045162499813 0.0100023897354905 0.992019380733042                NA
ENSRNOG00000000009  0.315935819923557  0.945916209804408  3.9303577318638  0.240669240394016 0.809811480914061                NA
ENSRNOG00000000010   0.35792609721321   1.06599609220382  3.8132283198917  0.279552128217199  0.77982113929097                NA
ENSRNOG00000000012  0.319959749943513  0.992781336729426 3.27168216147163   0.30344675543998 0.761549418580228                NA
```

+ 将结果按照p-value进行排序

```R
result_order <- result[order(result$pvalue),]
head(result_order)
```

```
log2 fold change (MLE): treatment treatment vs control 
Wald test p-value: treatment treatment vs control 
DataFrame with 6 rows and 6 columns
                           baseMean    log2FoldChange             lfcSE              stat               pvalue                 padj
                          <numeric>         <numeric>         <numeric>         <numeric>            <numeric>            <numeric>
ENSRNOG00000011250 208.046881231885 -7.50369356010508  0.44485821990427 -16.8676068562245 7.78886122158816e-64 1.14472893373681e-59
ENSRNOG00000047945 3799.51961509786  4.50434780195392 0.358671277660941  12.5584290755837 3.57357467823096e-36 2.62604135229802e-32
ENSRNOG00000017897 1130.41206772961  4.41361091204456 0.353924586455456  12.4704840549416 1.08166978868575e-35 5.29910029477147e-32
ENSRNOG00000001466 542.805654192746  4.87418957369525 0.412058420866664  11.8288799035913 2.76810877295631e-32 1.01707236590347e-28
ENSRNOG00000014013 400.690803761036  2.83690340404308 0.246440071910237  11.5115345570764 1.15406329271928e-30 3.39225364261904e-27
ENSRNOG00000018371 705.943312960284  4.65111741552834  0.41021741987017  11.3381762700384  8.4895191640983e-30 2.07950771924588e-26
```

**NOTE**

这里的`log2 fold change (MLE): treatment treatment vs control`行很重要，因为高低表达是相对的，这里你知道是谁与谁进行的比较，这里就是`treatment`与`control`进行比较。

+ 总结基因上下调情况

```R
summary(result_order)

# 结果
out of 2648 with nonzero total read count
adjusted p-value < 0.05
LFC > 0 (up)       : 360, 14%
LFC < 0 (down)     : 344, 13%
outliers [1]       : 0, 0%
low counts [2]     : 462, 17%
(mean count < 1)
[1] see 'cooksCutoff' argument of ?results
[2] see 'independentFiltering' argument of ?results
# 共有360个基因上调，344个基因下调，0个离群值。
```

* 查看显著的基因数量

```R
table(result_order$padj<0.05)

# 结果
FALSE  TRUE 
 1482   704 
```

* 保存数据

```R
# 新建文件夹
dir.create("./DESeq2")
# 不用按照padj排序的结果，就保存按照基因名排序的
write.csv(result, file="./DESeq2/results.csv", quote = F)
```

## 10. 提取差异表达基因与注释

### 10.1 名词解释

+ `Log2FC ` FC就是`Fold Change`就是倍数差异，就是将对照组与实验组的基因表达量的差别，一般将`Fold Change`等于2作为是否差异的临界点，那么对应的`Log2FC`就是`1`。 


将上述的数据

```R
# padj 小于 0.05 并且 Log2FC 大于 1 或者小于 -1
diff_gene <- subset(result_order, padj < 0.05 & abs(log2FoldChange) > 1)

# 查看数据框的大小
dim(diff_gene)
```

```
[1] 2485    6
```

+ 把差异基因写入到文件中

```R
dir.create("../DESeq2/")
write.csv(diff_gene, file="../DESeq2/difference.csv", quote = F)
```

### 10.2 使用`ClusterProfiler`对基因的ID进行转化

```R
# 首先安装ClusterProfiler
source("http://bioconductor.org/biocLite.R")
# 安装clusterProfiler包
biocLite("clusterProfiler")
# 这里我们分析的是大鼠，安装大鼠的数据库
biocLite("org.Rn.eg.db")

# 加载包
library(clusterProfiler)
library(org.Rn.eg.db)

# 得到基因ID(这个ID是Ensembl数据库的编号)
ensembl_gene_id <- row.names(diff_gene)

# 转换函数
ensembl_id_transform <- function(ENSEMBL_ID){
    # geneID是输入的基因ID，fromType是输入的ID类型，toType是输出的ID类型，OrgDb注释的db文件，drop表示是否剔除NA数据
    a = bitr(ENSEMBL_ID, fromType="ENSEMBL", toType=c("SYMBOL","ENTREZID"), OrgDb="org.Rn.eg.db")
    return(a)
}

# 开始转化
ensembl_id_transform(ensembl_gene_id)
```

使用`ClusterProfiler`包进行转化似乎有部分没有映射到，换`biomaRt`包试一下

### 10.3 使用`biomaRt`进行注释

```R
# 安装
biocLite("biomaRt")

# 加载
library("biomaRt")

# 选择数据库
mart <- useDataset("rnorvegicus_gene_ensembl", useMart("ENSEMBL_MART_ENSEMBL"))

# 得到基因ID(这个ID是Ensembl数据库的编号)
ensembl_gene_id <- row.names(diff_gene)
rat_symbols <- getBM(attributes=c("ensembl_gene_id","external_gene_name","entrezgene_id", "description"), filters = 'ensembl_gene_id', values = ensembl_gene_id, mart = mart)
```

+ 将基因矩阵与`symbols`合并

```R
# 生成用于合并的列
diff_gene$ensembl_gene_id <- ensembl_gene_id
# 将DESeq2对象转换为数据库
diff_gene_dataframe <- as.data.frame(diff_gene)
# 合并
diff_gene_symbols <- merge(diff_gene_dataframe, rat_symbols, by = c("ensembl_gene_id"))
```

+ 将数据存储起来

```R
write.table(result, "../stat/all_gene.tsv", sep="\t", quote = FALSE)
write.table(diff_gene_symbols, "../stat/diff_gene.tsv", row.names = F,sep="\t", quote = FALSE)
```

+ 统计样本的差异基因

```bash
echo -e "sample\tnum" > all_samples.tsv
for i in $(ls);
do
    if [ -d ${i} ];
    then
        prefix=$i
        diff_num=$(cat $i/diff_gene.tsv | tail -n+2 | wc -l)
        echo -e "${prefix}\t${diff_num}" >> all_samples.tsv
    fi
done
```

使用`R`绘图

```R
library(ggplot2)
data <- read.table("all_samples.tsv", header = T)

pdf("samples_diff_gene_num.pdf")
  ggplot(data=data, aes(x=sample, y=num, fill=sample)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "samples",y = "num",title = "different gene number")
dev.off()
```

## 11. 可视化

+ MA图

> MA-plot (R. Dudoit et al. 2002) ，也叫 mean-difference plot或者Bland-Altman plot，用来估计模型中系数的分布。 X轴, the “A” （ “average”）；Y轴，the “M” （“minus”） – subtraction of log values is equivalent to the log of the ratio。
> M表示log fold change，衡量基因表达量变化，上调还是下调。A表示每个基因的count的均值。提供了模型预测系数的分布总览。

```R
plotMA(result_order, ylim=c(-10,10))
```

+ 热图


## 12. 富集分析

* 使用`clusterProfiler`进行富集分析

```R
# 接续着上面的结果
ensembl_gene_id <- row.names(diff_gene)

# 得到symbol
rat_symbols <- getBM(attributes=c("ensembl_gene_id","external_gene_name","entrezgene_id", "description"), filters = 'ensembl_gene_id', values = ensembl_gene_id, mart = mart)
diff_gene_ensembl_id <- rat_symbols$ensembl_gene_id
```

### 12.1 `Gene Ontology (GO)`分析

+ GO的三大类

| 类别                    | 说明     |
| ----------------------- | -------- |
| molecular function (MF) | 分子功能 |
| biological process (BP) | 生物过程 |
| cellular component (CC) | 细胞组成 |

在`clusterProfiler`包中有`enrichGO`方法就是用来进行GO富集的

```react
enrichGO     GO Enrichment Analysis of a gene set. Given a vector of genes, this
             function will return the enrichment GO categories after FDR control.
Usage:
  enrichGO(gene, OrgDb, keyType = "ENTREZID", ont = "MF", pvalueCutoff = 0.05, 
           pAdjustMethod = "BH", universe, qvalueCutoff = 0.2, minGSSize = 10, 
           maxGSSize = 500, readable = FALSE, pool = FALSE)
Arguments:
  gene                 a vector of entrez gene id.
  OrgDb                OrgDb
  keyType              keytype of input gene
  ont                  One of "MF", "BP", and "CC" subontologies or 'ALL'.
  pvalueCutoff         Cutoff value of pvalue.
  pAdjustMethod        one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"
  universe             background genes
  qvalueCutoff         qvalue cutoff
  minGSSize            minimal size of genes annotated by Ontology term for testing.
  maxGSSize            maximal size of genes annotated for testing
  readable             whether mapping gene ID to gene Name
  pool                 If ont=’ALL’, whether pool 3 GO sub-ontologies
```

| 参数          | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| gene          | 差异基因对应的向量                                           |
| keyType       | 指定的gene的ID类型，一般都用ENTREZID，该参数的取值可以参考`keytypes(org.Hs.eg.db)`的结果 |
| OrgDb         | 该物种对应的org包的名字                                      |
| ont           | 代表GO的3大类别，`BP`, `CC`, `MF`                            |
| pAdjustMethod | 指定多重假设检验矫正的方法                                   |
| pvalueCutoff  | 对应的阈值                                                   |
| qvalueCutoff  | 对应的阈值                                                   |

参数需要指定正确，特别是`OrgDb`。

+ 开始GO分析


```R
for(i in c("MF", "BP", "CC")){
    ego <- enrichGO(gene       = rat_symbols$entrezgene_id,
                    OrgDb      = org.Rn.eg.db,
                    keyType    = 'ENSEMBL',
                    ont        = i,
                    pAdjustMethod = "BH",
                    pvalueCutoff = 0.01,
                    qvalueCutoff = 0.05)
    dotplot(ego, showCategory = 30, title = paste("The GO ", i, " enrichment analysis", sep = ""))
}
```

### 12.2 KEGG分析

```R
kk <- enrichKEGG(gene = gene, 
                 organism ='rno',
                 pvalueCutoff = 0.05,
                 qvalueCutoff = 0.05,
                 minGSSize = 1,
                 #readable = TRUE ,
                 use_internal_data = FALSE)
```

### 12.3 GSEA分析

这个富集方式与上面的相似，它就是以KEGG数据库（或其他基因注释数据库，例如GO）为背景，根据所选样品所有的基因表达量来做富集分析，得到的结果是所有表达的基因在各个代谢通路中的富集情况。

但是与上面的两个富集分析不同，它的输入文件不是一个基因列表，而是除了基因之外还有它的表达量（目前样本中所有的非`0`的基因的倍数的改变的数值）。

另外就是GSEA针对**所有基因**，KEGG针对**差异基因**富集的通路，现在一般结合两者的结果来做推断。

+ 制作genelist
+ GSEA分析
+ 富集分布

### 12.4 DO（Disease Ontology）分析

这个是疾病相关的本体分析

### 12.5 ReactomePA

### 12.6 另外可以使用几个在线网站

+ [metascape](http://metascape.org/gp/index.html)

+ [webgenstal](http://www.webgestalt.org/)

+ [DAVID](https://david-d.ncifcrf.gov/)

## ========================================

`StringTie` + `Ballgown`是较新的RNA-seq的分析方法。但是其中出现部分一定会出现的情况不知如何解决。这个过程没有走完，有待解决（在用`StringTie`合并第一步的转录本的gff之后，后面了`MSTRG`等基因名称。这种名称是在`stringtie`合并样本`gff`文件的时候产生的，后续差异分析之后不知道如何对应回去？）

## ========================================

## 5. 表达量分析

StringTie

![](./pic/DE_pipeline.png)

```bash
$ cd ~/project/rat/output
$ mkdir assembly

$ cd align
$ parallel -j 4 "
    stringtie -p 4 -G ../../annotation/rn6.gff -l {1} {1}.sort.bam -o ../assembly/{1}.gtf
" ::: $(ls *.sort.bam | perl -p -e 's/\.sort\.bam$//')
```
+ 查看一下新生成的`.gtf`文件

```bash
cd ~/project/rat/output/assembly

cat SRR2190795.gtf | head -n 4
```
可以看到使用StringTie处理后的注释文件与之前不一样了，在第九列里面出现了更多的描述信息，包括比对上的样本名，每个碱基的覆盖深度的平均数`cov`，表达量的标准化数值`TPM`和`FPKM`等等。

```bash
# stringtie -p 4 -G ../../annotation/rn6.gff -l SRR2190795 SRR2190795.sort.bam -o ../assembly/SRR2190795.gtf
# StringTie version 1.3.6
1	StringTie	transcript	1545134	1546169	1000	+	.	gene_id "SRR2190795.1"; transcript_id "SRR2190795.1.1"; reference_id "ENSRNOT00000044523"; ref_gene_id "ENSRNOG00000029897"; ref_gene_name "AABR07000156.1"; cov "0.192085"; FPKM "0.147392"; TPM "0.242629";
1	StringTie	exon	1545134	1546169	1000	+	.	gene_id "SRR2190795.1"; transcript_id "SRR2190795.1.1"; exon_number "1"; reference_id "ENSRNOT00000044523"; ref_gene_id "ENSRNOG00000029897"; ref_gene_name "AABR07000156.1"; cov "0.192085";
```
+ 合并`.gtf`文件

StringTie与之前的分析方式多了一步，这里将这些所有的样本的注释文件合并，在某种程度上根据比对的结果将那些没有出现在注释信息中的比对情况也进行了增补。

```bash
cd ~/project/rat/output/assembly

# 将生成 .gtf 文件的文件名放到文件中
ls *.gtf > mergelist.txt

##### 合并 ######
# --merge 合并模式
# -p 线程数
# -G 参考基因组的
stringtie --merge -p 8 -G ../../annotation/rn6.gff -o merged.gtf mergelist.txt 
```
参数--merge 为转录本合并模式。 在合并模式下，stringtie将所有样品的GTF/GFF文件列表作为输入，并将这些转录本合并/组装成非冗余的转录本集合。这种模式被用于新的差异分析流程中，用以生成一个**跨多个RNA-Seq样品的全局的、统一的转录本**。

接下来，重新组装转录本并估算基因表达丰度。

+ 估计转录本的丰度

```bash
$ cd ~/project/rat/output
$ mkdir abundance

$ cd align

$ parallel -j 4 "
    ../abundance/{1}
    stringtie -e -B -p 4 -G ../assembly/merged.gtf -l {1} {1}.sort.bam -o ../abundance/{1}/{1}.gtf
" ::: $(ls *.sort.bam | perl -p -e 's/\.sort\.bam$//')
```
+ 对比原始的注释文件，查看有哪些新发现的转录本

```bash
$ gffcompare 
```
+ 转化为表达量的矩阵

这里不用下游的`ballgown`进行分析，下载一个转换脚本，这个`python`脚本可以把之前生成的`.gtf`文件转换为表达量矩阵，这个脚本的下载方式是：

```bash
cd ~/project/rat/script

wget https://ccb.jhu.edu/software/stringtie/dl/prepDE.py

# 注意这个脚本是使用python2
python2 prepDE.py --help

cd ~/project/rat/output/
mkdir matrix

# 开始进行转换
python2 ~/project/rat/script/prepDE.py \
   -i ./abundance \
   -g ./matrix/gene_count_matrix.csv \
   -t ./matrix/transcript_count_matrix.csv \
   -l 100
```

到这里理一下文件夹，使用`tree`命令查看我们的目录结构

```bash
cd ~/project/rat

# -d 参数表示只显示文件夹
tree -d

.
├── annotation
├── genome
│   └── index
├── output
│   ├── abundance
│   │   ├── SRR2190795
│   │   ├── SRR2240182
│   │   ├── SRR2240183
│   │   ├── SRR2240184
│   │   ├── SRR2240185
│   │   ├── SRR2240186
│   │   ├── SRR2240187
│   │   └── SRR2240228
│   ├── adapter
│   ├── align
│   ├── assembly
│   │   ├── tmp.EpF0i246
│   │   └── tmp.bgxUpBmL
│   ├── fastqc
│   │   └── multiqc_data
│   ├── fastqc_trim
│   │   └── multiqc_data
│   ├── matrix
│   └── trim
├── phenotype
├── script
└── sequence
```

## 6. 表达量分析

在生物体中，不同部位、时间、不同处境下的基因表达情况是不一样的，这样在提取RNA并测序的时候，不同的RNA的存在量是不一样的，这个差异就导致了测序得到的read数量不同，基因表达越多，那么在组织中的存在越多，那么提取得到的量也就越多，最后测序测得的量也多。通过对RNA-seq的测序深度进行一个统计，就可以比较出基因的表达量，通过与特定的管家基因的表达量进行比较，就可以得出相对量从而判断上调还是下调。

![](./pic/read_map_and_count.png)

在分析之前需要新建一个表型(phenotype)文件，这个文件是用来对样本记性描述的，下面是一个样例

```bash
"ids","sex","population"
"ERR188044","male","YRI"
"ERR188104","male","YRI"
"ERR188234","female","YRI"
"ERR188245","female","GBR"
"ERR188257","male","GBR"
"ERR188273","female","YRI"
"ERR188337","female","GBR"
"ERR188383","male","GBR"
"ERR188401","male","GBR"
"ERR188428","female","GBR"
"ERR188454","male","YRI"
"ERR204916","female","YRI"
```
这里我们创建一个类似的文件，在NCBI的`Run selector`中的表格

| Run | BioSample | Sample name | Experiment | LoadDate | MBases | MBytes | health state | treatment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [SRR2190795](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2190795) | [SAMN03975625](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975625) | AM95_3_4__DEN283_275_index2 | [SRX1140283](https://www.ncbi.nlm.nih.gov/sra/SRX1140283) | 2015-09-05 | 1,440 | 1,039 | Liver cirrhosis | DEN + AM095 |
| [SRR2240182](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240182) | [SAMN03975626](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975626) | AM95_5__DEN284_index4 | [SRX1180447](https://www.ncbi.nlm.nih.gov/sra/SRX1180447) | 2015-09-07 | 2,337 | 1,682 | Liver cirrhosis | DEN + AM095 |
| [SRR2240183](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240183) | [SAMN03975627](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975627) | AM63_1_3__DEN265_285_index5 | [SRX1182152](https://www.ncbi.nlm.nih.gov/sra/SRX1182152) | 2015-09-07 | 1,680 | 1,214 | Liver cirrhosis | DEN + AM063 |
| [SRR2240184](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240184) | [SAMN03975628](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975628) | AM63_4_5__DEN261_282_index6 | [SRX1182155](https://www.ncbi.nlm.nih.gov/sra/SRX1182155) | 2015-09-07 | 1,886 | 1,371 | Liver cirrhosis | DEN + AM063 |
| [SRR2240185](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240185) | [SAMN03975629](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975629) | DEN_1_2__DEN251_255_index7 | [SRX1182156](https://www.ncbi.nlm.nih.gov/sra/SRX1182156) | 2015-09-07 | 2,195 | 1,590 | Liver cirrhosis | DEN |
| [SRR2240186](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240186) | [SAMN03975630](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975630) | DEN_4_5__DEN24_59_index12 | [SRX1182158](https://www.ncbi.nlm.nih.gov/sra/SRX1182158) | 2015-09-07 | 1,128 | 815 | Liver cirrhosis | DEN |
| [SRR2240187](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240187) | [SAMN03975631](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975631) | PBS_1_2__PBS8_9_index13 | [SRX1182166](https://www.ncbi.nlm.nih.gov/sra/SRX1182166) | 2015-09-07 | 1,861 | 1,342 | Healthy control | PBS |
| [SRR2240228](https://www.ncbi.nlm.nih.gov/Traces/sra/?run=SRR2240228) | [SAMN03975632](https://www.ncbi.nlm.nih.gov/biosample/SAMN03975632) | PBS_3_5__PBS18_19_index14 | [SRX1182170](https://www.ncbi.nlm.nih.gov/sra/SRX1182170) | 2015-09-07 | 1,649 | 1,190 | Healthy control | PBS |

样本除了健康状态与给药情况不同，其他均相同

```
cd ~/project/rat/output

mkdir phenotype

cat <<EOF >./phenotype/phenodata.csv
"ids","health state","treatment"
"SRR2190795","Liver cirrhosis","DEN + AM095"
"SRR2240182","Liver cirrhosis","DEN + AM095"
"SRR2240183","Liver cirrhosis","DEN + AM063"
"SRR2240184","Liver cirrhosis","DEN + AM063"
"SRR2240185","Liver cirrhosis","DEN"
"SRR2240186","Liver cirrhosis","DEN"
"SRR2240187","Healthy control","PBS"
"SRR2240228","Healthy control","PBS"
EOF
```

接下来就可以用R语言进行后续的分析了，打开`Rstudio`

```R
# 使用biocLite("ballgown")进行包的安装
source("http://bioconductor.org/biocLite.R")
options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/")

# 安装包
biocLite("ballgown")
biocLite("RSkittleBrewer")
biocLite("devtools")
biocLite("genefilter")
biocLite("dplyr")

# 读取表型文件

```
## 7. 差异表达分析

在这里发现了差异基因出现了`MSTRG`等名称。这个名称是在`stringtie`合并样本`gff`文件的时候产生的，后续差异分析之后不知道如何对应回去？


## 作者

+ [eternal-bug](https://github.com/eternal-bug) - Zelda_legend@163.com

## 参考

### 流程

主要参考

+ [\* Y大宽 - RNA-seq(7): DEseq2筛选差异表达基因并注释(bioMart)](https://www.jianshu.com/p/3a0e1e3e41d0)
+ [\* Y大宽 - RNA-seq(8): 探索分析结果:Data visulization](https://www.jianshu.com/p/807cf4a969fb)
+ [Dawn_天鹏 - 转录组学习三（数据质控）](https://www.jianshu.com/p/bacb86c78b43) - fastqc结果解释的很好
+ [Dawn_天鹏 - 转录组学习七（差异基因分析）](https://www.jianshu.com/p/26511d3360c8)
+ [RNA-seq workflow: gene-level exploratory analysis and differential expression](https://master.bioconductor.org/packages/release/workflows/vignettes/rnaseqGene/inst/doc/rnaseqGene.html)
+ [GEO数据挖掘-从数据下载到富集分析-各种绘图（学习笔记）](https://blog.csdn.net/weixin_43700050/article/details/86511630) - R脚本较为全面
+ [xuzhougeng/Learn-Bioinformatics](https://github.com/xuzhougeng/Learn-Bioinformatics)
+ [enrichplot: 让你们对clusterProfiler系列包无法自拔](http://www.360doc.com/content/18/0309/18/33459258_735717104.shtml) - clusterProfiler的各种可视化方法的介绍
+ [Ming Tang - RNA-seq-analysis](https://github.com/crazyhottommy/RNA-seq-analysis)
+ [DESeq2分析转录组之预处理+差异分析](https://www.jianshu.com/p/309c35fa6c7f) - 样本对比关系设定
+ [DESeq2 PCA 的一些问题](https://www.jianshu.com/p/b7e55bacbede) - rlog和vst
+ [Bioconductor:DESeq2](https://www.jianshu.com/p/bc8a6156c82a) - DESeq2包的介绍
+ [Bioconductor分析RNA-seq数据](https://www.jianshu.com/p/8f89284c16f8) - 说明了转录组分析中的一些理论知识
+ [转录组入门(6)： reads计数](https://www.jianshu.com/p/e9742bbf83b9) - 转录组分析的三个水平
+ [Htseq Count To Fpkm](http://www.bioinfo-scrounger.com/archives/342) - 得到基因的外显子长度
+ [浅谈GSEA分析和KEGG富集分析的异同](http://www.dxy.cn/bbs/topic/39085659?sf=2&dn=4)
+ [对转录组数据进行质量控制分析](http://www.chenlianfu.com/?p=2286)
+ [RNA-seq 基本分析流程](https://www.cnblogs.com/easoncheng/archive/2013/02/26/2934000.html)
+ [RNA-seq中的基因表达量计算和表达差异分析](https://blog.csdn.net/sinat_38163598/article/details/73008592) - DEseq2的归一化的方法
+ [知哥54581孪副3b - 如何理解基因富集分析以及富集的意思？](https://know.baidu.com/wenda/question/info?qid=4f6f8f0b0e01cf7c437e9477bf2bc1b51ef723c)
+ [#基因组干货#之烂大街的GO、KEGG分析作图](https://www.jianshu.com/p/462423702851) - 使用ggplot2来绘制富集图，而不是封装的函数
+ [GO，KEGG，DO富集分析](https://www.jianshu.com/p/47b5ea646932) - DO分析
+ [RPKM vs FPKM vs TPM](http://www.genek.tv/article/23) - 举例子计算`RPKM`和`TPM`
+ [What the FPKM? A review of RNA-Seq expression units](https://haroldpimentel.wordpress.com/2014/05/08/what-the-fpkm-a-review-rna-seq-expression-units/)
+ [Top-Down vs. Bottom-Up: What’s the Difference?](https://www.investopedia.com/articles/investing/030116/topdown-vs-bottomup.asp)

### 结果解读

+ [RNA-seq结果怎么才能看懂?答案全在这些图里---（2）基础分析结果篇](http://www.360doc.com/content/18/0307/18/45848444_735176770.shtml)
+ [手把手教你看富集分析结果之GO富集](http://www.360doc.com/content/17/0919/01/47411701_688261255.shtml)

### 原理

+ [如何理解基因富集分析以及富集的意思？](https://www.zhihu.com/question/30778984)
+ [【T】每日一生信--富集分析（超几何分布）（Fisher'sExactTest）](http://blog.sina.com.cn/s/blog_670445240101m4z3.html)

### 程序下载安装

+ [samtools的安装和使用](https://www.jianshu.com/p/6b7a442d293f)
+ [R与RStudio的安装](https://www.jianshu.com/p/1a0f25086e8b)
+ [高通量测序数据质控神器—Trimmomatic](https://www.plob.org/article/12130.html)
+ [HISAT+StringTie+Ballgown转录组分析流程介绍](https://www.jianshu.com/p/38c2406367d5)
+ [RNA-seq分析htseq-count的使用](https://www.cnblogs.com/triple-y/p/9338890.html)
+ [面面的徐爷 - RNA-seq数据分析---方法学文章的实战练习](https://www.jianshu.com/p/1f5d13cc47f8)
+ [biostar - Question: Phenotype data for Ballgown tool](https://biostar.usegalaxy.org/p/23253/)
+ [RNA Sequencing](http://www.yourgene.com.tw/content/messagess/contents/655406000360260030/) - 图片
+ [biostar - Question: Stringtie prepDE.py Error line 32](https://www.biostars.org/p/306894/) - prepDE.py脚本出错
+ [生信技能树 - biomart](https://www.jianshu.com/p/0dbd5528ce3d) - biomart用法（中文解读中最为详细的）
+ [Question: 98.21% of input gene IDs are fail to map](https://www.biostars.org/p/296321/) - 使用`ClusterProfiler`包可能会出现`input gene IDs are fail to map`就是部分基因没有对应到数据库中
+ [用RNA-SeQC得到表达矩阵RPKM值](https://www.jianshu.com/p/bf87bf3ca469)

### 问题

**Q：How to deal with MSTRG tag without relevant gene name?**

  + **A：[Question: How to deal with MSTRG tag without relevant gene name?](https://www.biostars.org/p/282817/)** - 在用stringtie的时候后续合并完成会生成`MSTRG`标签的基因名，怎么解决

**Q：RNA-seq应该去除PCR重复吗？**

  + **A: [Should I remove PCR duplicates from my RNA-seq data?](https://dnatech.genomecenter.ucdavis.edu/faqs/should-i-remove-pcr-duplicates-from-my-rna-seq-data/)**

  + **A: [The trouble with PCR duplicates](https://www.molecularecologist.com/2016/08/the-trouble-with-pcr-duplicates/)**

  + **A: [Removing PCR duplicates in RNA-seq Analysis](https://bioinformatics.stackexchange.com/questions/2282/removing-pcr-duplicates-in-rna-seq-analysis)**

  + **A: [《The impact of amplification on differential expression analyses by RNA-seq》](https://www.nature.com/articles/srep25533)**

**Q： DEseq2在进行差异分析时，组别之间重复数量不一样可以进行比较吗？**

  + **A：[Question: Deseq2 Etc. Unequal Sample Sizes](https://www.biostars.org/p/90421/)**

**Q：RNA-seq多少个重复比较合适？**

  + **A：[RNA测序中多少生物学重复合适](http://www.sohu.com/a/248181085_769248)** - 出于科研经费和实验结果准确性的综合考虑，RNA测序中每组至少使用6个生物学重复。若实验目的是鉴定所有倍数变化的差异基因，至少需要12个生物学重复。

**Q：How different is rlog transformation from vst transformation in DESeq2**

  + **A：[Question: How different is rlog transformation from vst transformation in DESeq2](https://www.biostars.org/p/338885/)** - 差异不是很明显，但是在运行速度上有一定差别

**Q: RNA-seq analysis- HiSat2 and Cufflinks**

  + **A：[Question: RNA-seq analysis- HiSat2 and Cufflinks](https://biostar.usegalaxy.org/p/18308/)** - `samtools view -Sbo alignments.bam alignments.sam`


[def]: ./pic/RNA-seq_small.jpg