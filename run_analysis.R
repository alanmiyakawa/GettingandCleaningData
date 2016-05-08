#Set the working directory.
setwd("~/Desktop/Coursera")
#Download, unzip, and list the UCI files. Go Anteaters!
if(!file.exists("./UCIdata")){dir.create("./UCIdata")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./UCIdata/UCIDataset.zip", method="curl")
unzip(zipfile="./UCIdata/UCIDataset.zip", exdir="./UCIdata")
path_rf <- file.path("./UCIdata" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
#Read the relevant data files.
SubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
FeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
ActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
#Combine objects by rows and name variables.
Subject <- rbind(SubjectTrain, SubjectTest)
Features<- rbind(FeaturesTrain, FeaturesTest)
Activity<- rbind(ActivityTrain, ActivityTest)
names(Subject)<-c("subject")
names(Activity)<- c("activity")
FeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2
#Merge to the columns to create a master data frame.
SubAct <- cbind(Subject, Activity)
MasterData <- cbind(Features, SubAct)
#Subset the data for the mean and standard deviation.
subFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
selectedNames<-c(as.character(subFeaturesNames), "subject", "activity" )
MasterData<-subset(MasterData,select=selectedNames)
#Apply labels in "activity_labels.txt" to the file and assign more specific names.
ActivityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
MasterData$activity<-factor(MasterData$activity);
MasterData$activity<- factor(MasterData$activity,labels=as.character(ActivityLabels$V2))
names(MasterData)<-gsub("^t", "time", names(MasterData))
names(MasterData)<-gsub("^f", "frequency", names(MasterData))
names(MasterData)<-gsub("Acc", "Accelerometer", names(MasterData))
names(MasterData)<-gsub("Gyro", "Gyroscope", names(MasterData))
names(MasterData)<-gsub("Mag", "Magnitude", names(MasterData))
names(MasterData)<-gsub("BodyBody", "Body", names(MasterData))
#Create a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
MasterData2<-aggregate(. ~subject + activity, MasterData, mean)
MasterData2<-MasterData2[order(MasterData2$subject,MasterData2$activity),]
write.table(MasterData2, file = "FinalData.txt",row.name=FALSE)
