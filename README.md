# Rstan在贝叶斯分析中的运用
0. Rstan的安装
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

或者可以尝试下述代码

```R
# note: replace the '4' with the number of cores you want to devote to the build
Sys.setenv(MAKEFLAGS = "-j4") 
install.packages("rstan", type = "source")
```

1. 基本分布拟合(Fitting distribution)
----------------------------
2. 线性回归模型(Linear regression model)
---------------------------
3. 广义线性模型(Generalized linear model)
---------------------------
4. 案例分析（准备金数据分析）
-------



