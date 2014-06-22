run_analysis <- function(){
        
        #Hard-coded data file paths
        paths <- c(
                "subject_test" = "UCI HAR Dataset/test/subject_test.txt",
                "X_test" = "UCI HAR Dataset/test/X_test.txt",
                "y_test" = "UCI HAR Dataset/test/y_test.txt",
                "subject_train" = "UCI HAR Dataset/train/subject_train.txt",
                "X_train" = "UCI HAR Dataset/train/X_train.txt",
                "y_train" = "UCI HAR Dataset/train/y_train.txt",
                "features" = "UCI HAR Dataset/features.txt",
                "activities" = "UCI HAR Dataset/activity_labels.txt"
                )
        
        #load the data file contents into memory
        rawData <- loadData(paths)
        #extract the 561 features names from features.txt
        featureNames <- getFeatureNames(paths["features"])
        #extract the activity names and keys from activity_labels.txt
        activityLookup <- getActivityNames(paths["activities"])
        #combine the X and y data for the test and training set into a single data frame
        combinedData <- combineDataSet(rawData, featureNames)
        #limit the data to onle the mean and standard deviation feature measurements
        meanAndStds <- selectMeanAndStdData(combinedData)
        #convert the activity ids into descriptions (WALKING, etc)
        labeledData <- labelActivities(meanAndStds, activityLookup)
        #summarize the data into a single, mean value of each measurement for each subject-action combo
        summarizeData(labeledData)
        #export data into .csv file
        write.csv(data,"summarizedData.csv")
}        
        
## open files and load into a list of 6 data
loadData <- function(paths){

        list(
                "subjectTest" =  read.table(paths["subject_test"]),
                "XTest" = read.table(paths["X_test"]),
                "yTest" = read.table(paths["y_test"]),
                "subjectTrain" = read.table(paths["subject_train"]),
                "XTrain" = read.table(paths["X_train"]),
                "yTrain" = read.table(paths["y_train"])                
                )        
}

##create vector of feature names
getFeatureNames <- function(featurePath){
        features<-read.table(featurePath)  
        as.character(features[,2])
}

##create activity lookup table
getActivityNames <- function(activityPath){
        activities<-read.table(activityPath)
        colnames(activities)<-c("index","activityName")
        activities
}

##combine subject, X, and y tables into single data frame
combineDataSet <- function(rawDataList, features){
        testSet<- cbind(rawDataList[["subjectTest"]],rawDataList[["yTest"]],rawDataList[["XTest"]])
        colnames(testSet) <- c("subjects","activities",features)
        trainSet<- cbind(rawDataList[["subjectTrain"]],rawDataList[["yTrain"]],rawDataList[["XTrain"]])
        colnames(trainSet) <- c("subjects","activities",features)        
        rbind(testSet,trainSet)
}

##filter out for only mean and standard deviation columns using regular expression
selectMeanAndStdData <- function(dataSet){
        selections<-c(1,2,grep("mean\\(\\)",names(dataSet)),grep("std\\(\\)",names(dataSet)))
        dataSet[,selections]        
}

##use merge() function to perform inner join on mean and standard deviation data and activity lookup table
labelActivities <- function(dataSet,activityLookup){
        merge(x=dataSet,y=activityLookup,by.x="activities",by.y="index")   
}

##create summarized, tidy data set with the average values of each variable by activity and subject
summarizeData <- function(labeledDataSet){
        ##melt labeled data set into "long form", so that each row lists the variable name and value
        meltData <- melt(labeledData, id=c("subjects", "activityName"), measure.vars=names(labeledData)[3:68])
        
        ##cast melted data back into "wide form" so that each variable name is a column with the mean as value
        dcast(meltData, subjects + activityName ~ variable, mean)
}