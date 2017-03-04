# ===========================================================   
# 4. 案例分析（准备金数据拟合）
# year: 事故年
# ay: 事故年（简化）
# lag: 进展年
# cum: 累积赔款
# incre: 增量赔款
# premium：已收保费
# =========================================================== 
# 读取数据框格式的数据
  library(data.table)
  library(gamlss)
# 用于预测的数据
  dtnew = fread("F:\\Files\\学术研究\\工作任务\\贝叶斯回归模型（书稿+代码）//triangle data(数据框格式).csv")  
  Xpred <- model.matrix(~ factor(ay) + factor(lag), data = dtnew)  # 设计矩阵
# 用于建模的数据  
  dt <- dtnew[incre>0]
  X <- model.matrix(~ factor(ay) + factor(lag), data = dt)  # 设计矩阵

# ===========================================================
# 1. Poisson×(泊松回归模型)
# ===========================================================
  m.po <- glm(incre ~ factor(ay) + factor(lag) + offset(log(premium)), data = dt, family = poisson)
# 对准备金数据进行预测
  pred.po <- exp(Xpred%*%coef(m.po))*dtnew$premium
  dtnew$pred.po =  pred.po
  summary(m.po)
  
# ===========================================================
# 2. Bayesian + rtan(泊松回归模型)
# ===========================================================
# 设计矩阵
  library(rstan)
  mydat <- list(N = nrow(X),
                K = ncol(X),
                y = dt$incre,
                premium = dt$premium
  )

  glmod <- "
  data{
    int N;
    int K;
    matrix[N,K] X;   
    int y[N];
    vector[N] premium;
  }
  parameters{
    vector[K] beta; 
  }
  transformed parameters {
    vector[N] mu; 
    vector[N] loglike;
    mu = exp(X * beta + log(premium)); 
    for (i in 1:N){
      loglike[i] = poisson_lpmf(y[i]|mu[i]);
    }    
  }
  model{  
    target += normal_lpdf(beta|0, 100);
    target += loglike;
  }
  "
  sfit <- stan(model_code = glmod, data = mydat,
               pars = c('beta', 'lp__'),
               iter = 10000, warmup = 5000, thin = 5, chains = 4)

# 输出参数估计值
  print(sfit, pars = c('beta', 'lp__'),
        probs = c(0.05, 0.5, 0.95))
# 输出回归系数的样本路径图
  traceplot(sfit, pars = c('beta'), inc_warmup = FALSE)  # 轨迹图
  stan_ac(sfit, pars = c('beta'), inc_warmup = FALSE)    # 自相关图
  stan_hist(sfit, pars = c('beta'), inc_warmup = FALSE)  # 后验分布直方图

# -----------------------------------------------------------------
# 提取 HMC 抽样样本
# 预测上三角和下三角的数据
# -----------------------------------------------------------------
  set.seed(1123)
  beta.mcmc <- extract(sfit, pars = 'beta')$beta
  n_sims <- nrow(beta.mcmc)
  y_rep <- matrix(NA, nrow = nrow(dtnew), ncol = n_sims)
  for (s in 1:n_sims){
    beta <- beta.mcmc[s,]
    mu <- exp(Xpred%*%(beta) + log(dtnew$premium))
    y_rep[, s] <- rPO(nrow(dtnew), mu = mu)
  }
# 以样本的均值作为预测值
  pred.bayes <- apply(y_rep, 1, mean)
  dtnew$pred.bayes <- pred.bayes

# 比较链梯法和Bayesian的结果
  plot(pred.po, pred.bayes, xlab = '链梯法', ylab = '贝叶斯方法')
  abline(a = 0, b = 1)

# -----------------------------------------------------------------------------------
# 预测分布
# -----------------------------------------------------------------------------
  ind.lower <- (dtnew$ay + dtnew$lag >10)   # 提取下三角
  res.mcmc <- apply(y_rep[ind.lower,], 2, sum)
  hist(res.mcmc, xlab = '未决赔款准备金', ylab = '频数', main = '')   # 未决赔款准备金的预测分布（下三角之和）
  