# ===========================================================
# 1. 基本分布拟合(fit distribution)
# ===========================================================
# 伽马分布模拟
  set.seed(111)
  N <- 100
  y <- rgamma(N, shape = 30, rate = 2)
  mydat <- list(y=y, N=N)

# 拟合伽马分布 - fitdist
  library(fitdistrplus)
  fit.GA2 <- fitdist(data = y, distr = 'gamma')
  summary(fit.GA2) 

# 拟合伽马分布 - Bayesian
  library(rstan)
  model.GA <-'
    data{
    int<lower=0> N;
    real y[N];
  }
  parameters{
    real<lower=0> alpha;
    real<lower=0> beta; 
  }
  model{
    target += gamma_lpdf(y|alpha, beta); 
  }
  '
# 模型拟合
  fit.GA <- stan(model_code = model.GA, data = mydat, 
                 iter = 10000, warmup = 2000, thin = 10,
                 chains = 4)
  print(fit.GA, pars=c('alpha','beta','lp__'), digits_summary = 3, probs=c(0.025,0.5,0.975))
# 模型诊断  
  traceplot(fit.GA, pars = c('alpha','beta'), inc_warmup = FALSE)  # 轨迹图
  stan_ac(fit.GA, pars = c('alpha','beta'), inc_warmup = FALSE)    # 自相关图