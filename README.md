# Rstan 在贝叶斯分析中的运用

## [Rstan 主页](http://mc-stan.org/interfaces/rstan)

主要包括 stan 的下载、安装、使用手册以及相应的例子

## Rstan 安装
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

# Rstan 在贝叶斯分析中的运用


## Rstan 应用
### [1. 基本分布的拟合(R code)](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/1.%20%E5%9F%BA%E6%9C%AC%E5%88%86%E5%B8%83%E6%8B%9F%E5%90%88.r)
* 假设伽马分布的均值为15，形状参数（shape）和比率参数（rate）分别为 30 和 2。请模拟 1000 个服从该伽马分布的随机数
* 基于这组随机数应用 Rstan 估计伽马分布的两个参数

### [2. 线性回归模型(R code)](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/2.%20%E7%BA%BF%E6%80%A7%E5%9B%9E%E5%BD%92%E6%A8%A1%E5%9E%8B(LM).r)
* 假设 y 服从正态分布，标准差为 2，均值可以表示为三个协变量的线性函数，即 μ=10+0.2*x1-0.3*x2+0.4*x3
* 三个协变量都服从标准正态分布
* 模拟 1000 个因变量和协变量的观察值
* 基于这组模拟数据应用 Rstan 建立线性回归模型。

### [3. 广义线性模型(R code)](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/3.%20%E5%B9%BF%E4%B9%89%E7%BA%BF%E6%80%A7%E6%A8%A1%E5%9E%8B(GLM).r)
* 假设因变量 y 服从伽马分布，均值可以表示为三个协变量的线性函数，即 μ=5+1.2*x1+1.3*x2+1.4*x3
* 三个协变量都服从均值为 0.1 的指数分布
* 请模拟 1000 个因变量和协变量的观察值
* 基于这组模拟数据应用Rstan建立回归模型。

### [4. 准备金数据分析(R code)](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/4.%20%E5%87%86%E5%A4%87%E9%87%91%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90.r)
本数据是国外一家保险公司私家车业务线的流量三角形数据。该数据给出了55个上三角的已付增量赔款以及各个事故年的已收保费，其中数据分为

* [流量三角形格式](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/triangle%20data(%E6%B5%81%E9%87%8F%E4%B8%89%E8%A7%92%E5%BD%A2%E6%A0%BC%E5%BC%8F).csv)
* [数据框格式](https://github.com/lzx89757/Introduction-to-Rstan/blob/master/triangle%20data(%E6%95%B0%E6%8D%AE%E6%A1%86%E6%A0%BC%E5%BC%8F).csv) 

在未决赔款准备金评估的传统方法中，链锑法是最主要的评估方法之一，对准备金的预测结果与（过离散）泊松回归模型是等价的

* 下面应用 Rstan 建立对该数据建立回归模型，并预测下三角的增量赔款，同时给出未决赔款准备金的预测均值和预测分布
* 将预测结果与链锑法相比较

完结


