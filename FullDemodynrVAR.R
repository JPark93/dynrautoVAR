library(dynr); library(qgraph)
library(igraph); library(fclust)
source('./weVAR.R')
source('./dynr.sub.R')
# Sample Characteristics
  nv = 5; times = 300; N = 8  
  set.seed(312489)
  # Variables, times, sample size
# Params for Group 1
  beta1 = matrix(c(0.62, 0.00, 0.00, 0.00, 0.00,
                   0.00, 0.53, 0.00, 0.00, 0.00,
                   0.00, 0.00, 0.61, 0.00, 0.00,
                   0.00, 0.00, 0.00, 0.52,-0.22,
                   0.32,-0.16, 0.00, 0.00, 0.52), nv, nv, byrow = TRUE)
  
  psi1 = matrix(c(0.83,0.00,0.00,-0.40,0.40,
                  0.00,0.99,0.00,0.00,0.00,
                  0.00,0.00,0.88,0.00,0.00,
                  -0.40,0.00,0.00,1.01,0.00,
                  0.40,0.00,0.00,0.00,0.91), nv, nv, byrow = TRUE)
# Params for Group 2
  beta2 = matrix(c(0.62,0.00, 0.00, 0.00,0.00,
                   0.00,0.53, 0.00, 0.00,0.00,
                   0.00,0.00, 0.61, 0.00,0.00,
                   0.00,0.00, 0.30, 0.52,0.00,
                   0.00,-0.16, 0.00, -0.35,0.52), nv, nv, byrow = TRUE)
  
  psi2 = matrix(c(0.83,0.00,0.00,0.00,0.00,
                  0.00,0.99,0.40,0.00,0.00,
                  0.00,0.40,0.88,0.40,0.00,
                  0.00,0.00,0.40,1.01,0.00,
                  0.00,0.00,0.00,0.00,0.91), nv, nv, byrow = TRUE)
# Data Generation
  # N/2 in Subgroup 1
  # N/2 in Subgroup 2
  true.dat = NULL
  for(j in 1:N){
    dat2fit = matrix(NA, times, nv)
    dat2fit[1,] = rnorm(nv)
    if(j <= N/2){
      beta = beta1; kap = psi1
    }else{beta = beta2; kap = psi2}
    for(i in 2:times){
      dat2fit[i,] = beta %*% dat2fit[i-1,] + 
      MASS::mvrnorm(1, mu = rep(0, 5), Sigma = kap)
    } 
    true.dat = rbind(true.dat, dat2fit)
  }

# Adding 2 Fuzzy Subjects
  for(i in 1:2){
    dat2fit = matrix(NA, times, nv)
    dat2fit[1,] = rnorm(nv)
    fuzz = rbinom(times, 1, prob = 0.5)
      for(i in 2:times){
        if(fuzz[i] == 1){
          beta = beta1; kap = psi1
        }else{beta = beta2; kap = psi2}
        dat2fit[i,] = beta %*% dat2fit[i-1,] + 
        MASS::mvrnorm(1, mu = rep(0, 5), Sigma = kap)
      }
    true.dat = rbind(true.dat, dat2fit)
  }
# Adding Labels
  true.dat = data.frame(true.dat)
  true.dat$id = rep(1:(N+2), each = times)
  true.dat$time = rep(1:times, (N+2))

# Fitting Auto-VAR
# COMMENTED OUT TO SAVE YOU TIME
# create
# func.test = weVAR(data = true.dat, varnames = paste0('X', 1:5),
#                      id = 'id', time = 'time', dir = '~/Desktop/test/',
#                      MLVAR = FALSE)
# INSTEAD USE LINE BELOW TO READ IN OUTPUT
func.test = readRDS('./functest.RDS')
# Plotting Output of 2 subjects from each subgroup:
  par(mfrow = c(2,2))
  for(pyj in c(3:6)){ # 3 and 4 are Subgroup 1; 5 and 6 are Subgroup 2
    qgraph::qgraphMixed(func.test[[1]][[pyj]]$PCC, func.test[[1]][[pyj]]$PDC, 
                        layout = 'circle', theme = 'gimme', 
                        ltyUndirected = 1, ltyDirected = 2)  
  }
# Clustering on dynr.var function output
  # Clustering using WalkTrap (Hard Clustering); Using info from PCC and PDC Matrices
  dynr.sub(input = func.test, method = 'hard', params.var = 'Both')
  # Clustering using Fuzzy k-means (Fuzzy Clustering); Using info from PCC and PDC
    # k = 2 for number of clusters desired and m = 2 for value of fuzzifier
      dynr.sub(input = func.test, params.var = 'Both',
               method = 'fuzz', k = 2, m = 2)
# Clustering based on list of dynr.cook objects
  # Creating a list of dynr.cook objects from our outputted weVAR output
    res.list = list()
    for(i in 1:length(func.test[[1]])){
      res.list[[i]] = func.test[[1]][[i]]$Res
    }
  # Clustering based on specific parameters from dynr.cook objects
    dynr.sub(input = res.list, alpha = 0.05, 
             params.cook = c('a_5', 'c_4', 'd_5','e_4'), 
             method = 'fuzz', k = 2)
#   # Avgnet Function  
#     avgnet = function(dynrVAR.out = NULL, params = c('Betas', 'Resid','PDC', 'PCC')){
#       avgnets = list()
#       temp.avg = NULL
#       averagenet = NULL
#       for(j in params){
#         for(i in 1:length(dynrVAR.out[[1]])){
#           thenets = c(dynrVAR.out[[1]][[i]][[j]])
#           temp.avg = rbind(temp.avg, thenets)
#           sdnet = matrix(apply(temp.avg, 2, sd), length(varnames), length(varnames), byrow = TRUE)
#           averagenet = matrix(colMeans(temp.avg), length(varnames), length(varnames), byrow = TRUE)
#         }
#         avgnets[[j]] = list('Average Network' = averagenet, 'SD Network' = sdnet)
#       }
#     }
# 
# sdnet    
    
  
    
