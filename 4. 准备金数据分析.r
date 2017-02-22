# ===========================================================   
# 4. 案例分析（准备金数据拟合）
# =========================================================== 
library(data.table)
# 读取数据框格式的数据
  dt = fread("C:/Users/Administrator/Desktop/Israel data.csv")  
# 转化为流量三角形格式
  triangle <- matrix(data = 0, nrow = 18, ncol = 18)
  obs = 0
  for(i in 1:18){
    for(j in 1:(18-i+1)){
      obs <- obs + 1 
      triangle[i,j] <- dt$y[obs]
    }
  }

# ----------------------------------------------------------
# 极大似然估计
# ----------------------------------------------------------
  library(gamlss)
  mGA <- gamlss(y ~ factor(i) + factor(j), data = dt, family = GA(mu.link = 'log'))
# 对准备金数据进行预测
  beta.mle <- coef(mGA)
# 转化为数据框格式的数据
  dtnew <- data.table(i = rep(1:18, each = 18), j = rep(1:18, 18))

# 需要预测的数据格式(包含上三角的观测值，和下三角待预测的部分)
  ynew <- c()
  for(i in 1:18){
    for(j in 1:18){
      obs <- (i-1)*18 + j
      ynew[obs] <- triangle[i,j]
    }
  }
  dtnew$y <- ynew
  Xpred <- model.matrix(~ factor(i) + factor(j), data = dtnew)
  y.mle <- exp(Xpred%*%beta.mle)
  dtnew$y.mle <- y.mle   
# -----------------------------------------------------------
# Bayesian - rstan
# -----------------------------------------------------------
# 设计矩阵
  library(rstan)
  X <- model.matrix(~ factor(i) + factor(j), data = dt)
  Xpred <- model.matrix(~ factor(i) + factor(j), data = dtnew)
  Npred <- dim(Xpred)[1]
  mydat <- list(N = nrow(X),
                K = ncol(X),
                y = dt$y, 
                Xpred = Xpred,
                Npred = Npred
  )

  glmod <- "
  data{
    int N;
    int K;
    int Npred;
    matrix[N,K] X;   
    matrix[Npred,K] Xpred;
    vector[N] y;
  }
  parameters{
    vector[K] beta; 
    real<lower = 0> sigma2;
  }
  transformed parameters {
    vector[N] mu; 
    vector[N] loglike;
    real<lower = 0> sigma;
    mu = exp(X * beta); 
    sigma = sigma2^0.5;
    for (i in 1:N){
      loglike[i] = gamma_lpdf(y[i]|1/sigma2, 1/(mu[i]*sigma2));   // loglikelihood function
    }    
  }
  model{  
    target += normal_lpdf(beta|0, 100);
    target += cauchy_lpdf(sigma2|0, 5);
    target += loglike;
  }
  generated quantities {
    vector[N] PointPosteriors;
    vector[Npred] ypred;
    vector[Npred] mupred;
    mupred = exp(Xpred*beta);
    for (i in 1:N) {
      PointPosteriors[i] = exp(gamma_lpdf(y[i]|1/sigma2, 1/(mu[i]*sigma2)));
    }
    for (i in 1:Npred){
      ypred[i] = gamma_rng(1/sigma2, 1/(mupred[i]*sigma2));
    }
  }
  "
  sfit <- stan(model_code = glmod, data = mydat,
               pars = c('beta', 'sigma','sigma2', 'lp__', 'PointPosteriors', 'ypred'),
               iter = 10000, warmup = 5000, thin = 5, chains = 4)

# 输出参数估计值
  print(sfit, pars = c('beta', 'sigma', 'lp__'),
        probs = c(0.05, 0.5, 0.95))
#输出回归系数的样本路径图
  traceplot(sfit, pars = c('beta', 'sigma'), inc_warmup = FALSE)  # 轨迹图
  stan_ac(sfit, pars = c('beta', 'sigma'), inc_warmup = FALSE)    # 自相关图
  stan_hist(sfit, pars = c('sigma2', 'sigma'), inc_warmup = FALSE)  # 后验分布直方图

# ------------------------------------------------------------------  
# 计算 WAIC（类似AIC统计量，评价模型的拟合优度）
# ------------------------------------------------------------------
  WAIC <- function(pointMatrix) {
    lppd <- sum(log(apply(pointMatrix, 2, FUN = mean)))
    pWAIC2 <- sum(apply(log(pointMatrix), 2, FUN = var))
    return(c(-2 * (lppd - pWAIC2), lppd, pWAIC2))
  }
  PP <- extract(sfit, pars = 'PointPosteriors')$PointPosteriors
  WAIC(PP)
# -----------------------------------------------------------------
# 第一种方法：预测（利用 generated quantities 里面的函数）
# -----------------------------------------------------------------
  y_rep <- yextract(sfit, pars = 'ypred')$ypred
# -----------------------------------------------------------------
# 第二种方法：预测（不需要写 generated quantities 里面的函数）
# 直接提取 HMC 抽样样本
# -----------------------------------------------------------------
  set.seed(1123)
  beta.mcmc <- extract(sfit, pars = 'beta')$beta
  sigma.mcmc <- extract(sfit, pars = 'sigma')$sigma
  n_sims <- length(sigma.mcmc)
  y_rep <- matrix(NA, nrow = nrow(dtnew), ncol = n_sims)
  for (s in 1:n_sims){
    sigma <- sigma.mcmc[s]
    beta <- beta.mcmc[s,]
    mu <- exp(Xpred%*%(beta))
    y_rep[, s] <- rGA(1, mu = mu, sigma = sigma)
  }

# 以样本的均值作为预测值
  y.bayes <- apply(y_rep, 1, mean)
  dtnew$y.bayes <- y.bayes
# ==========================================================
# 未赔款准备金的预测分布(未决赔款准备金 = 下三角预测值之和)
# ==========================================================
