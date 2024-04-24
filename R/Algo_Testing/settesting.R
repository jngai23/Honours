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
#endodata <- read_csv("Documents/test/caret_stuff/final.csv")
endodata <- deepnormspedata
#Selecting data sample from set (~12000 datapoints)
headata <- sample_n(endodata[,2:(ncol(endodata))], 1000)
#Removes Null cells
#headata <- headata[, colSums(is.na(headata)) == 0]
headata$Toxicity_Value = as.factor(headata$Toxicity_Value) 
deepnormspedata$Toxicity_Value = as.factor(deepnormspedata$Toxicity_Value) 

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

control <- trainControl(method="cv", number=10, repeats=3)
metric <- "Accuracy"
set.seed(seed)
mtry <- 12
tunegrid <- expand.grid(.mtry=mtry)
confusegrid <- train(Toxicity_Value~., data=headtrain, method="rf", 
                     metric=metric, tuneGrid=tunegrid, trControl=control, 
                     ntree=1500, na.action = na.exclude, allowParallel=TRUE)
print(confusegrid)

cl <- makeCluster(detectCores() - 1)
registerDoParallel(cl)

adagrid <- expand.grid(.iter=3, .maxdepth=5, .nu=5)
adatest <- train(Toxicity_Value~., data=headtrain, method="ada", tuneGrid=adagrid, 
                 metric=metric, trControl=control)
                     
print(confusegrid)

testest <- train(Species~.,iris, method = "ada", tuneGrud=adagrid)

datainitialiser <- function(dataset, samplecount) {
  
}

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

removecol <- adremover(headtrain, headtest)
removedtest <- headtest[-c(removecol),]

predictions <- predict(confusegrid, removedtest)
confusionMatrix(predictions, removedtest$Toxicity_Value)





#Custom Algo creation
#Code snippet taken from "https://machinelearningmastery.com/tune-machine-learning-algorithms-in-r/"
#*Temporary, to be rewritten and adjusted for usage
customRF <- list(type = "Classification", library = "randomForest", loop = NULL)
customRF$parameters <- data.frame(parameter = c("mtry", "ntree"), class = rep("numeric", 2), label = c("mtry", "ntree"))
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

# train model

#library(foreach)
#library(doParallel)
#cluster <- makeCluster(7)
#registerDoParallel(cluster)
#stopCluster(cluster)

control <- trainControl(method="repeatedcv", number=10, repeats=3)
tunegrid <- expand.grid(.mtry=c(5:10), .ntree=c(125, 150, 175, 200))
set.seed(seed)
custom <- train(Toxicity_Value~., data=headata, method=customRF,
                metric=metric, tuneGrid=tunegrid,
                trControl=control, na.action = na.exclude)
custom
plot(custom)

featurePlot(x = deepnormspedata[, 3:7], y = deepnormspedata$Toxicity_Value, plot = 'box')
