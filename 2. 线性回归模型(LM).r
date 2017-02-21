# ===========================================================  
# 2. 线性回归模型(LM)
# ===========================================================  
# 【例8 4】 
# 假设y服从正态分布，标准差为2
# 均值可以表示为三个协变量的线性函数
# 即μ=10+0.2*x1-0.3*x2+0.4*x3
# 其中三个协变量都服从标准正态分布
# 请模1000个因变量和协变量的观察值
# 并基于这组模拟数据应用Rstan建立线性回归模型
# -----------------------------------------------------------
# 模拟数据
  set.seed(111)
  N <- 1000  #样本量
# 生成协变量
  covariates <- replicate(3, rnorm(n = N))  
  colnames(covariates) <- c('x1', 'x2', 'x3')
# 设计矩阵
  X <- cbind(Intercept = 1, covariates)
  coefs <- c(10, 0.2, -0.3, 0.4)  #回归系数的真实值
  mu <- X %*% coefs #因变量的均值（真实值）
  sigma <- 2  #因变量的标准差
  y <- rnorm(N, mu, sigma)  
  dt <- data.frame(y, X)  #模拟的数据集
  fit <- lm(y ~ x1 + x2 + x3, data = dt)
  summary(fit)

# rstan 拟合 - vector形式
  mydat <- list(N = N, K = ncol(X), y = y, X = X)  #用list封装数据
  lmod <-"
  data{
    int N;
    int K;
    matrix[N,K] X;
    vector[N] y;
  }
  
  parameters{
    vector[K] beta; 
    real<lower = 0> sigma;
  }
  
  model{
    vector[N] mu;
    mu = X * beta;   
    target += normal_lpdf(beta|0, 100);
    target += cauchy_lpdf(sigma|0, 5);
    target += normal_lpdf(y|mu, sigma);
  }
  "
  sfit <- stan(model_code = lmod, 
               data = mydat, 
               iter = 2000, warmup = 200, thin = 2, chains = 4)
  
  print(sfit, probs = c(0.05, 0.5, 0.95))
  #输出回归系数的样本路径图
  traceplot(sfit, pars = c('beta', 'sigma'), inc_warmup = FALSE)  # 轨迹图
  stan_ac(sfit, pars = c('beta', 'sigma'), inc_warmup = FALSE)    # 自相关图