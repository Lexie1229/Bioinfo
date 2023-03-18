# R函数

### setwd()
setwd(),用于设置当前的工作目录.
* setwd(dir)
    * dir:一个字符串，表示要设置为当前工作目录的目录路径.

### c()
c(),用于将参数组合成向量(或列表).
* c(..., recursive = FALSE)
    * recursive：指定是否递归地组合列表和嵌套向量中的元素.

### function()
function(),用于命名和创建函数.
* my_function <- function(arguments){# function body}
    * my_function：函数的名称.
    * arguments：函数的参数.
    * function body(函数体)：一组执行指定任务的语句，可以访问参数和其他变量，并生成输出结果.

### strsplit()
strsplit(),用于分割字符串，根据指定的分隔符将其拆分成子字符串，并将这些子字符串存储在一个列表中.
* strsplit(x, split, fixed = F, perl = F, useBytes = F)
    * x：要被拆分的字符串或字符向量.
    * split：用于分隔字符串的字符或正则表达式.
    * fixed：split是否应该被视为普通字符而不是正则表达式，默认为FALSE，即split是正则表达式.

### length()
length(),用于计算对象中的元素数量.
* length(x)
    * x：一个R对象，可以是向量、列表、矩阵、数据框、数组等.

### lapply()
lapply(),用于对列表、矩阵、向量等数据类型的每个元素应用指定的函数，并返回一个包含结果的列表.
* lapply(X, FUN, ...)
    * X：要应用函数的列表或向量.
    * FUN：要应用的函数.


## data <- read.table("example.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)函数，用于读取表格型文本数据；file表示文件名或连接符，指定读取数据的文件名或URL地址等；header表示是否将第一行数据作为表头；sep:表示字符串，用于指定数据中各字段之间的分隔符；stringsAsFactors表示是否将字符型变量转换为因子型变量。



## [[1]]表示访问一个列表中的第一个元素；列表中的每个元素都可以使用双方括号（[[ ]]）或美元符号（$）来访问，使用双方括号[[ ]]访问列表元素时，可以使用元素的索引或名称



	
## substring(text, first = 1, last = nchar(text))函数，用于从字符串中提取一个子串；text表示一个字符串；first和last是整数，表示要提取的子串的起始和结束位置。

## nchar(x, type = "any")函数，用于计算字符串长度；x表示要计算长度的字符串或字符向量；type是一个可选参数，指定如何计算长度，默认值为"any"，表示计算所有字符的长度，如果设置为"bytes"，则只计算字节数。

	

## paste(..., sep = " ", collapse = NULL)函数，用于将多个字符串拼接成一个字符串；...表示要拼接的字符串，可以是多个；sep表示用于分隔字符串的分隔符，默认值为一个空格；collapse表示用于合并多个向量的可选参数。

## print(x, ...)函数，用于打印输出；x表示要输出的对象；...表示一些可选参数，比如控制输出格式的参数等。
   

## colnames(x) <- value函数，用于获取或设置一个数据框（data frame）的列名；x表示一个数据框对象；value表示一个字符向量，用于设置数据框的列名，如果省略value参数，则colnames()函数返回数据框的列名。


## write.table(x, file, sep = " ", quote = TRUE, dec = ".", row.names = TRUE, col.names = TRUE,... )函数，用于将数据写入一个以指定分隔符分隔的文本文件中；x表示要写入文件的数据，可以是一个数据框、矩阵或向量等R中支持的数据类型；file表示要写入的文件名，可以是一个字符向量或连接字符的字符串，如果文件已存在则将它覆盖，否则创建一个新文件；sep:表示分隔符，用于分隔每列数据的值，默认为" "，即空格；quote表示是否应该将字符串用双引号引起来，默认为TRUE；dec表示浮点数的小数点分隔符，默认为.；row.names和col.names表示是否应该在文件中包含行名和列名，默认为TRUE。


## lapply(X, FUN, ...)函数，用于对列表、矩阵、向量等数据类型的每个元素应用指定的函数，并返回一个包含结果的列表；X表示要应用函数的列表或向量；FUN表示要应用的函数。
## data <- read.table("example.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)函数，用于读取表格型文本数据；file表示文件名或连接符，指定读取数据的文件名或URL地址等；header表示是否将第一行数据作为表头；sep:表示字符串，用于指定数据中各字段之间的分隔符；stringsAsFactors表示是否将字符型变量转换为因子型变量。


## callDML(dmlTest, p.threshold = 0.05, adjust = "BH", bAdjust = NULL, direction = NULL, verbose = FALSE)函数，用于对DNA甲基化数据进行甲基化差异位点的检测；dmlTest表示一个DMLtest对象，该对象包含了甲基化差异位点的统计信息；p.threshold表示显著性水平；adjust用于多重检验校正的方法；bAdjust用于指定是否进行贝叶斯校正；direction用于指定差异方向；verbose用于控制是否输出详细的运行信息。

## callDMR(dmlTest, p.threshold = 0.05, adjust = "BH", bAdjust = NULL, direction = NULL, mergeDistance = NULL, verbose = FALSE, ...)函数，用于对DNA甲基化数据进行甲基化差异区域的检测；dmlTest表示一个DMLtest对象，该对象包含了甲基化差异位点的统计信息；p.threshold表示显著性水平；adjust表示用于多重检验校正的方法；bAdjust用于指定是否进行贝叶斯校正；direction用于指定差异方向；mergeDistance用于指定DMR之间的最大距离；verbose用于控制是否输出详细的运行信息。



install.packages("tidyr")
install.packages("dplyr")


library(DSS)
library(tidyr)
library(dplyr)