# Rstan 在贝叶斯分析中的运用
## [Rstan 主页](http://mc-stan.org/interfaces/rstan)
## Rstan 安装
--------------------------------
- 下载安装与 R 版本相对应的的 [Rtools](http://cran.r-project.org/bin/windows/Rtools/)。安装过程注意下图中的选项
![editpathrtools](https://raw.github.com/wiki/stan-dev/rstan/editpathrtools.png)
* 退出当前的 R，然后重新启动 R
* 在 R 中输入命令 `Sys.getenv("PATH")` 并检查 Rtools 是否安装在指定的路径。如果 Rtools 安装在 `c:\\Rtools` ，那么你会看到下面的代码和显示
```text
> Sys.getenv('PATH')
[1] "c:\\\\Rtools\\\\bin;c:\\\\Rtools\\\\gcc-4.6.3\\\\bin;...
``` 
* 检查 `g++` 能否被 R 读取. 例如：
```
> system('g++ -v')
Using built-in specs.
COLLECT_GCC=c:\Rtools\GCC-46~1.3\bin\G__~1.EXE
COLLECT_LTO_WRAPPER=c:/rtools/gcc-46~1.3/bin/../libexec/gcc/i686-w64-mingw32/4.6.3/lto-wrapper.exe
Target: i686-w64-mingw32
Configured with: /data/gannet/ripley/Sources/mingw-test3/src/gcc/configure --host=i686-w64-mingw32 --build=x86_64-linux-gnu --target=i686-w64-mingw32 --with-sysroot=/data/gannet/ripley/Sources/mingw-test3/mingw32mingw32/mingw32 --prefix=/data/gannet/ripley/Sources/mingw-test3/mingw32mingw32/mingw32 --with-gmp=/data/gannet/ripley/Sources/mingw-test3/mingw32mingw32/prereq_install --with-mpfr=/data/gannet/ripley/Sources/mingw-test3/mingw32mingw32/prereq_install --with-mpc=/data/gannet/ripley/Sources/mingw-test3/mingw32mingw32/prereq_install --disable-shared --enable-static --enable-targets=all --enable-languages=c,c++,fortran --enable-libgomp --enable-sjlj-exceptions --enable-fully-dynamic-string --disable-nls --disable-werror --enable-checking=release --disable-win32-registry --disable-rpath --disable-werror CFLAGS='-O2 -mtune=core2 -fomit-frame-pointer' LDFLAGS=
Thread model: win32
gcc version 4.6.3 20111208 (prerelease) (GCC)

> system('where make')
c:\Rtools\bin\make.exe
```
* 安装 Rstan 包
```R
# note: omit the 's' in 'https' if you cannot handle https downloads
install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies=TRUE)
```

* 或者可以尝试下述代码

```R
# note: replace the '4' with the number of cores you want to devote to the build
Sys.setenv(MAKEFLAGS = "-j4") 
install.packages("rstan", type = "source")
```

## Rstan 应用
----------------------------
* 基本分布的拟合-[伽马分布](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/1.%20%E5%9F%BA%E6%9C%AC%E5%88%86%E5%B8%83%E6%8B%9F%E5%90%88.r)
* 线性回归模型(Linear regression model)-[多元回归模型](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/2.%20%E7%BA%BF%E6%80%A7%E5%9B%9E%E5%BD%92%E6%A8%A1%E5%9E%8B(LM).r)
* 广义线性模型(Generalized linear model)-[伽马回归模型](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/3.%20%E5%B9%BF%E4%B9%89%E7%BA%BF%E6%80%A7%E6%A8%A1%E5%9E%8B(GLM).r)
* 准备金数据分析-[流量三角形拟合](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/4.%20%E5%87%86%E5%A4%87%E9%87%91%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90.r)

### [数据（流量三角形格式）](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/triangle%20data(%E6%B5%81%E9%87%8F%E4%B8%89%E8%A7%92%E5%BD%A2%E6%A0%BC%E5%BC%8F).csv)

### [数据（数据框格式）](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/triangle%20data(%E6%95%B0%E6%8D%AE%E6%A1%86%E6%A0%BC%E5%BC%8F).csv)

### 数据说明
本数据是国外一家保险公司私家车业务线的流量三角形数据。该数据给出了55个上三角的已付增量赔款以及各个事故年的已收保费。
