#30/5/24 SVM Testing & implementation via svm

library(caret)
library(mlbench)
library(randomForest)
library(parallel)
library(doParallel)
library(dplyr)
library(Metrics)
library(pROC)
library(kernlab)
setwd("~/Documents/Honours/R/Algo_Testing/SVM")
#cl <- makePSOCKcluster(4)
#registerDoParallel(cl)
#stopCluster(cl)

#function to calculate metrics
vanilpredmetrics <- function(testset, p, type, kernel, cost) {
  length = length(ytest)
  acc = 0
  fp = 0
  tp = 0
  tn = 0
  fn = 0
  
  for (i in 1:length) {
    realval = as.factor(testset$Toxicity_Value[i])
    predval = p[i]
    
    if (realval == TRUE) {
      if (predval == realval) {
        acc = acc + 1
        tp = tp + 1
      } 
      else {
        fp = fp + 1
      }
    }
    else {
      if (predval == realval) {
        acc = acc + 1
        tn = tn + 1
      } 
      else {
        fn = fn + 1
      }
    }
  }
  acc = acc / nrow(testset)
  f1 = (2 * tp) / ((2 * tp) + fp + fn)
  mcc = 0
  
  temp = sqrt((fp + tn) * (tp + fp) * (tp + fn) * (tn + fn))
  if (temp != 0) {
    mcc = ((tp * tn) - (fp * fn)) / temp
  }
  
  kapp = 0
  temp = (( ( (tp + fp) * (fp + tn) ) + ( (tp + fn) * (fn + tn) ) ))
  if (temp != 0) {
    kapp =  ( 2 * ((tp * tn) - (fn * fp)) ) / temp
  }
  
  
  
  resultlist <- list(type = type, kernel = kernel, cost = cost,
                     tp = tp, tn = tn, fn = fn, fp = fp, acc = acc,
                     mcc = mcc, f1 = f1, kappa = kapp)
  return(resultlist)
}

df <- read.csv("~/Documents/Honours/Data/Targetdata/autoencdata/dtargetautoencdata.csv")

seed <- 81
set.seed(seed)

#Sampling for testing
df <- sample_n(df[,0:(ncol(df))], 2000)  
sampleset <- createDataPartition(df$Toxicity_Value, p=0.8, list=FALSE)


#Convert Toxicity_Value into a factor for the algorithm
#Numerical Binary (1,0) values are also altered to Categorical (T, F)
df$Toxicity_Value = as.factor(df$Toxicity_Value) 
df$Toxicity_Value <- ifelse(df$Toxicity_Value == 1, "T", "F")

#Creating test and train sets
testset <- df[-sampleset,]
trainset <- df[sampleset,]

x <- trainset#[,2:ncol(trainset)]
y <- trainset$Toxicity_Value
xtrain <- x[,3:ncol(x)]
xtest <- testset[,3:ncol(testset)]
ytest <- as.factor(testset$Toxicity_Value)

#First for Kernels that do not have unique hyperparameters
#Creating dataframe to store results
#Tracks hyperparameters (cost, type) and confusion matrix variables
noparamresults <- data.frame(type = character(),
                        kernel = character(),
                        cost = numeric(),
                        tp = numeric(),
                        tn = numeric(),
                        fn = numeric(),
                        fp = numeric(),
                        acc = numeric(),
                        mcc = numeric(),
                        f1 = numeric(),
                        kappa = numeric(),
                        stringsAsFactors = FALSE)

#Setting Hyperparameters
types <- c('C-svc', 'nu-svc', 'C-bsvc', 'spoc-svc', 
           'kbb-svc', 'one-svc')
kernels <- c('vanilladot', 'laplacedot', 'rbfdot')
costs <- c(0.01, 0.1, 1, 100, 1000)
vals <- c()

#Training loop
testset$Toxicity_Value = sapply(testset$Toxicity_Value, as.logical)
y = sapply(y, as.logical)

for (type in types){
  for (kernel in kernels){
    for (cost in costs){
      m = ksvm(x = as.matrix(xtrain), y = as.factor(y), 
               kernel = kernel, type = type, C = cost)
      p = predict(m, xtest)
      resultlist <- vanilpredmetrics(testset, p, type, kernel, cost)
      noparamresults <- rbind(noparamresults, resultlist)
    }
  }
}

#For the polydot kernel (polynomial)

degrees = c(1:5)


testset$Toxicity_Value = sapply(testset$Toxicity_Value, as.logical)
y = sapply(y, as.logical)

for (type in types){
  for (kernel in kernels){
    for (cost in costs){
      m = ksvm(x = as.matrix(xtrain), y = as.factor(y), 
               kernel = kernel, type = type, C = cost)
      p = predict(m, xtest)
      resultlist <- vanilpredmetrics(testset, p, type, kernel, cost)
      noparamresults <- rbind(noparamresults, resultlist)
    }
  }
}

#For the Tanhdot kernel (hyperbolic tangent)

#For the besseldot kernel (bessel)

#For the anovadot kernel (ANOVA RBF)

#For the stringdot kernel (String)
