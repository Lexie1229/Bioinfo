# [甲基化分析](https://github.com/Jihong-Tang/methylation-analysis/tree/master/NBT_repeat)

## 0 介绍
APOBEC偶联甲基化表观测序 (ACE-seq）可以特异性检测5hmC（5-羟甲基胞嘧啶）。基于[NBT文章](https://www.nature.com/articles/nbt.4204)中的ACE-seq数据，学习在小鼠（mouse）样本中寻找5hmc DMLs（differentially methylated loci，差异甲基化位点）的生物信息流程，学习基于[`bismark`](https://github.com/FelixKrueger/Bismark)和[`DSS`](http://bioconductor.org/packages/release/bioc/html/DSS.html) 软件工具包的甲基化数据分析程序，熟悉基本的生物信息数据分析协议。

## 1 数据下载 
### 1.1 测序数据
* 下载测序数据，进入[EBI-ENA search page](https://www.ebi.ac.uk/ena)，搜索GEO数据库编号[GSE116016](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE116016)，在[result page](https://www.ebi.ac.uk/ena/data/view/PRJNA476795)获取FTP地址，使用[`aria2`](https://aria2.github.io/)工具下载`.fastq.gz`文件。有关数据下载的详细信息参考[Blog](https://www.jianshu.com/u/3fcc93cd84c1)，测序数据参考[NBT文章](https://www.nature.com/articles/nbt.4204)。

```bash
mkdir -p $HOME/project/NBT_repeat/data/seq_data/WT_mESC_rep1
mkdir -p $HOME/project/NBT_repeat/data/seq_data/TetTKO_mESC_rep1
cd $HOME/project/NBT_repeat/data/seq_data/

# 下载 Wild type: SRR7368841 & SRR7368842
aria2c -d ./WT_mESC_rep1/ -Z ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR736/001/SRR7368841/SRR7368841.fastq.gz ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR736/002/SRR7368842/SRR7368842.fastq.gz
# 下载 TetTKO type: SRR7368845
aria2c -d ./TetTKO_mESC_rep1/ -Z ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR736/005/SRR7368845/SRR7368845.fastq.gz
```

### 1.2 参考基因组数据
* 从[Ensembl](https://www.ensembl.org/info/data/ftp/index.html)下载小鼠肌肉（Mus musculus）参考基因组数据，进入[ensembl download page](https://www.ensembl.org/info/data/ftp/index.html)，下载小鼠的DNA `.fasta` 文件，在[result page](https://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/)获取FTP地址，使用[`aria2`](https://aria2.github.io/)工具下载`.fastq.gz`文件。

```bash
mkdir -p $HOME/project/NBT_repeat/data/genome_data/
cd $HOME/project/NBT_repeat/data/genome_data/

# 命令行下载
aria2c -d ./ -Z ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.1.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.2.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.3.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.4.fa.gz
aria2c -d ./ -Z ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.5.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.6.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.7.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.8.fa.gz
aria2c -d ./ -Z ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.9.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.10.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.11.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.12.fa.gz
aria2c -d ./ -Z ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.13.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.14.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.15.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.16.fa.gz
aria2c -d ./ -Z ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.17.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.18.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.19.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.X.fa.gz ftp://ftp.ensembl.org/pub/release-108/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.Y.fa.gz

# 或脚本下载
sh $HOME/Scripts/methylation-analysis/Scripts/shell/genome_data_download.sh $HOME/NBT_repeat/data/genome_data/
```

## 2 质量控制和修剪
对高通量测序进行质量控制，以直接判断数据集是否质量良好以及文库或测序本身是否存在基本问题。使用[FastQc](www.bioinformatics.babraham.ac.uk/projects/fastqc/)进行质量控制，并使用[Trim Galore](www.bioinformatics.babraham.ac.uk/projects/trim_galore/)修剪接头。

```bash
cd $HOME/project/NBT_repeat/data/seq_data/

# 质量控制以查看原始测序数据的质量
fastqc --threads 3 ./WT_mESC_rep1/*.fastq.gz ./TetTKO_mESC_rep1/*.fastq.gz
## -t/--threads <int>:指定可以同时处理的文件数。

# 安装Trim Galore
sudo apt install trim-galore

# 质量和接头修剪
trim_galore -o ./WT_mESC_rep1/trimmed_data/ --fastqc ./WT_mESC_rep1/*.fastq.gz
trim_galore -o ./TetTKO_mESC_rep1/trimmed_data/ --fastqc ./TetTKO_mESC_rep1/*.fastq.gz
## -o/--output_dir <DIR>:指定所有输出写入特定的目录而不是当前目录，如果指定的目录不存在，则自动新建。
## --fastqc:修剪完成后，在FastQ文件的默认模式下运行FastQC。
```

## 3 甲基化分析
质量控制和修剪后，遵循基于[Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)的BS-seq数据分析协议对ACE-seq数据进行甲基化分析。

### 3.1 基因组索引
序列比对前，基因组需要*in-silico*亚硫酸氢盐转化并索引。基于`Bismark`，可以同时使用`Bowtie`和`Bowtie2`完成索引。

```bash
# 安装bismark
cd ~/biosoft
wget https://github.com/FelixKrueger/Bismark/archive/refs/tags/0.24.0.tar.gz
tar xzf 0.24.0.tar.gz
cd Bismark-0.24.0
export PATH=$HOME/biosoft/Bismark-0.24.0:$PATH 
## 写入.bashrc文件
echo '# Bismark'
echo 'export PATH="$HOME/biosoft/Bismark-0.24.0:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 建立索引
bismark_genome_preparation --bowtie2 $HOME/project/NBT_repeat/data/genome_data/
## --bowtie2：建立用于Bowtie2的亚硫酸氢盐索引。
## --parallel INT：使用多个线程，加快基因组索引过程。
## 因为内存原因，仅使用Chr19建立索引。
```

### 3.2 序列比对
甲基化数据分析的核心是将测序reads与参考基因组比对。

```bash
genome_path="$HOME/project/NBT_repeat/data/genome_data/"
cd $HOME/project/NBT_repeat/data/seq_data/

# 序列比对
bismark -o ./WT_mESC_rep1/bismark_result/ --parallel 4 --genome_folder ${genome_path} ./WT_mESC_rep1/trimmed_data/*.fq.gz
bismark -o ./TetTKO_mESC_rep1/bismark_result/ --parallel 4 --genome_folder ${genome_path} ./TetTKO_mESC_rep1/trimmed_data/*.fq.gz
## -o/--output_dir <dir>:指定输出目录。
## --parallel/--multicore <int>：设置Bismark并行运行个数。
## --genome_folder:包含未修改的参考基因组以及bismark_genome_preparation脚本生成的子目录的路径。

# 合并WT_mESC_rep1的 .bam 文件
samtools cat -o SRX4241790_trimmed_bismark_bt2.bam ./WT_mESC_rep1/bismark_result/*.bam
## cat:连接BAMs（-o FILE:输出的文件类型BAM/CRAM）

mv SRX4241790_trimmed_bismark_bt2.bam ./WT_mESC_rep1/bismark_result
```

### 3.3 去除比对的重复reads
哺乳动物的基因组巨大，不太可能遇到一些真正独立且与相同基因组位置对齐的片段，而更可能是PCR扩增的结果。因此，对于大型基因组，删除duplicate reads是甲基化分析采取的有效途径，可以通过`deduplicate_bismark`脚本完成`deduplication`。

```bash
cd $HOME/project/NBT_repeat/data/seq_data/
mkdir -p ./WT_mESC_rep1/deduplicated_result/
mkdir -p ./TetTKO_mESC_rep1/deduplicated_result/

# 去除比对的重复reads
deduplicate_bismark --bam --output_dir ./WT_mESC_rep1/deduplicated_result/ ./WT_mESC_rep1/bismark_result/SRX4241790_trimmed_bismark_bt2.bam
deduplicate_bismark --bam --output_dir ./TetTKO_mESC_rep1/deduplicated_result/ ./TetTKO_mESC_rep1/bismark_result/*.bam
## --bam: 结果输出BAM格式文件。
## --output_dir [path]:指定输出目录。
```

### 3.4 甲基化信息提取
`Bismark`包中的`bimark_methylation_extractor`脚本可以从比对结果的文件中提取甲基化信息。此外，甲基化信息可以容易地转换为其他格式，便于下游分析。

```bash
genome_path="$HOME/project/NBT_repeat/data/genome_data"
cd $HOME/project/NBT_repeat/data/seq_data/
mkdir -p ./WT_mESC_rep1/extracting_result/
mkdir -p ./TetTKO_mESC_rep1/extracting_result/

# 甲基化信息提取
## Wild type
bismark_methylation_extractor --single-end --gzip --parallel 4 --bedGraph \
--cytosine_report --genome_folder ${genome_path} \
-o ./WT_mESC_rep1/extracting_result/ ./WT_mESC_rep1/deduplicated_result/*.bam 
## TetTKO type
bismark_methylation_extractor --single-end --gzip --parallel 4 --bedGraph \
--cytosine_report --genome_folder ${genome_path} \
-o ./TetTKO_mESC_rep1/extracting_result/ ./TetTKO_mESC_rep1/deduplicated_result/*.bam
## -s/--single-end:输入由单端测序数据生成的Bismark结果文件。
## --gzip:甲基化提取文件(CpG_OT_...，CpG_OB_... etc)以GZIP压缩形式输出以节省磁盘空间。
## --parallel/--multicore <int>：设置甲基化提取过程使用的内核数。
## --bedGraph:甲基化输出写入排序的bedGraph文件，提供胞嘧啶的位置及其甲基化状态。
## --cytosine_report:bedGraph转换完成后，生成全基因组所有胞嘧啶甲基化报告。
## --genome_folder <path>:指定用于甲基化提取的基因组的路径。
## -o/--output_dir DIR: 指定输出目录。
```

## 4 下游分析
基于甲基化分析过程中获得的甲基化信息结果，可以进行一些基本的下游分析，包括寻找特定位点、检测差异甲基化位点或区域（DML/DMR，differential methylation loci/regions）。使用[`DSS`](http://bioconductor.org/packages/release/bioc/html/DSS.html)R包进行差异甲基化分析。

### 4.1 输入数据准备
`DSS` 需要将每个BS-seq样实验数据汇总为每个CG位点的以下信息：染色体数，基因组坐标，总reads数及显示甲基化的reads数。输入数据可以从bismarkd的结果`.cov`文件传输，因为count文件包含以下列：chr，start，end，methylation%，count methylated，count unmethylated。

```bash
mkdir -p $HOME/project/NBT_repeat/R_analysis/WT_data
mkdir -p $HOME/project/NBT_repeat/R_analysis/TetTKO_data
cd $HOME/project/NBT_repeat/R_analysis/

# 存储文件路径信息
file_WT_path="$HOME/project/NBT_repeat/data/seq_data/WT_mESC_rep1/extracting_result/SRX4241790_trimmed_bismark_bt2.deduplicated.bismark.cov.gz"
file_TetTKO_path="$HOME/project/NBT_repeat/data/seq_data/TetTKO_mESC_rep1/extracting_result/SRR7368845_trimmed_bismark_bt2.deduplicated.bismark.cov.gz"

# 复制结果文件到R_analysis文件夹
cp ${file_WT_path} ./WT_data/
cp ${file_TetTKO_path} ./TetTKO_data/

# 解压文件
gunzip -d ./WT_data/SRX4241790_trimmed_bismark_bt2.deduplicated.bismark.cov.gz
gunzip -d ./TetTKO_data/SRR7368845_trimmed_bismark_bt2.deduplicated.bismark.cov.gz

# 将 .cov 文件传输到 .txt 文件
cp ./WT_data/SRX4241790_trimmed_bismark_bt2.deduplicated.bismark.cov ./WT_data/SRX4241790_methylation_result.txt
cp ./TetTKO_data/SRR7368845_trimmed_bismark_bt2.deduplicated.bismark.cov ./TetTKO_data/SRR7368845_methylation_result.txt
```

```r
# 安装
install.packages("tydir")
install.packages("dplyr") 

# 加载
library(tidyr)
library(dplyr)

setwd("C:/Users/19065/project/NBT_repeat/R_analysis")
file_names <- c("./WT_data/SRX4241790_methylation_result.txt", "./TetTKO_data/SRR7368845_methylation_result.txt")

func_read_file <- function(file_name){
	dir_vec <- strsplit(file_name, split = "/")[[1]]
	len <- length(dir_vec)
	file_prefix = substring(dir_vec[len], 0, nchar(dir_vec[len]) - 4)
	file_save_path = substring(file_name, 0, nchar(file_name) - nchar(dir_vec[len]))
	print(paste("File", file_name, "is being importing and this may take a while..."), sep = "")
	rawdata_df <- read.table(file_name, header = F, stringsAsFactors = F)
	print("Importing file is finished!")
	colnames(rawdata_df) <- c("chr", "start", "end", "methyl%", "methyled", "unmethyled")
	write.table(rawdata_df, paste(file_save_path, file_prefix, "_transfered.txt", sep = ""), row.names = F )
}

lapply(file_names, func_read_file)

q()
```

```bash
# 或使用Rscript处理
Rscript $HOME/Scrpits/methylation-analysis/Scripts/R/bismark_result_transfer.R ./WT_data/SRX4241790_methylation_result.txt ./TetTKO_data/SRR7368845_methylation_result.txt
```

### 4.2 检测 DML/DMR
输入数据准备完成后，使用`DSS`包寻找DMLs或DMRs。

```r
library(tidyr)
library(dplyr)
library(DSS)

first_file <- "./WT_data/SRX4241790_methylation_result_transfered.txt"
second_file <- "./TetTKO_data/SRR7368845_methylation_result_transfered.txt"
file_prefix <- "mm_all_chr"
file_save_path <- "./"

# 输入数据
first_raw_data <- read.table(first_file, header = T, stringsAsFactors = F)
second_raw_data <- read.table(second_file, header = T, stringsAsFactors = F)

# 数据操作为BSseq异议做准备
DSS_first_input_data <- first_raw_data %>%
	mutate(chr = paste("chr", chr, sep = "")) %>%
	mutate(pos = start, N = methyled + unmethyled, X = methyled) %>%
	select(chr, pos, N, X)
DSS_second_input_data <- second_raw_data %>%
	mutate(chr = paste("chr", chr, sep = "")) %>%
	mutate(pos = start, N = methyled + unmethyled, X = methyled) %>%
	select(chr, pos, N, X)

# 创建BSseq对象并进行静态测试
bsobj <- makeBSseqData(list(DSS_first_input_data, DSS_second_input_data), c("S1", "S2"))
dmlTest <- DMLtest(bsobj, group1 = c("S1"), group2 = c("S2"), smoothing = T)

# 检测 DMLs
dmls <- callDML(dmlTest, p.threshold = 0.001)

# 检测 DMRs
dmrs <- callDMR(dmlTest, p.threshold=0.01)

# 输出结果
write.table(dmlTest, paste(file_save_path, file_prefix, "_DSS_test_result.txt", sep = ""), row.names = F)
write.table(dmls, paste(file_save_path, file_prefix, "_DSS_dmls_result.txt", sep = ""), row.names = F)
write.table(dmrs, paste(file_save_path, file_prefix, "_DSS_dmrs_result.txt", sep = ""), row.names = F)
```

```bash
# 或使用Rscript处理
Rscript $HOME/Scripts/methylation-analysis/Scripts/R/DSS_differ_analysis.R ./WT_data/SRX4241790_methylation_result.txt ./TetTKO_data/SRR7368845_methylation_result.txt mm_chr_all ./
```

## 5 实际甲基化信息分析
提出了一种简单的方法来利用从传统甲基化分析流程中的甲基化信息.

## 6 参考
* [Aria2 Manual](https://aria2.github.io/manual/en/html/index.html)
* [Bismark User Guide](https://rawgit.com/FelixKrueger/Bismark/master/Docs/Bismark_User_Guide.html)
* [DSS package Manual](http://bioconductor.org/packages/release/bioc/manuals/DSS/man/DSS.pdf）



## NOTE

* function():命名和创建函数。
```r
f <- function(<arguments>){
	## Do something interesting
}
```

* strsplit()：分割字符串。
```r
strsplit(x, split, fixed = F, perl = F, useBytes = F)
```

* substring():提取字符向量中的子串。
```r
substring (text, first, last)
```

* length():返回字符数量。
* nchar():返回字符串长度。