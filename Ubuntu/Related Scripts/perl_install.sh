
```
#!/bin/bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "${BASE_DIR}" || exit

hash cpanm 2>/dev/null || {
    curl -L https://cpanmin.us | perl - App::cpanminus
}

CPAN_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/CPAN/
NO_TEST=--notest

# basic modules
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Archive::Extract Config::Tiny File::Find::Rule Getopt::Long::Descriptive JSON JSON::XS Text::CSV_XS YAML::Syck
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST App::Ack App::Cmd DBI MCE Moo Moose Perl::Tidy Template WWW::Mechanize XML::Parser

# RepeatMasker need this
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Text::Soundex

# GD
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST GD SVG GD::SVG

# bioperl
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Data::Stag Test::Most URI::Escape Algorithm::Munkres Array::Compare Clone Error File::Sort Graph List::MoreUtils Set::Scalar Sort::Naturally
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST HTML::Entities HTML::HeadParser HTML::TableExtract HTTP::Request::Common LWP::UserAgent PostScript::TextBlock
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST *XML::DOh XML::SAX::Writer XML::Simple XML::Twig XML::Writer *GraphViz *SVG::GraphM *XML::DOM::XPat
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST SHLOMIF/XML-LibXML-2.0134.tar.gz
cpanm --mirror-only --mirror $CPAN_MIRROR --notest Convert::Binary::C IO::Scalar
cpanm --mirror-only --mirror $CPAN_MIRROR --notest CJFIELDS/BioPerl-1.007002.tar.gz

cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Bio::ASN1::EntrezGene Bio::DB::EUtilities Bio::Graphics
cpanm --mirror-only --mirror $CPAN_MIRROR --notest CJFIELDS/BioPerl-Run-1.007002.tar.gz # BioPerl-Run

# circos
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Config::General Data::Dumper Digest::MD5 Font::TTF::Font Math::Bezier Math::BigFloat Math::Round Math::VecStat
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Params::Validate Readonly Regexp::Common Set::IntSpan Statistics::Basic Text::Balanced Text::Format Time::HiRes

# Bio::Phylo
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST XML::XML2JSON PDF::API2 Math::CDF Math::Random
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Bio::Phylo

# Database and WWW
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST MongoDB LWP::Protocol::https Mojolicious

# text, rtf and xlsx
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Roman Text::Table RTF::Writer Chart::Math::Axis
cpanm --mirror-only --mirror $CPAN_MIRROR --notest Excel::Writer::XLSX Spreadsheet::XLSX Spreadsheet::ParseExcel Spreadsheet::WriteExcel

# Test::*
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Test::Class Test::Roo Test::Taint Test::Without::Module

# Moose and Moo
cpanm --mirror-only --mirror $CPAN_MIRROR --notest MooX::Options MooseX::Storage

# Develop
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST App::pmuninstall App::cpanoutdated Minilla Version::Next CPAN::Uploader

# Others
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST DateTime::Format::Natural DBD::CSV String::Compare Sereal PerlIO::gzip

# AlignDB::*
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST AlignDB::IntSpan AlignDB::Stopwatch
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST AlignDB::Codon AlignDB::DeltaG AlignDB::GC AlignDB::SQL AlignDB::Window AlignDB::ToXLSX
cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST App::RL App::Fasops App::Rangeops

# App::*
cpanm -nq https://github.com/wang-q/App-Plotr.git
cpanm -nq https://github.com/wang-q/App-Egaz.git

# Gtk3 stuffs
# cpanm --mirror-only --mirror $CPAN_MIRROR $NO_TEST Glib Cairo Cairo::GObject Glib::Object::Introspection Gtk3 Pango

# Math
# cpanm --mirror-only --mirror $CPAN_MIRROR --notest Math::Random::MT::Auto PDL Math::GSL

# Statistics::R would be installed in `brew.sh`
# DBD::mysql would be installed in `mysql8.sh`
```



hash cpanm 2>/dev/null || {
    curl -L https://cpanmin.us | perl - App::cpanminus
}


> * BASH_SOURCE[0]:等价于BASH_SOURCE,取得当前执行的shell文件所在的路径及文件名.
> * dirname:去除文件名中的非目录部分，仅显示与目录有关的部分.
> * pwd（Print Work Directory）：显示工作目录。
> * hash：记住或显示程序位置,提高命令的调用速率。
>> * linux系统下有一个hash表，每个SHLL独立，当新开一个SHELL的时候，hash表为空，每当执行过一条命令，hash表会记录下这条命令的路径，相当于缓存。第一次执行命令shell解释器默认会从PATH路径下寻找该命令的路径，当第二次使用该命令时，shell解释器首先会查看hash表，没有该命令才会去PATH路径下寻找。
>> * hash:不使用任何选项和参数的时候,hash命令显示执行该命令的次数，以及命令的完整路径。
>> * hash -l:输出的格式可用于输入或者再执行。显示hash表命令的路径，以及命令的名字。
>> * hash name：仅带参数不带选项，hash命令可用于清空具体命令的缓存中的次数。
> * /dev/null：一个特殊的设备文件，这个文件接收到任何数据都会被丢弃。null设备通常也被称为位桶（bit bucket）或黑洞。
> * 2>/dev/null：将标准错误（stderr，2）删掉。
> * cpanminus：是一个脚本，用于从CPAN获取、解压、构建和安装模块。
> * curl -L https://cpanmin.us | perl - App::cpanminus：使用最新的 cpanminus 来安装 cpanminus 本身。将可执行文件安装到 Perl 的 bin 路径中。