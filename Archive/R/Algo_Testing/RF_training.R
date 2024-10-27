#Random Forest Model Training

library(caret)
library(mlbench)
library(randomForest)
library(dplyr)

seed <- 81

#Data reading
endodata <- read_csv("Documents/test/caret_stuff/final.csv")
#Selecting data sample from set (~12000 datapoints)
headata <- sample_n(endodata, 300)
#Removes Null cells
headata <- headata[, colSums(is.na(endodata)) == 0]
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
x <- headata[,4:colcount]
y <- headata$Toxicity_Value
#Creating control set & Confusion Matrix Construction
control <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"
set.seed(seed)
mtry <- 20
tunegrid <- expand.grid(.mtry=mtry)
confusegrid <- train(Toxicity_Value~., data=headata, method="rf", 
                     metric=metric, tuneGrid=tunegrid, trControl=control, ntree=500)
print(confusegrid)


#Custom Algo creation

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
control <- trainControl(method="repeatedcv", number=10, repeats=3)
tunegrid <- expand.grid(.mtry=c(1:15), .ntree=c(1000, 1500, 2000, 2500))
set.seed(seed)
custom <- train(Toxicity_Value~., data=headata, method=customRF, metric=metric, tuneGrid=tunegrid, trControl=control)
summary(custom)
plot(custom)
