# [dotfiles/r/build.sh](https://github.com/wang-q/dotfiles/blob/master/r/build.sh)

```bash
#!/bin/bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# ${BASH_SOURCE[0]}，返回当前运行脚本名称

# source URI
sudo cp /etc/apt/sources.list /etc/apt/sources.list~
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

sudo apt -y update

# This command will install texlive
# sudo apt -y build-dep r-base

sudo apt -y install build-essential
sudo apt -y install gfortran
# gfortran：a compiler for the Fortran programming language that is used by some R packages for numerical computations.

# sudo apt install apt-rdepends
# apt-rdepends --build-depends --print-state --follow=DEPENDS r-base

sudo apt -y install groff-base libxml2-dev gettext
sudo apt -y install libblas-dev liblapack-dev
sudo apt -y install libcurl4-openssl-dev libncurses5-dev libreadline-dev
sudo apt -y install libcairo2-dev libjpeg-dev libpango1.0-dev libpng-dev libtiff5-dev
sudo apt -y install libbz2-dev liblzma-dev zlib1g-dev
# groff-base
# libxml2-dev：a library for parsing and manipulating XML documents that is used by some R packages.
# gettext
# libblas-dev：a library that provide Basic Linear Algebra Subprograms (BLAS) that is used by many R packages for numerical computations.
# liblapack-dev：a library that provided Linear Algebra Package (LAPACK) routines that is used by many R packages for numerical computations.
# libcurl4-openssl-dev：a library for transferring data with URLs that supports various protocols, including HTTP, FTP, and SMTP. It is used by some R packages to download data from the internet.
# libncurses5-dev
# libreadline-dev
# libcairo2-dev
# libjpeg-dev
# libpango1.0-dev
# libpng-dev
# libtiff5-dev
# libbz2-dev
# liblzma-dev
# zlib1g-dev

# make：控制从程序的源文件生成程序的可执行文件和其他非源文件的工具。

# BLAS (Basic Linear Algebra Subroutines) is a set of efficient routines for most of the basic vector and matrix operations. They are widely used as the basis for other high quality linear algebra software, for example lapack and linpack.



sudo apt -y install ghostscript libfreetype-dev fontconfig

# udunit2, gdal
sudo apt -y install cmake
sudo apt -y install udunits-bin libudunits2-dev
sudo apt -y install gdal-bin libgdal-dev

mkdir -p $HOME/share/R

cd
curl -L https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/base/R-4/R-4.2.1.tar.gz |
    tar xvz
cd R-4.2.1
## 替换R源文件版本，安装不同版本的R

# brewed binaries confuse configure
hash brew 2>/dev/null && {
    brew unlink pkg-config
}

CC=gcc CXX=g++ FC=gfortran ./configure \
    --prefix="$HOME/share/R" \
    --enable-memory-profiling \
    --disable-java \
    --with-pcre1 \
    --with-blas \
    --with-lapack \
    --without-x \
    --without-tcltk \
    --without-ICU \
    --with-cairo \
    --with-libpng \
    --with-jpeglib \
    --with-libtiff \
    --with-gnu-ld
# PCRE - Perl Compatible Regular Expressions

CC 表示 C Compiler；

make -j 8
make check

bin/Rscript -e '
    capabilities();
    png("test.png");
    plot(rnorm(4000),rnorm(4000),col="#ff000018",pch=19,cex=2);
    dev.off();
    '

make install

cd
rm -fr ~/R-4.2.3

if grep -q -i R_42_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains R_42_PATH"
else
    echo "==> Updating .bashrc with R_42_PATH..."
    R_42_PATH="export PATH=\"$HOME/share/R/bin:\$PATH\""
    echo '# R_42_PATH' >> $HOME/.bashrc
    echo $R_42_PATH    >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source ~/.bashrc
```

compile 编译
build 构建


* make [options] [target]
    * -f FILE/--file=FILE/--makefile=FILE：Read FILE as a makefile(指定构建文件的规则).
    * -j [N]/--jobs[=N]：Allow N jobs at once; infinite jobs with no arg(指定并行执行文件数).

* 部分参考：
    * [make](https://www.gnu.org/software/make/)
    * [GNU Make 手册](https://www.gnu.org/software/make/manual/make.html)