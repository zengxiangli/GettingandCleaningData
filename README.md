# GettingandCleaningData

```r
path <- file.path(getwd())
url  <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
```

## create directory if the path is not exists
```r
if(!file.exists(path)){
    dir.create(path)
}
```

## download the dataset file if file not exists
```r
file <- file.path(path,"dataset.zip")
if(!file.exists(file)){
    download.file(url,file)
}
```


## unzip the zip file 
```r
unzipedDataPath <- file.path(getwd(),"UCI HAR Dataset")
if(!file.exists(unzipedDataPath)){
    cmd <- paste('"C:\\Program Files\\HaoZip\\haozipc.exe" x',
        paste0("\"",file,"\""))
    system(cmd)
}
```

## load data.table library
```r
library(data.table)
```

## Read the train data
```r
dtSetTrain <- read.table(file.path(unzipedDataPath, "train", "x_train.txt"))
dtSubjectTrain <- read.table(file.path(unzipedDataPath, "train", "subject_train.txt"))
dtLabelTrain <- read.table(file.path(unzipedDataPath, "train", "y_train.txt"))
```

## Read the test data
```r
dtSetTest <- read.table(file.path(unzipedDataPath, "test", "x_test.txt"))
dtSubjectTest <- read.table(file.path(unzipedDataPath, "test", "subject_test.txt"))
dtLabelTest <- read.table(file.path(unzipedDataPath, "test", "y_test.txt"))
```

## Concatenate train data
```r
dtTrain <- cbind(dtSubjectTrain,dtLabelTrain,dtSetTrain)
```

## Concatenate test data
```r
dtTest <- cbind(dtSubjectTest,dtLabelTest,dtSetTest)
```

## Merge train and test data
```r
dt <- rbind(dtTrain,dtTest)
```

## Read features
```r
dtFeatures <- fread(file.path(unzipedDataPath,"features.txt"))
setnames(dtFeatures,names(dtFeatures),c('id','name'))
dtFeatures <- dtFeatures[grep("-mean|-std",dtFeatures$name),]
```


## Create tidy data
```r
cols <- c(1,2,dtFeatures$id+2)
dt <- dt[,cols]
```

## set names
```r
setnames(dt,c("subject.id","activity.name",dtFeatures$name))
dtActNames <- read.table(file.path(unzipedDataPath,"activity_labels.txt"))
setnames(dtActNames,names(dtActNames),c("id","name"))
dt$activity.name <- factor(dt$activity.name, levels = dtActNames$id, labels = dtActNames$name)
```

## creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```r
tidy <- aggregate(dt[,3:ncol(dt)], by = list(dt$subject.id, dt$activity.name), FUN = mean)
```

## set first two column names again
```r
colnames(tidy)[1:2] <- c("subject.id", "activity.name")
```

## save the dataset to txt file
```r
write.table(tidy, file="tidy_data.txt", row.names = FALSE)
```

