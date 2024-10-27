#30/5/24 SVM Testing & implementation via LibLineaR

library(caret)
library(mlbench)
library(randomForest)
library(parallel)
library(doParallel)
library(dplyr)
library(Metrics)
library(pROC)
library(LiblineaR)
setwd("~/Documents/Honours/R/Algo_Testing/SVM")
#cl <- makePSOCKcluster(4)
#registerDoParallel(cl)
#stopCluster(cl)

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

#Creating dataframe to store results
#Tracks hyperparameters (cost, type) and confusion matrix variables
results <- data.frame(type = numeric(),
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
types <- c(0:7)
costs <- c(0.01, 0.1, 1, 100, 1000)
vals <- c()

#function to calculate metrics
predmetrics <- function(ytest, testset, p, curtype, curcost) {
  length = length(ytest)
  acc = 0
  fp = 0
  tp = 0
  tn = 0
  fn = 0
  
  for (i in 1:length) {
    realval = testset$Toxicity_Value[i]
    predval = p$predictions[i]
    
    if (realval == "T") {
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
  
  
  
  resultlist <- list(type = curtype, cost = curcost, tp = tp, tn = tn, 
                     fn = fn, fp = fp, acc = acc, mcc = mcc, f1 = f1, kappa = kapp)
  return(resultlist)
}

#Training loop
for(type in types){
  for (cost in costs){
    m=LiblineaR(data=xtrain,target=y,type=type,cost=cost,bias=1,verbose=FALSE)
    p=predict(m,xtrain)
    
    resultlist <- predmetrics(y, trainset, p, type, cost)
    results <- rbind(results, resultlist)
    }
}

