library(caret)
library(mlbench)
library(randomForest)

endodata <- read_csv("Documents/test/caret_stuff/processed_endo_data.csv")
endodata <- endodata[, colSums(is.na(endodata)) == 0]
endodata$Toxicity_Value = as.factor(endodata$Toxicity_Value) 
x <- endodata$`Canonical SMILES`
y <- endodata$Toxicity_Value


control <- trainControl(method="repeatedcv", number=10, repeats=3)
seed <- 81
metric <- "Accuracy"
set.seed(seed)
mtry <- 10
tunegrid <- expand.grid(.mtry=mtry)
rf_default <- train(Toxicity_Value~., data=endodata, method="rf", 
                     metric=metric, tuneGrid=tunegrid, trControl=control)
