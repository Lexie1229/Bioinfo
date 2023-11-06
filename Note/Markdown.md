## [Markdown 基本语法](https://markdown.com.cn/)

### 1 标题（Heading）语法
创建标题，在单词或短语前面添加井号(#)。# 的数量代表了标题的级别。还可以在文本下方添加任意数量的 == 号来标识一级标题，或者 -- 号来标识二级标题。不同的 Markdown 应用程序处理 # 和标题之间的空格方式并不一致。为了兼容考虑，请用一个空格在 # 和标题之间进行分隔。 
> <h3>Heading level 3 (H3)</h3>
> <h6>Heading level 6 (H6)</h6>

### 2 段落（Paragraph）语法 
创建段落，使用空白行将一行或多行文本进行分隔。注意不要使用空格（spaces）或制表符（ tabs）缩进段落。
> <p>I really like using Markdown.</p>

### 3 换行（Line Break）语法
在一行的末尾添加两个或多个空格，然后按回车键，即可创建一个换行。为了兼容性，请在行尾添加“结尾空格”（trailing whitespace)或 HTML 的 br 标签来实现换行。
> <p>This is the first line.<br>And this is the second line.</p>

### 4 强调语法
#### 粗体（Blod）
加粗文本，在单词或短语的前后各添加两个星号（asterisks）或下划线（underscores）。如需加粗一个单词或短语的中间部分用以表示强调的话，请在要加粗部分的两侧各添加两个星号（asterisks）。Markdown 应用程序在如何处理单词或短语中间的下划线上并不一致。为兼容考虑，在单词或短语中间部分加粗的话，请使用星号（asterisks）。
> I just love <strong>bold text</strong>.

#### 斜体（Italic）
斜体显示文本，请在单词或短语前后添加一个星号（asterisk）或下划线（underscore）。要斜体突出单词的中间部分，请在字母前后各添加一个星号，中间不要带空格。
> Italicized text is the <em>cat's meow</em>.

#### 粗体+斜体
同时使用粗体和斜体突出显示文本，请在单词或短语的前后各添加三个星号或下划线。要加粗并用斜体显示单词或短语的中间部分，请在要突出显示的部分前后各添加三个星号，中间不要带空格。
> This text is <strong><em>really important</em></strong>.

### 5 引用语法
创建块引用，请在段落前添加一个 > 符号。

#### 多个段落的块引用
块引用可以包含多个段落。为段落之间的空白行添加一个 > 符号。
> Dorothy followed her through many of the beautiful rooms in her castle.
>
> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.

#### 嵌套块引用
块引用可以嵌套。在要嵌套的段落前添加一个 >> 符号。
> Dorothy followed her through many of the beautiful rooms in her castle.
>
>> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.

#### 带有其它元素的块引用
带有其它元素的块引用
块引用可以包含其他 Markdown 格式的元素。并非所有元素都可以使用，你需要进行实验以查看哪些元素有效。
> ##### The quarterly results look great!
>> - Revenue was off the chart.
> *Everything* is going according to **plan**.

### 6 列表语法
可以将多个条目组织成有序或无序列表。
#### 有序列表(ordered list)
创建有序列表，请在每个列表项前添加数字并紧跟一个英文句点。数字不必按数学顺序排列，但是列表应当以数字 1 起始。
>  <ol>
> <li>First item</li>
> <li>Second item</li>
> <li>Third item
> <ol>
> <li>Indented item</li>
> <li>Indented item</li>
> </ol>
> </li>
> <li>Fourth item</li>
> </ol>

#### 无序列表(unordered list)
创建无序列表，请在每个列表项前面添加破折号 (-)、星号 (*) 或加号 (+) 。缩进一个或多个列表项可创建嵌套列表。
> <ul>
> <li>First item</li>
> <li>Second item</li>
> <li>Third item
> <ul>
> <li>Indented item</li>
> <li>Indented item</li>
> </ul>
> </li>
> <li>Fourth item</li>
> </ul>

#### 在列表中嵌套其他元素
要在保留列表连续性的同时在列表中添加另一种元素，请将该元素缩进四个空格或一个制表符，如下例所示:
> * 段落
> * 引用块
> * 代码块   
    代码块通常采用四个空格或一个制表符缩进。当它们被放在列表中时，请将它们缩进八个空格或两个制表符。
> * 图片

### 7 代码语法
要将单词或短语表示为代码，请将其包裹在反引号 (`) 中.
> At the command prompt, type <code>nano</code>.

#### 转义反引号

### 8 分割线语法

### 9 链接语法

### 10 图片语法

### 11 转义字符语法

### 12 内嵌HTML标签