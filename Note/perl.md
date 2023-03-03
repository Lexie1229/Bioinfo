perl
* -n：assume "while (<>) { ... }" loop around program(读取输入文件或stdin，将每行内容作为$_变量的值，并依次执行Perl代码块).
* -e commandline：one line of program (several -e's allowed, omit programfile)(一行的程序（允许几个-e，省略程序文件）).
* -p:assume loop like -n but print line also, like sed(与-n选项类似，但每行的内容都被自动打印出来).
* -l[octnum]:enable line ending processing, specifies line terminator(在输出时自动添加一个换行符，以及在输入时自动剥离换行符。).
* -a:autosplit mode with -n or -p (splits $_ into @F)(具有-n或-p选项，将输入行按指定分隔符分割成数组，赋值给@F数组变量).
* -F/pattern/:split() pattern for -a switch (//'s are optional)(指定输入分隔符，用于-a选项，默认为使用空格作为分隔符).