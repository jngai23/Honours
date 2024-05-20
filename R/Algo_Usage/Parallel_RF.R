#Implementation of Random Forest for Machine Learning
#For use with Toxric Datasets using processed data
#22/4/24

library(caret)
library(mlbench)
library(randomForest)
library(parallel)
library(doParallel)
library(dplyr)
library(Metrics)
library(pROC)
setwd("~/Documents/Honours/R/Algo_Usage")
cl <- makePSOCKcluster(4)
registerDoParallel(cl)
stopCluster(cl)

seed <- 81
set.seed(seed)

#Data Reading, make sure to change for each set
#df <- read_csv("datasets/UMAPdata.csv")
df <- dtargetUMAPdata
#Sampling for testing
df <- sample_n(df[,3:(ncol(df))], 1000)  
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

#Parameter setting
#test mtry = 5, 10, 50, 100, 250, 500
candidates = c(5, 10, 50, 100, 250)
#test ntree = 500, 1000, 2500
treecount = c(1000)

#Testing a range of parameters
metric <- "Accuracy"
#Control tests for ROC, Sensitivity, Specificity
control <- trainControl(method="cv", number=10, 
                        summaryFunction=twoClassSummary, 
                        classProbs=TRUE,
                        savePredictions = 'all',
                        allowParallel=TRUE)
tunegrid <- expand.grid(.mtry=candidates)
set.seed(seed)
#Trains the model on data using parameters set
metric <- "ROC"
set.seed(seed)
tunegrid <- expand.grid(.mtry=candidates)
start.time <- Sys.time()
custom <- train(Toxicity_Value~., data=x, method="rf", 
                metric=metric, tuneGrid=tunegrid, trControl=control, 
                ntree=treecount, na.action = na.exclude)
end.time <- Sys.time()
time.taken <- round(end.time - start.time,2)
time.taken
#Plot and View Data
custom
#plot(custom)

#Predict on Test Set
predout = predict(custom, testset)

#Tests accuracy of model on the Test Set
length = length(testset$Toxicity_Value)
counts = 0
for (i in 1:length) {
  if (testset$Toxicity_Value[i] == predout[i]) {
    counts <- counts + 1
  }
}
acc = counts/nrow(testset)
print(paste("Accuracy = ", acc))

#Determines Cohen's Kappa Coefficient of Model
testset$Toxicity_Value = as.factor(testset$Toxicity_Value) 
postResample(pred = predout, obs = testset$Toxicity_Value)

#Converts Toxicity_Value Data back to numerical to calculate RMSE
df$Toxicity_Value <- ifelse(df$Toxicity_Value == 1, "T", "F")
binary_testset <- ifelse(testset$Toxicity_Value == 'T', 1, 0)
binary_preds <- ifelse(predout == 'T', 1, 0)
#Determines RMSE of model
RMSE <- rmse(binary_testset, binary_preds)

#Output all results to text
#Change output file depending on inputs
sink(file = 'autoencdataRF.txt')
print('from autoencdata.csv')
print(paste("ntree = ", treecount))
print(paste("mtry = ", candidates))
custom
postResample(pred = predout, obs = testset$Toxicity_Value)
print(paste("Accuracy = ", acc))
print(paste("RMSE = ", RMSE))
print(time.taken)
sink()

