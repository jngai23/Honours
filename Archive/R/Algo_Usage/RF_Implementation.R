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

cl <- makePSOCKcluster(5)
registerDoParallel(cl)
stopCluster(cl)

seed <- 81
set.seed(seed)

#Data Reading
df <- deepnormspedata

#Sampling for testing
df <- sample_n(df[,2:(ncol(df))], 1000)
sampleset <- createDataPartition(df$Toxicity_Value, p=0.8, list=FALSE)


#Convert Toxicity_Value into a factor for the algorithm
#Numerical Binary (1,0) values are also altered to Categorical (T, F)
df$Toxicity_Value <- ifelse(df$Toxicity_Value == 1, "T", "F")
df$Toxicity_Value = as.factor(df$Toxicity_Value) 

#Creating test and train sets
testset <- df[-sampleset,]
trainset <- df[sampleset,]

x <- trainset#[,2:ncol(trainset)]
y <- trainset$Toxicity_Value

#Random Forest Algorithm initialisation
#Identical to Inbuilt RandomForest from caret but multiple variables can be tested
RF <- list(type = "Classification", library = "randomForest", loop = NULL)
RF$parameters <- data.frame(parameter = c("mtry", "ntree"), 
                            class = rep("numeric", 2), 
                            label = c("mtry", "ntree"))
RF$grid <- function(x, y, len = NULL, search = "grid") {}
RF$fit <- function(x, y, wts, param, lev, last, weights, classProbs, ...) {
  randomForest(x, y, mtry = param$mtry, ntree=param$ntree, ...)
}
RF$predict <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata)
RF$prob <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata, type = "prob")
RF$sort <- function(x) x[order(x[,1]),]
RF$levels <- function(x) x$classes

#Parameter setting
candidates = c(25, 50)
treecount = c(100, 250)

#Testing a range of parameters
metric <- "Accuracy"
#Control tests for ROC, Sensitivity, Specificity
control <- trainControl(method="cv", number=10, 
                        summaryFunction=twoClassSummary, 
                        classProbs=TRUE,
                        savePredictions = 'all',
                        allowParallel=TRUE)
tunegrid <- expand.grid(.mtry=candidates, .ntree=treecount)
set.seed(seed)
#Trains the model on data using parameters set
custom <- train(Toxicity_Value~., data=x, method=RF,
                metric=metric, tuneGrid=tunegrid,
                trControl=control, na.action = na.exclude)
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
postResample(pred = predout, obs = testset$Toxicity_Value)

#Converts Toxicity_Value Data back to numerical to calculate RMSE
df$Toxicity_Value <- ifelse(df$Toxicity_Value == 1, "T", "F")
binary_testset <- ifelse(testset$Toxicity_Value == 'T', 1, 0)
binary_preds <- ifelse(predout == 'T', 1, 0)
#Determines RMSE of model
RMSE <- rmse(binary_testset, binary_preds)

#Output all results to text
sink(file = 'output.txt')
print('from deepnormspedata.csv')
custom
postResample(pred = predout, obs = testset$Toxicity_Value)
print(paste("Accuracy = ", acc))
print(paste("RMSE = ", RMSE))
sink()

control <- trainControl(method="cv", number=10, repeats=3)
metric <- "Accuracy"
set.seed(seed)
mtry <- 12
tunegrid <- expand.grid(.mtry=mtry)
confusegrid <- train(Toxicity_Value~., data=headtrain, method="rf", 
                     metric=metric, tuneGrid=tunegrid, trControl=control, 
                     ntree=1500, na.action = na.exclude, allowParallel=TRUE)
