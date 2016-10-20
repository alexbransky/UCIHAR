library(data.table)

## create the data directory if it doesn't exist
if (!file.exists("data")) {
    dir.create("data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dateDownloaded <- date()

## download the zip file
download.file(fileUrl, destfile="./data/UCI.zip")

## unzip the file
unzip("./data/UCI.zip", exdir = "./data/UCI")

## view the contents of the unzipped folder
file_list <- list.files("./data/UCI", recursive = TRUE)
# run file_list to view files

#### Merge training and test sets 
features <- read.table("./data/UCI/UCI HAR Dataset/features.txt", header=FALSE)
features$V2 <- tolower(features[,2])
features$V2 <- gsub('\\ ',"",features[,2])
features$V2 <- gsub('\\(',"",features[,2])
features$V2 <- gsub('\\)',"",features[,2])
features$V2 <- gsub('\\-',"_",features[,2])
features$V2 <- gsub('\\,',"_",features[,2])

### Test set
## load data
X_test <- read.table("./data/UCI/UCI HAR Dataset/test/X_test.txt", header=FALSE, col.names=features[,2])
## segregate test data
X_test$type <- "test"
## load activity labels
y_test <- read.table("./data/UCI/UCI HAR Dataset/test/y_test.txt", header=FALSE)
X_test$activityid <- y_test[,1]
## load subject train id
subject_test <- read.table("./data/UCI/UCI HAR Dataset/test/subject_test.txt", header=FALSE)
X_test$subject <- subject_test[,1]


### train set
## load data
X_train <- read.table("./data/UCI/UCI HAR Dataset/train/X_train.txt", header=FALSE, col.names=features[,2])
## segregate test data
X_train$type <- "train"
## load activity labels
y_train <- read.table("./data/UCI/UCI HAR Dataset/train/y_train.txt", header=FALSE)
X_train$activityid <- y_train[,1]
## load subject train id
subject_train <- read.table("./data/UCI/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
X_train$subject <- subject_train[,1]
## X_train[1:100,c(564,563,562)]
## X_train$subject

mergedData <- rbind(X_test, X_train)

## Extract only the measurements on the mean and standard deviation for each measurement
correctColumns <- grep("mean|std", names(mergedData))
## Add last columns that contains activitylabel, subject and type
correctColumns <- c(563,564,562,correctColumns)
mergedData_MeanStd <- mergedData[,correctColumns]

## Label the data set with descriptive variable names. 
activity_labels <- read.table("./data/UCI/UCI HAR Dataset/activity_labels.txt", header=FALSE, col.names=c("activityid", "activitylabel"))
library(plyr)
mergedData_MeanStd <- join(activity_labels, mergedData_MeanStd)

## Creates a second, independent tidy data set with the average of each 
##  variable for each activity and each subject.
library(reshape2)
mergedDataMeanStd_melt <- melt(mergedData_MeanStd,
                               id=c("activitylabel","subject","type"),
                               measure.vars=names(mergedData_MeanStd[,5:90])) # only data variables

meanData <- acast(mergedDataMeanStd_melt, variable ~ activitylabel ~ subject, mean)
meanData
write.table(meanData, file="./data/tidydataset.txt", quote=TRUE, sep=",", row.name=FALSE)