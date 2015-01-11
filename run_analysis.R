library(dplyr)
library(plyr)

#set appropriate work directory --- setwd()

#set the url for download
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
#download the file
download.file(Url,destfile="./Data.zip") 

#unzip the files
unzip(zipfile="Data.zip") 

#Create the folder to save the files
caminho <- file.path("UCI HAR Dataset") 
#recursive=TRUE to view all files in subdirectories too
arquivos <- list.files(caminho, recursive = TRUE) 
#See the result
arquivos 

#README file shows the files with the useful information

# features.txt contain the variable names
# activity_labels.txt contain the variable level names

#Read the files
SubTrain <- read.table(file.path(caminho, "train", "subject_train.txt"),header = FALSE)
#read the table into caminho, subdirectory train/test, without header - introduce after
SubTest  <- read.table(file.path(caminho, "test" , "subject_test.txt"),header = FALSE)

YTest  <- read.table(file.path(caminho, "test" , "Y_test.txt" ), header = FALSE)
YTrain <- read.table(file.path(caminho, "train", "Y_train.txt"),header = FALSE)

XTest  <- read.table(file.path(caminho, "test" , "X_test.txt" ),header = FALSE)
XTrain <- read.table(file.path(caminho, "train", "X_train.txt"),header = FALSE)

#Merge data sets

Subject <- rbind(SubTrain, SubTest) 
Y <- rbind(YTrain, YTest)  
X <- rbind(XTrain, XTest)  

#Introduce the names into the data.frames
names(Subject)<-c("subject") #change the column name "V1" to "subject"
names(Y)<- c("activity") #change the column name to y -Single column
dataNames <- read.table(file.path(caminho, "features.txt"),head=FALSE)
names(X)<- dataNames$V2 #Set names to the columns from feature.txt - Multiple Columns

#Bind all tables by columns
SubandY <- cbind(Subject, Y)
All <- cbind(X, SubandY)

#choose names with mean and std (pattern recognition[grep])
subdataNames<-dataNames$V2[grep("mean\\(\\)|std\\(\\)", dataNames$V2)]

Names<-c(as.character(subdataNames), "subject", "activity" )
All<- subset(All, select = Names)

labels <- read.table(file.path(caminho, "activity_labels.txt"),header = FALSE)
#load activity label - here named as Y - to recognize the label names
All$activity <- factor(All$activity, labels = labels$V2)

#pattern matching and Replacement -  change for descriptive variable names   
names(All)<-gsub("^t", "time", names(All))  
names(All)<-gsub("^f", "frequency", names(All))
names(All)<-gsub("Acc", "Accelerometer", names(All))
names(All)<-gsub("Gyro", "Gyroscope", names(All))
names(All)<-gsub("Mag", "Magnitude", names(All))
names(All)<-gsub("BodyBody", "Body", names(All))

#Creating tidy data
# "Independent tidy data set with the average of each variable for each activity and each subject".
TidyData<-aggregate(. ~subject + activity, All, mean)
TidyData<-TidyData[order(TidyData$subject,TidyData$activity),]
write.table(TidyData, file = "tidydata2.txt",row.name=FALSE)
