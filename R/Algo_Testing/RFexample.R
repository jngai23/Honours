#11/3/24 Random forest testing 

library(caret)
library(mlbench)
library(randomForest)
library(dplyr)

seed <- 81
set.seed(seed)
#Data reading
endodata <- read_csv("Documents/test/caret_stuff/final.csv")
#Selecting data sample from set (~12000 datapoints)
headata <- sample_n(endodata, 100)
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
mtry <- 12
tunegrid <- expand.grid(.mtry=mtry)
confusegrid <- train(Toxicity_Value~., data=headata, method="rf", 
                    metric=metric, tuneGrid=tunegrid, trControl=control, ntree=1500)
print(confusegrid)

#Random Search for mtry
control <- trainControl(method="repeatedcv", number=10, repeats=3, search="random")
set.seed(seed)
mtry <- 7
newgrid <- train(Toxicity_Value~., data=headata, method="rf", metric=metric, tuneLength=15, trControl=control)
print(newgrid)
plot(newgrid)
#Optimal value found to be ~12

#Grid search for mtry
control <- trainControl(method="repeatedcv", number=10, repeats=3, search="grid")
set.seed(seed)
tunegrid <- expand.grid(.mtry=c(1:15))
rf_gridsearch <- train(Toxicity_Value~., data=headata, method="rf", metric=metric, tuneGrid=tunegrid, trControl=control)
print(rf_gridsearch)
plot(rf_gridsearch)
#Optimal value still remains as 12

#Algorithm Tune for mtry
set.seed(seed)
bestmtry <- tuneRF(x, y, stepFactor=1.5, improve=1e-5, ntree=500)
print(bestmtry)
#Optimises between 10 and 15

# Manual Search
control <- trainControl(method="repeatedcv", number=10, repeats=3, search="grid")
tunegrid <- expand.grid(.mtry=12)
modellist <- list()
for (ntree in c(1000, 1500, 2000, 2500)) {
  set.seed(seed)
  fit <- train(Toxicity_Value~., data=headata, method="rf", metric=metric, tuneGrid=tunegrid, trControl=control, ntree=ntree)
  key <- toString(ntree)
  modellist[[key]] <- fit
}
# compare results
results <- resamples(modellist)
summary(results)
dotplot(results)
#ntree peaks in acc + kappa at ~1500
