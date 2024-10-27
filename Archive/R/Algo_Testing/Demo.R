#Demo of currrent progress

#Main ML library
library(caret)
#Dataset library for testing
library(mlbench)
#First applied model
library(randomForest)
#Dataframe manip tools
library(dplyr)
#Testing adaboost as a method (wip)
library(ada)
#Testing parallel processing to speed up training times (wip)
library(parallel)
library(doParallel)


#Data Preprocessing
seed <- 81
set.seed(seed)

#Data reading
endodata <- read_csv("Documents/test/caret_stuff/final.csv")
#Selecting data sample from set (~12000 datapoints) to reduce training times
headata <- sample_n(endodata[,3:ncol(endodata)], 100)
#Removes Null cells (No longer necessary)
#headata <- headata[, colSums(is.na(headata)) == 0]

#Renders Toxicity_Value as a factor
headata$Toxicity_Value = as.factor(headata$Toxicity_Value) 

#Removes Duplicate columns
#As each character in a SMILE is its own data point, if the longest SMILE is not
#In the sample, the extra columns need removing
duperemove <- function(data) {
  dupecol <- sapply(data, function(col) length(unique(col)) == 1)
  data[, !dupecol, drop = FALSE]
}
headata <- duperemove(headata)
colcount <- ncol(headata)

#Creation of testing & training sets
headsamp <- sample(1:nrow(headata), 0.8 * nrow(headata)) 
headtest <- headata[-headsamp,]
headtrain <- headata[headsamp,]

headtest <- duperemove(headtest)
headtrain <- duperemove(headtrain)
colcount <- ncol(headtrain)

#Set x and y values to features & toxicity respectively
x <- headtrain[,2:colcount]
y <- headtrain$Toxicity_Value

################################################################################

#Random Forest Algorithm Setup
#Training control & Confusion Matrix Parameter Construction using Accuracy as metric
control <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"
set.seed(seed)

mtry <- 20
numtree <- 500

tunegrid <- expand.grid(.mtry=mtry)
#(Relatively) quick command to spot test a given model parameters
paramtester <- train(Toxicity_Value~., data=headata, method="rf", 
                     metric=metric, tuneGrid=tunegrid, 
                     trControl=control, ntree=numtree)
print(paramtester)

#Output

#Random Forest 
#
#100 samples
#226 predictors
#2 classes: '0', '1' 
#
#No pre-processing
#Resampling: Cross-Validated (10 fold, repeated 3 times) 
#Summary of sample sizes: 90, 89, 91, 90, 90, 90, ... 
#Resampling results:
#  
#  Accuracy   Kappa    
#0.6311785  0.1419494
#
#Tuning parameter 'mtry' was held constant at a value of 20


#Random Forest Algorithm creation for searching for optimal parameters
customRF <- list(type = "Classification", library = "randomForest", loop = NULL)
customRF$parameters <- data.frame(parameter = c("mtry", "ntree"), 
                                  class = rep("numeric", 2), 
                                  label = c("mtry", "ntree"))

customRF$grid <- function(x, y, len = NULL, search = "grid") {}
customRF$fit <- function(x, y, wts, param, lev, last, weights, classProbs, ...) {
  randomForest(x, y, mtry = param$mtry, ntree=param$ntree, ...)
}
customRF$predict <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata)
customRF$prob <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata, type = "prob")
customRF$sort <- function(x) x[order(x[,1]),]
customRF$levels <- function(x) x$classes

#Training a model given certain bounds
#Parameters are 'mtry' (number of vars used at each split) 
# and 'ntree' (number of trees)
mtryrange <- c(1:5)
ntreerange <- c(1000, 1500, 2000, 2500)

control <- trainControl(method="repeatedcv", number=10, repeats=3)
tunegrid <- expand.grid(.mtry=mtryrange, .ntree=ntreerange)
set.seed(seed)
custom <- train(Toxicity_Value~., data=headata, method=customRF, 
                metric=metric, tuneGrid=tunegrid, trControl=control)
summary(custom)
plot(custom)

################################################################################

#Current model testing (adaboost)

#Converts data from binary (0,1) to categorical (F,T)
category_to_binary <- function(data, colname) {
  data[[colname]] <- ifelse(data[[colname]] == 1, 'T',
                            ifelse(data[[colname]] == 0, 'F', data[[colname]]))
  return(data)
}

#Converts datasets from binary data to categorical data
headtrain <- category_to_binary(headtrain, "Toxicity_Value")
headtest <- category_to_binary(headtest, "Toxicity_Value")
headata <- category_to_binary(headata, "Toxicity_Value")

#Enabling Parallel Processing
#library(doParallel)
#cl <- makePSOCKcluster(4)
#registerDoParallel(cl)

control <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"

#Testing on Dataset

#uses new dataset, special characters (:,-,+ etc,) to regular chars (sb, db etc,)
#Not yet tuned
bagrid <- expand.grid(.iter=3, .maxdepth=2, .nu=3)
adatest <- train(Toxicity_Value~., data=headtrain, method="ada", 
                 metric=metric, trControl=control)
print(adatest)

#Boosted Classification Trees 
#
#100 samples
#49 predictor
#2 classes: '0', '1' 
#
#No pre-processing
#Resampling: Cross-Validated (10 fold, repeated 3 times) 
#Summary of sample sizes: 89, 91, 89, 90, 90, 90, ... 
#Resampling results:
#  
#  Accuracy  Kappa      
#0.509899  -0.02677629
#
#Tuning parameter 'iter' was held constant at a value of 5
#Tuning parameter 'maxdepth' was
#held constant at a value of 2
#Tuning parameter 'nu' was held constant at a value of 3

#stopCluster(cl)
##################

