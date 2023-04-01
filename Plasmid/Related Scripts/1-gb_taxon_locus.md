[withncbi/taxon/gb_taxon_locus.pl](https://github.com/wang-q/withncbi/blob/master/taxon/gb_taxon_locus.pl)

```perl
#!/usr/bin/perl
use strict;
use warnings;
use autodie;  # automatically handle errors，自动处理常见的错误和异常情况

use Path::Tiny;

my $file = shift

if ( !$file ) {             # 检查是否传递了一个参数
    die "You should provide a .gb file.\n";
}
elsif ( !-e $file ) {       # 检查文件是否存在
    die "[$file] doesn't exist.\n";
}

$file = path($file);

my $content = $file->slurp;

my @gbs = grep {/\S+/} split( /^\/\//m, $content );  
# grep，匹配字符串，即去除空行
# split，以//为分隔符进行分割

printf STDERR "There are [%d] sequences.\n", scalar @gbs;

my $count;
for my $gb (@gbs) {
    my ( $locus, $taxon );

    if ( $gb =~ /LOCUS\s+(\w+)\s+/ ) {
        # =~，用于匹配正则表达式的操作符，用于判断一个字符串是否匹配某个模式，并可以将匹配的结果保存到变量中
        # \w，表示匹配任何单词字符，包括字母、数字或下划线字符
        # \s，表示匹配任何空白字符，包括空格、制表符、换行符、回车符等
        # 括号( )，表示将匹配到的内容分组，后续的代码中可以使用$1、$2等特殊变量引用这些分组
        $locus = $1;
    }
    else {
        warn "Can't get locus\n";
        next;
    }

    if ( $gb =~ /db_xref\=\"taxon\:(\d+)/ ) {
        $taxon = $1;
    }
    else {
        warn "Can't get taxon\n";
        next;
    }

    printf "%s,%s\n", $taxon, $locus;
    $count++;
}

printf STDERR "There are [%d] valid sequences.\n", $count;

__END__
# __END__，用于标识脚本的结尾，此后的内容不会被解析为perl代码，而被视为数据或注释

=head1 NAME
# =head1 NAME，一种特殊的文档标记（documentation tag），用于指定脚本的名称和简要说明
# 脚本名称 - 简要说明

gb_taxon_locus.pl - scan a multi-sequence .gb file


=head1 SYNOPSIS
# =head1 SYNOPSIS，脚本使用说明和示例

    wget -N ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/organelle/plastid/plastid.1.genomic.gbff.gz
    gzip -d plastid.1.genomic.gbff.gz
    
    perl gb_taxon_locus.pl plastid.1.genomic.gbff > refseq_id_seq.csv


=cut
# =cut，一种特殊的标记，用于标识Perl文档（Pod）的结束，用于指示Perl解释器停止解析文档内容

# Path::Tiny
## Slurp mode：
## Slurping the content of a file means reading all the content into one scalar variable.
## If the file has multiple lines, as usually text files do,
## then that scalarvariable will have new-line characters (represented by \n) in it.


# =head1 NAME，脚本名称 - 简要说明
# =head1 SYNOPSIS，脚本使用说明和示例
# =head1 DESCRIPTION，脚本详细说明和功能说明
# =head1 OPTIONS，脚本选项说明
# =head1 AUTHOR，脚本作者信息
# =head1 COPYRIGHT AND LICENSE，脚本版权和许可证说明
```