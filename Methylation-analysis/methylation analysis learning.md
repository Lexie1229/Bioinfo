# [甲基化分析](https://github.com/Jihong-Tang/methylation-analysis/tree/master/NBT_repeat)
## 0 介绍

* APOBEC偶联甲基化表观测序(ACE-seq)可以特异性检测5hmC（5-羟甲基胞嘧啶）。基于[NBT文章](https://www.nature.com/articles/nbt.4204)中的ACE-seq数据，学习在小鼠（mouse）样本中寻找5hmc DMLs（differentially methylated loci，差异甲基化位点）的生物信息流程，学习基于[`bismark`](https://github.com/FelixKrueger/Bismark)和[`DSS`](http://bioconductor.org/packages/release/bioc/html/DSS.html) 软件工具包的甲基化数据分析程序，熟悉基本的生物信息数据分析协议。

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

* 对高通量测序进行质量控制，以直接判断数据集是否质量良好以及文库或测序本身是否存在基本问题。使用[FastQc](www.bioinformatics.babraham.ac.uk/projects/fastqc/)进行质量控制，并使用[Trim Galore](www.bioinformatics.babraham.ac.uk/projects/trim_galore/)修剪接头。

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

* 质量控制和修剪后，遵循基于[Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)的BS-seq数据分析协议对ACE-seq数据进行甲基化分析。

### 3.1 基因组索引

* 序列比对前，基因组需要*in-silico*亚硫酸氢盐转化并索引。基于`Bismark`，可以同时使用`Bowtie`和`Bowtie2`完成索引。

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

* 甲基化数据分析的核心是将测序reads与参考基因组比对。

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

* 哺乳动物的基因组巨大，不太可能遇到一些真正独立且与相同基因组位置对齐的片段，而更可能是PCR扩增的结果。因此，对于大型基因组，删除duplicate reads是甲基化分析采取的有效途径，可以通过`deduplicate_bismark`脚本完成`deduplication`。

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

* `Bismark`包中的`bimark_methylation_extractor`脚本可以从比对结果的文件中提取甲基化信息。此外，甲基化信息可以容易地转换为其他格式，便于下游分析。

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

* 基于甲基化分析过程中获得的甲基化信息结果，可以进行一些基本的下游分析，包括寻找特定位点、检测差异甲基化位点或区域（DML/DMR，differential methylation loci/regions）。使用[`DSS`](http://bioconductor.org/packages/release/bioc/html/DSS.html)R包进行差异甲基化分析。

### 4.1 输入数据准备

* `DSS` 需要将每个BS-seq样实验数据汇总为每个CG位点的以下信息：染色体数，基因组坐标，总reads数及显示甲基化的reads数。输入数据可以从bismarkd的结果`.cov`文件传输，因为count文件包含以下列：chr，start，end，methylation%，count methylated，count unmethylated。

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
# 安装R包
install.packages("tidyr")
install.packages("dplyr")

# 加载R包
library(tidyr)
library(dplyr)

# 设置工作目录
setwd("C:/Users/19065/project/NBT_repeat/R_analysis")
## setwd(dir)函数，用于设置当前的工作目录；dir是一个字符串，表示要设置为当前工作目录的目录路径。

# 定义向量
file_names <- c("./WT_data/SRX4241790_methylation_result.txt", "./TetTKO_data/SRR7368845_methylation_result.txt")
## c(..., recursive = FALSE)函数，用于将参数组合成向量（或列表）；recursive表示指定是否递归地组合列表和嵌套向量中的元素

# 定义函数
func_read_file <- function(file_name){
	## my_function <- function(<arguments>){# function body}函数，用于命名和创建函数;my_function表示函数的名称；arguments表示函数的参数；函数体（function body）表示一组执行指定任务的语句，这些语句可以访问参数和其他变量，并生成输出结果。

	# 分割元素，获得列表，如"./WT_data/SRX4241790_methylation_result.txt"
	dir_vec <- strsplit(file_name, split = "/")[[1]]
	## strsplit(x, split, fixed = F, perl = F, useBytes = F)函数，用于分割字符串，根据指定的分隔符将其拆分成子字符串，并将这些子字符串存储在一个列表中；x表示要被拆分的字符串或字符向量；split表示用于分隔字符串的字符或正则表达式；fixed表示split是否应该被视为普通字符而不是正则表达式，默认为FALSE，即split是正则表达式。
	## [[1]]表示访问一个列表中的第一个元素；列表中的每个元素都可以使用双方括号（[[ ]]）或美元符号（$）来访问，使用双方括号[[ ]]访问列表元素时，可以使用元素的索引或名称

	# 计算列表元素数量，如3
	len <- length(dir_vec)
	## length(x)函数，用于计算对象中的元素数量；x表示一个R对象，可以是向量、列表、矩阵、数据框、数组等。

	# 提取文件前缀，如SRX4241790_methylation_result
	file_prefix = substring(dir_vec[len], 0, nchar(dir_vec[len]) - 4)
	## substring(text, first = 1, last = nchar(text))函数，用于从字符串中提取一个子串；text表示一个字符串；first和last是整数，表示要提取的子串的起始和结束位置。
	## nchar(x, type = "any")函数，用于计算字符串长度；x表示要计算长度的字符串或字符向量；type是一个可选参数，指定如何计算长度，默认值为"any"，表示计算所有字符的长度，如果设置为"bytes"，则只计算字节数。

	# 提取文件保存路径，如./WT_data/
	file_save_path = substring(file_name, 0, nchar(file_name) - nchar(dir_vec[len]))

	# 输出提示信息
	print(paste("File", file_name, "is being importing and this may take a while..."), sep = "")
	## paste(..., sep = " ", collapse = NULL)函数，用于将多个字符串拼接成一个字符串；...表示要拼接的字符串，可以是多个；sep表示用于分隔字符串的分隔符，默认值为一个空格；collapse表示用于合并多个向量的可选参数。
	## print(x, ...)函数，用于打印输出；x表示要输出的对象；...表示一些可选参数，比如控制输出格式的参数等。

	# 读取数据
	rawdata_df <- read.table(file_name, header = F, stringsAsFactors = F)
	## read.table(file, header = TRUE, sep = "", quote = "\"'",dec = ".", fill = TRUE, comment.char = "", ...)函数，用于从文本文件中读取数据；file表示要读取的文件名或路径；header表示文件是否有标题行，默认为TRUE，表示第一行是标题行；sep:表示字段之间的分隔符，默认为空格；quote表示字符串的边界字符，默认为双引号和单引号；dec表示数值型列的小数点分隔符，默认为.；fill表示是否用NA值填充空值，默认为TRUE；comment.char表示注释行，默认为#。
	## stringsAsFactors = F表示读入字符型数据时不将其转换为因子（factor）类型，以避免因子类型的不必要转换和处理所带来的麻烦。

	# 输出提示信息
	print("Importing file is finished!")

	# 设置列名
	colnames(rawdata_df) <- c("chr", "start", "end", "methyl%", "methyled", "unmethyled")
	## colnames(x) <- value函数，用于获取或设置一个数据框（data frame）的列名；x表示一个数据框对象；value表示一个字符向量，用于设置数据框的列名，如果省略value参数，则colnames()函数返回数据框的列名。

	# 数据写入文件
	write.table(rawdata_df, paste(file_save_path, file_prefix, "_transfered.txt", sep = ""), row.names = F )
	## write.table(x, file, sep = " ", quote = TRUE, dec = ".", row.names = TRUE, col.names = TRUE,... )函数，用于将数据写入一个以指定分隔符分隔的文本文件中；x表示要写入文件的数据，可以是一个数据框、矩阵或向量等R中支持的数据类型；file表示要写入的文件名，可以是一个字符向量或连接字符的字符串，如果文件已存在则将它覆盖，否则创建一个新文件；sep:表示分隔符，用于分隔每列数据的值，默认为" "，即空格；quote表示是否应该将字符串用双引号引起来，默认为TRUE；dec表示浮点数的小数点分隔符，默认为.；row.names和col.names表示是否应该在文件中包含行名和列名，默认为TRUE。
}

# 调用函数，逐一处理向量元素
lapply(file_names, func_read_file)
## lapply(X, FUN, ...)函数，用于对列表、矩阵、向量等数据类型的每个元素应用指定的函数，并返回一个包含结果的列表；X表示要应用函数的列表或向量；FUN表示要应用的函数。

q()
```

```bash
# 或使用Rscript处理
Rscript $HOME/Scrpits/methylation-analysis/Scripts/R/bismark_result_transfer.R ./WT_data/SRX4241790_methylation_result.txt ./TetTKO_data/SRR7368845_methylation_result.txt
```

### 4.2 检测 DML/DMR

* 输入数据准备完成后，使用`DSS`包寻找DMLs或DMRs。

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
## data <- read.table("example.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)函数，用于读取表格型文本数据；file表示文件名或连接符，指定读取数据的文件名或URL地址等；header表示是否将第一行数据作为表头；sep:表示字符串，用于指定数据中各字段之间的分隔符；stringsAsFactors表示是否将字符型变量转换为因子型变量。

# 数据操作为BSseq objection做准备
DSS_first_input_data <- first_raw_data %>%
	mutate(chr = paste("chr", chr, sep = "")) %>%
	mutate(pos = start, N = methyled + unmethyled, X = methyled) %>%
	select(chr, pos, N, X)
DSS_second_input_data <- second_raw_data %>%
	mutate(chr = paste("chr", chr, sep = "")) %>%
	mutate(pos = start, N = methyled + unmethyled, X = methyled) %>%
	select(chr, pos, N, X)
## %>%表示管道操作符，用于将数据从一个函数或操作的输出传递到另一个函数或操作的输入。
## mutate(.data, new_var = expression, ...)函数，用于在数据框中添加新的变量或对现有变量进行转换；.data表示要进行操作的数据框；new_var表示新变量的名称，可以是任何有效的R语言变量名；expression表示对新变量进行计算的表达式。
## select(.data, var1, var2, ..., varn)函数，用于选择数据框中的列或变量；.data表示要进行操作的数据框；var1、var2、...、varn表示要选择的变量或列的名称。

# 创建BSseq对象并进行差异分析测试
bsobj <- makeBSseqData(list(DSS_first_input_data, DSS_second_input_data), c("S1", "S2"))
dmlTest <- DMLtest(bsobj, group1 = c("S1"), group2 = c("S2"), smoothing = T)
## makeBSseqData(data, sampleNames, assembly = NULL, annotation = NULL, colData = NULL, removeDuplicates = FALSE, verbose = FALSE)函数，用于将DNA甲基化数据转换为BSseq对象；data表示一个数据框列表，其中每个数据框代表一个样本的DNA甲基化数据；sampleNames表示一个字符向量，指定每个样本的名称；assembly和annotation参数是可选的，用于指定数据的基因组组装版本和注释信息；colData表示一个数据框，用于指定每个样本的其他相关信息，例如性别、年龄等；removeDuplicates表示是否删除重复的CpG位点；verbose表示是否输出详细的运行信息。
## DMLtest(bsobj, group1, group2, formula = NULL, mincov = 5, minNumSNPs = 3, pAdjustMethod = "BH", alpha = 0.05, bAdjust = NULL, verbose = FALSE, ncores = 1, minQ = NULL, minDelta = NULL, direction = NULL, smoothing = FALSE, smooth_window_size = 3, smooth_sd = 1, mc.cores = 1, ignore_chroms = NULL, ignore_cpgs = NULL, ignore_samples = NULL)函数，用于对DNA甲基化数据进行差异分析；bsobj表示一个BSseq对象；group1和group2表示用于比较的两个样本组别；formula表示一个公式对象，用于指定模型中的自变量和因变量关系；mincov和minNumSNPs表示关于数据过滤的参数，用于指定最小测序深度和最小位点数；pAdjustMethod表示用于多重检验校正的方法；alpha表示显著性水平；bAdjust表示是否进行贝叶斯校正；verbose表示是否输出详细的运行信息；ncores表示用于并行计算的核数；minQ和minDelta表示关于DMR过滤的参数，用于指定最小的FDR和甲基化差异值；direction用于指定差异方向；smoothing表示是否对甲基化水平进行平滑处理；smooth_window_size和smooth_sd用于指定平滑的窗口大小和标准差；mc.cores用于指定并行计算的核数；ignore_chroms、ignore_cpgs和ignore_samples表示关于数据过滤的参数，用于忽略某些染色体、CpG位点或样本。

# 检测 DMLs
dmls <- callDML(dmlTest, p.threshold = 0.001)
## callDML(dmlTest, p.threshold = 0.05, adjust = "BH", bAdjust = NULL, direction = NULL, verbose = FALSE)函数，用于对DNA甲基化数据进行甲基化差异位点的检测；dmlTest表示一个DMLtest对象，该对象包含了甲基化差异位点的统计信息；p.threshold表示显著性水平；adjust用于多重检验校正的方法；bAdjust用于指定是否进行贝叶斯校正；direction用于指定差异方向；verbose用于控制是否输出详细的运行信息。

# 检测 DMRs
dmrs <- callDMR(dmlTest, p.threshold=0.01)
## callDMR(dmlTest, p.threshold = 0.05, adjust = "BH", bAdjust = NULL, direction = NULL, mergeDistance = NULL, verbose = FALSE, ...)函数，用于对DNA甲基化数据进行甲基化差异区域的检测；dmlTest表示一个DMLtest对象，该对象包含了甲基化差异位点的统计信息；p.threshold表示显著性水平；adjust表示用于多重检验校正的方法；bAdjust用于指定是否进行贝叶斯校正；direction用于指定差异方向；mergeDistance用于指定DMR之间的最大距离；verbose用于控制是否输出详细的运行信息。

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

* 提出了一种简单的方法来利用从传统甲基化分析流程中的甲基化信息.

## 6 参考
* [Aria2 Manual](https://aria2.github.io/manual/en/html/index.html)
* [Bismark User Guide](https://rawgit.com/FelixKrueger/Bismark/master/Docs/Bismark_User_Guide.html)
* [DSS package Manual](http://bioconductor.org/packages/release/bioc/manuals/DSS/man/DSS.pdf)




