# ===========================================================   
# 3. 广义线性模型(GLM)
# =========================================================== 
# 假设因变量y服从伽马分布
# 均值可以表示为三个协变量的线性函数
# 即μ=5+1.2*x1+1.3*x2+1.4*x3
# 其中三个协变量都服从均值为0.1的指数分布
# 请模1000个因变量和协变量的观察值，并基于这组模拟数据应用Rstan建立回归模型。
# 模拟数据

  set.seed(111)
  N <- 1000  #样本量
# 生成协变量
  covariates <- replicate(3, rexp(n = N, rate = 10))  
  colnames(covariates) <- c('x1','x2','x3')
# 设计矩阵
  X <- cbind(Intercept = 1, covariates)
  coefs <- c(5, 1.2, 1.3, 1.4)    # 回归系数的真实值
  mu <- exp(X %*% coefs)         # 因变量的均值（真实值）
  sigma <- 0.2                   # 伽马分布的离散参数
# 模拟因变量的观察值，服从伽马分布
  library(gamlss)
  y <- rGA(N, mu = mu, sigma = sigma)  
  dt <- data.frame(y, X)  # 模拟的数据集
# 为了便于比较，下面首先应用glm()函数给出参数的极大似然估计值，有关程序代码和输出结果如下。
# 应用glm函数建立广义线性模型glmfit
  glmfit <- glm(y ~ x1 + x2 + x3, family = Gamma(link = "log"),data = dt)
  summary(glmfit)                # 输出参数估计值
  
# 下面应用rstan估计模型的参数。首先把数据封装在mydat中，并把相应的贝叶斯模型记为glmod。
  mydat <- list(N = N, K = ncol(X), y = y, X = X)
  
  glmod <- "
  data{
    int N;
    int K;
    matrix[N,K] X;   
    vector[N] y;
  }
  parameters{
    vector[K] beta; 
    real<lower=0> sigma2;
  }
  transformed parameters {
    vector[N] mu; 
    vector[N] loglike;
    real sigma;
    mu = exp(X * beta); 
    sigma = sigma2^0.5;
    for (i in 1:N){
      loglike[i] = gamma_lpdf(y[i]|1/sigma2, 1/(mu[i]*sigma2)); // loglikelihood function
    }    
  }
  model{  
    target += normal_lpdf(beta|0, 100);
    target += cauchy_lpdf(sigma2|0, 5);
    target += loglike;
  }
  "

  sfit <- stan(model_code = glmod, data = mydat,
               pars = c('beta', 'sigma', 'lp__'),
               iter = 1000, warmup = 200, thin = 2, chains = 4)
# 输出参数估计值
  print(sfit, pars = c('beta', 'sigma', 'lp__'),
        probs = c(0.05, 0.5, 0.95))
# 输出回归系数的样本路径图
  traceplot(sfit, pars = c('beta', 'sigma'), inc_warmup = FALSE)  # 轨迹图
  stan_ac(sfit, pars = c('beta', 'sigma'), inc_warmup = FALSE)    # 自相关图