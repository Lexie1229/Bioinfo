# R函数

### c()
c(),用于将参数组合成向量(或列表).
* c(..., recursive = FALSE)
    * recursive：指定是否递归地组合列表和嵌套向量中的元素.

### callDML()
callDML(),用于对DNA甲基化数据进行甲基化差异位点的检测.
* callDML(dmlTest, p.threshold = 0.05, adjust = "BH", bAdjust = NULL, direction = NULL, verbose = FALSE)
    * dmlTest：一个DMLtest对象，该对象包含了甲基化差异位点的统计信息.
    * p.threshold：显著性水平.
    * adjust：用于多重检验校正的方法.
    * bAdjust：用于指定是否进行贝叶斯校正；direction用于指定差异方向.
    * verbose：用于控制是否输出详细的运行信息.

### callDMR
callDMR(),用于对DNA甲基化数据进行甲基化差异区域的检测.
* callDMR(dmlTest, p.threshold = 0.05, adjust = "BH", bAdjust = NULL, direction = NULL, mergeDistance = NULL, verbose = FALSE, ...)
    * dmlTest：一个DMLtest对象，该对象包含了甲基化差异位点的统计信息.
    * p.threshold：显著性水平.
    * adjust：用于多重检验校正的方法.
    * bAdjust：用于指定是否进行贝叶斯校正.
    * direction：用于指定差异方向.
    * mergeDistance：用于指定DMR之间的最大距离.
    * verbose：用于控制是否输出详细的运行信息.

### colnames()
colnames(),用于获取或设置一个数据框(data frame)的列名.
* colnames(x) <- value
    * x：一个数据框对象.
    * value：一个字符向量，用于设置数据框的列名，如果省略value参数，则colnames()函数返回数据框的列名.

### function()
function(),用于命名和创建函数.
* my_function <- function(arguments){# function body}
    * my_function：函数的名称.
    * arguments：函数的参数.
    * function body(函数体)：一组执行指定任务的语句，可以访问参数和其他变量，并生成输出结果.

### lapply()
lapply(),用于对列表、矩阵、向量等数据类型的每个元素应用指定的函数，并返回一个包含结果的列表.
* lapply(X, FUN, ...)
    * X：要应用函数的列表或向量.
    * FUN：要应用的函数.

### length()
length(),用于计算对象中的元素数量.
* length(x)
    * x：一个R对象，可以是向量、列表、矩阵、数据框、数组等.

### nchar()
nchar(),用于计算字符串长度.
* nchar(x, type = "any")
    * x：要计算长度的字符串或字符向量.
    * type：一个可选参数，指定如何计算长度，默认值为"any"，表示计算所有字符的长度，如果设置为"bytes"，则只计算字节数.

### paste()
paste()，用于将多个字符串拼接成一个字符串.
* paste(..., sep = " ", collapse = NULL)
    * ...：要拼接的字符串，可以是多个.
    * sep：用于分隔字符串的分隔符，默认值为一个空格.
    * collapse：用于合并多个向量的可选参数.

### print()
print(),用于打印输出.
* print(x, ...)
    * x：要输出的对象.
    * ...：一些可选参数，比如控制输出格式的参数等.

### read.table()
read.table(),用于读取表格型文本数据.
* data <- read.table("example.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)
    * file：文件名或连接符，指定读取数据的文件名或URL地址等.
    * header：是否将第一行数据作为表头.
    * sep：字符串，用于指定数据中各字段之间的分隔符.
    * stringsAsFactors：是否将字符型变量转换为因子型变量.

### setwd()
setwd(),用于设置当前的工作目录.
* setwd(dir)
    * dir:一个字符串，表示要设置为当前工作目录的目录路径.

### strsplit()
strsplit(),用于分割字符串，根据指定的分隔符将其拆分成子字符串，并将这些子字符串存储在一个列表中.
* strsplit(x, split, fixed = F, perl = F, useBytes = F)
    * x：要被拆分的字符串或字符向量.
    * split：用于分隔字符串的字符或正则表达式.
    * fixed：split是否应该被视为普通字符而不是正则表达式，默认为FALSE，即split是正则表达式.

### substring()
substring(),用于从字符串中提取一个子串.
* substring(text, first = 1, last = nchar(text))
    * text：一个字符串.
    * first：整数，表示要提取的子串的起始位置.
    * last：整数，表示要提取的子串的结束位置.

### write.table()
write.table(),用于将数据写入一个以指定分隔符分隔的文本文件中.
* write.table(x, file, sep = " ", quote = TRUE, dec = ".", row.names = TRUE, col.names = TRUE,... )
    * x：要写入文件的数据，可以是一个数据框、矩阵或向量等R中支持的数据类型.
    * file：要写入的文件名，可以是一个字符向量或连接字符的字符串，如果文件已存在则将它覆盖，否则创建一个新文件.
    * sep：分隔符，用于分隔每列数据的值，默认为" "，即空格.
    * quote：是否应该将字符串用双引号引起来，默认为TRUE.
    * dec：浮点数的小数点分隔符，默认为..
    * row.names：是否应该在文件中包含行名，默认为TRUE.
    * col.names：是否应该在文件中包含列名，默认为TRUE.

# R 包

### ape

* ape(Analyses of Phylogenetics and Evolution):Functions for reading, writing, plotting, and manipulating phylogenetic trees, analyses of comparative data in a phylogenetic framework, ancestral character analyses, analyses of diversification and macroevolution, computing distances from DNA sequences, reading and writing nucleotide sequences as well as importing from BioConductor, and several tools such as Mantel's test, generalized skyline plots, graphical exploration of phylogenetic data (alex, trex, kronoviz), estimation of absolute evolutionary rates and clock-like trees using mean path lengths and penalized likelihood, dating trees with non-contemporaneous sequences, translating DNA into AA sequences, and assessing sequence alignments. Phylogeny estimation can be done with the NJ, BIONJ, ME, MVR, SDM, and triangle methods, and several methods handling incomplete distance matrices (NJ*, BIONJ*, MVR*, and the corresponding triangle method). Some functions call external applications (PhyML, Clustal, T-Coffee, Muscle) whose results are returned into R.

### dplyr

* dplyr(A Grammar of Data Manipulation)：A fast, consistent tool for working with data frame like objects, both in memory and out of memory.

### readr

* readr(Read Rectangular Text Data)：The goal of 'readr' is to provide a fast and friendly way to read rectangular data (like 'csv', 'tsv', and 'fwf'). It is designed to flexibly parse many types of data found in the wild, while still cleanly failing when data unexpectedly changes.

### tidyr

* tidyr(Tidy Messy Data)：Tools to help to create tidy data, where each column is a variable, each row is an observation, and each cell contains a single value. 'tidyr' contains tools for changing the shape (pivoting) and hierarchy (nesting and 'unnesting') of a dataset, turning deeply nested lists into rectangular data frames ('rectangling'), and extracting values out of string columns. It also includes tools for working with missing values (both implicit and explicit).


## Bioconductor

### DSS
DSS(Dispersion shrinkage for sequencing data)：DSS is an R library performing differntial analysis for count-based sequencing data. It detectes differentially expressed genes (DEGs) from RNA-seq, and differentially methylated loci or regions (DML/DMRs) from bisulfite sequencing (BS-seq). The core of DSS is a new dispersion shrinkage method for estimating the dispersion parameter from Gamma-Poisson or Beta-Binomial distributions.

# Others
* [[1]]：表示访问一个列表中的第一个元素；列表中的每个元素都可以使用双方括号（[[ ]]）或美元符号（$）来访问，使用双方括号[[ ]]访问列表元素时，可以使用元素的索引或名称.