#Implementation of Random Forest for Machine Learning
#Complete rewrite of the previous algos for greater cutomizationa nd result storage
#31/5/24

library(caret)
library(mlbench)
library(randomForest)
library(parallel)
library(doParallel)
library(dplyr)
library(Metrics)
library(pROC)
setwd("~/Honours/Rstudio")
cl <- makeCluster(4)
registerDoParallel(cl)
stopCluster(cl)

seed <- 81
set.seed(seed)

#Function to Calculate Metrics
metriccalc <- function(pred, ytest, mtry, ntree) {
  length = length(ytest)
  acc = 0
  fp = 0
  tp = 0
  tn = 0
  fn = 0
  for (i in 1:length) {
    realval = testset$Toxicity_Value[i]
    predval = predout[i]
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
  resultlist <- list(mtry = mtry, ntree = ntree, tp = tp, tn = tn, fn = fn, fp = fp, acc = acc)
  return(resultlist)
}

#Data Reading
#df <- read.csv("Datasets/dtargetautoencdata.csv")
df <- dtargetautoencdata
#Sampling for testing
df <- sample_n(df[,0:(ncol(df))], 3000)  
sampleset <- createDataPartition(df$Toxicity_Value, p=0.8, list=FALSE)


#Convert Toxicity_Value into a factor for the algorithm
#Numerical Binary (1,0) values are also altered to Categorical (T, F)
df$Toxicity_Value = as.factor(df$Toxicity_Value) 
df$Toxicity_Value <- ifelse(df$Toxicity_Value == 1, "T", "F")
df$Toxicity_Value = as.factor(df$Toxicity_Value) 

#Creating test and train sets
testset <- df[-sampleset,]
trainset <- df[sampleset,]

xtrain <- trainset[,2:ncol(trainset)]
ytrain <- trainset$Toxicity_Value

xtest <- testset[,2:ncol(testset)]
ytest <- testset$Toxicity_Value
#Metric Dataframe Initialisation
results <- data.frame(mtry = numeric(),
                      ntree = numeric(),
                      tp = numeric(),
                      tn = numeric(),
                      fn = numeric(),
                      fp = numeric(),
                      acc = numeric(),
                      stringsAsFactors = FALSE)
#Parameter setting
candidates = c(1:11)
treecount = c(10, 100, 500, 1000, 2500)
#Model Training

start.time<-proc.time() 
for (candi in candidates) {
  for (treec in treecount) {
    #model = randomForest(x = xtrain, y = ytrain, mtry = mtry, ntree = ntree)
    metric <- "ROC"
    #Control tests for ROC, Sensitivity, Specificity
    control <- trainControl(method="cv", number=10, 
                            summaryFunction=twoClassSummary, 
                            classProbs=TRUE,
                            savePredictions = 'all'
                            ,allowParallel=TRUE
    )
    set.seed(seed)
    #Trains the model on data using parameters set
    tunegrid <- expand.grid(.mtry=candi)
    confusegrid <- train(x = xtrain, y = ytrain, method="rf", 
                         metric=metric, tuneGrid=tunegrid, trControl=control, 
                         ntree=treec)
    #Predict on Test Set
    predout = predict(model, xtest)
    #Calculate Metrics
    resultlist <- metriccalc(predout, ytest, candi, treec)
    results <- rbind(results, resultlist)
  }  
}


stop.time<-proc.time() 
run.time<-stop.time -start.time 
print(run.time) 

#write.csv(results, file = "RFout.csv", row.names = FALSE)
user  system elapsed 
1.905   0.316  20.588 



