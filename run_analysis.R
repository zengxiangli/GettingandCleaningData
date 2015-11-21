path <- file.path(getwd())
url  <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!file.exists(path)){
    dir.create(path)
}

file <- file.path(path,"dataset.zip")

if(!file.exists(file)){
    download.file(url,file)
}

unzipedDataPath <- file.path(getwd(),"UCI HAR Dataset")

if(!file.exists(unzipedDataPath)){
    cmd <- paste('"C:\\Program Files\\HaoZip\\haozipc.exe" x',
        paste0("\"",file,"\""))
    system(cmd)
}
library(data.table)

## Read the train data
dtSetTrain <- read.table(file.path(unzipedDataPath, "train", "x_train.txt"))
dtSubjectTrain <- read.table(file.path(unzipedDataPath, "train", "subject_train.txt"))
dtLabelTrain <- read.table(file.path(unzipedDataPath, "train", "y_train.txt"))

## Read the test data
dtSetTest <- read.table(file.path(unzipedDataPath, "test", "x_test.txt"))
dtSubjectTest <- read.table(file.path(unzipedDataPath, "test", "subject_test.txt"))
dtLabelTest <- read.table(file.path(unzipedDataPath, "test", "y_test.txt"))

## Concatenate train data
dtTrain <- cbind(dtSubjectTrain,dtLabelTrain,dtSetTrain)

## Concatenate test data
dtTest <- cbind(dtSubjectTest,dtLabelTest,dtSetTest)

## Merge train and test data
dt <- rbind(dtTrain,dtTest)

## Read features
dtFeatures <- fread(file.path(unzipedDataPath,"features.txt"))
setnames(dtFeatures,names(dtFeatures),c('id','name'))
dtFeatures <- dtFeatures[grep("-mean|-std",dtFeatures$name),]


## Create tidy data
cols <- c(1,2,dtFeatures$id+2)
dt <- dt[,cols]

## set names
setnames(dt,c("subject.id","activity.name",dtFeatures$name))
dtActNames <- read.table(file.path(unzipedDataPath,"activity_labels.txt"))
setnames(dtActNames,names(dtActNames),c("id","name"))

dt$activity.name <- factor(dt$activity.name, levels = dtActNames$id, labels = dtActNames$name)

tidy <- aggregate(dt[,3:ncol(dt)], by = list(dt$subject.id, dt$activity.name), FUN = mean)

write.table(tidy, file="tidy_data.txt", row.names = FALSE)

