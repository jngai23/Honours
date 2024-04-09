#Testing Logistic Regression

#KNN Training 

library(caret)
library(mlbench)
library(randomForest)
library(dplyr)
library(ada)
library(parallel)
library(doParallel)


seed <- 81
set.seed(seed)

#Data reading
#endodata <- pleaseactuallywork
endodata <- normspedata
#Selecting data sample from set (~12000 datapoints)
headata <- sample_n(endodata[,2:ncol(endodata)], 100)
#Removes Null cells
#headata <- headata[, colSums(is.na(headata)) == 0]
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

headsamp <- sample(1:nrow(headata), 0.8 * nrow(headata)) 

headtest <- headata[-headsamp,]
headtrain <- headata[headsamp,]

headtest <- duperemove(headtest)
headtrain <- duperemove(headtrain)
colcount <- ncol(headtrain)

x <- headtrain[,2:colcount]
y <- headtrain$Toxicity_Value

library(plyr)
##################

category_to_binary <- function(data, colname) {
  data[[colname]] <- ifelse(data[[colname]] == 1, 'T',
                            ifelse(data[[colname]] == 0, 'F', data[[colname]]))
  return(data)
}

headtrain <- category_to_binary(headtrain, "Toxicity_Value")
headtest <- category_to_binary(headtrain, "Toxicity_Value")
headata <- category_to_binary(headata, "Toxicity_Value")


#library(doParallel)
#cl <- makePSOCKcluster(4)
#registerDoParallel(cl)

control <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"

library(mlbench)

data(Sonar)
bagrid <- expand.grid(.iter=5, .maxdepth=2, .nu=3)
bagtest <- train(Toxicity_Value~., data=headata, method="ada", 
                 trControl=control, tuneGrid=bagrid, metric=metric, na.action=na.pass)

test <- headata[,1:3]
test <- test %>% select(-char1) 

metric <- "Accuracy"
bagrid <- expand.grid(.iter=5, .maxdepth=2, .nu=3)
bagtest <- train(Toxicity_Value~., data=headata, method="ada", 
                 trControl=control, tuneGrid=bagrid, metric=metric, na.action=na.pass)
#stopCluster(cl)
##################

##################
#Testing other models

#Bayesian linear regression
#Works but no adjustable parameters
library(arm)
testtest <- train(Toxicity_Value~., data=headata, method="bayesglm", 
                  metric=metric, trControl=control)
print(testtest)

#Boosted General Additive Model
#Accuracy metric values missing
library(mboost, plyr, import)
gamgrid <- expand.grid(.mstop=3, .prune=1)
gamtest <- train(Toxicity_Value~., data=headata[,1:50], method="gamboost", 
                 metric=metric, trControl=control, tuneGrid=gamgrid, na.action=na.pass)

data(Sonar)
gamtest <- train(Class~., data=Sonar, method="gamboost", 
                 metric=metric, trControl=control, tuneGrid=gamgrid)

#Gaussian Process
#Error, cannot scale data
library(kernlab)
gamgrid <- expand.grid(.scale=3, .degree=1)
gamtest <- train(Toxicity_Value~., data=headata[,1:53], method="gaussprPoly", 
                 metric=metric, trControl=control, tuneGrid=gamgrid)


##################


#Random Forest algo for reference
control <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"
set.seed(seed)
mtry <- 12
tunegrid <- expand.grid(.mtry=mtry)
confusegrid <- train(Toxicity_Value~., data=headtrain, method="rf", 
                     metric=metric, tuneGrid=tunegrid, trControl=control, 
                     ntree=1500, na.action = na.pass, allowParallel=TRUE)
print(confusegrid)



#removes all items in test set not seen in the train set
adremover <- function(train,test){
  testcol <- ncol(test)
  traincol <- ncol(train)
  colcount <- min(testcol, traincol)
  
  toremove <- c()
  seen <- c()
  currcol <- 1
  loops <- 1
  rowcount <- 1
  
  for (coll in train[,1:colcount]) {
    for (row in coll) {
      if (is.element(row, seen) == FALSE) {
        seen <- append(seen, row)
      }
    }
    for (row in test[,loops]) {
      for (items in row) {
        if (is.element(items, seen ) == FALSE) {
          toremove <- append(toremove, rowcount)
        }
        rowcount <- (rowcount + 1)
      }
      rowcount <- 1
    }
    
    loops <- (loops + 1)
    seen <- c()
  }
  toremove <- unique(toremove)
  return(toremove)
}
#Test set analysis
removecol <- adremover(headtrain, headtest)
removedtest <- headtest[-c(removecol),]

predictions <- predict(confusegrid, removedtest)
confusionMatrix(predictions, removedtest$Toxicity_Value)