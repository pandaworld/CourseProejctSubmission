##   run_analysis.R   is a script to create a tidy data set from the raw data set fouind in the following repository
##   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
##   25 July 2015
#
## This script assumes that the data has been downloaded and available in the working directory. The script will unzip the file 
## and perform the steps as described in comments to product the tidy data set of averages for means and standard deviations 
## in the raw data set for each activity and each subject.

## Step 1: Download raw data set using url and unzip into working directory
## this step is only performed once to bring down the data. As such it will be commented in the script as I will assume that
## the data is already availble in the working directory. 

## fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## download.file(fileUrl, destfile = "./UCI HAR Dataset.zip", method = "curl")
## list.files()                                                # list the directory to make confirm file is there


unzip("UCI HAR Dataset.zip")                                # unzip the downloaded file UCI HAR Dataset.zip
list.files("UCI HAR Dataset", recursive = T)                # list all the files in the unzipped folder and sub-folders

## Step 2: Examine the files to understand the raw data set and determine which files are needed to produce the tidy data set 
##         required for the course project. The focus of the assignement is on "mean" and "standard deviation." This data is 
##         within the files in the test and train folders (not the Inertial Signals folders. )

## The folder UCI HAR Dataset contains 4 files which describe the data set and 2 folders, "test" and "train".
## The "test" and "train" each contain 3 files: subject_test.txt, X_????.txt, Y_????.txt and a folder Inertial Signals. 
##      {???? = test or train}
## The Inertial Signal folders contain raw data collected from smart phones. 
## "Subject" files contain the Subject (1-30) data
## "Y" files contain Activity (1-6) data 
## "X" files contains variable Measurements data



## Step 3: Read in the data and Add column headings 
## Read the files in "test" folder into data frames, no headers in the files.  Assign column headers.

test_activity <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = F)            # read Y_test.txt and check the contents
head(test_activity)
dim(test_activity)
names(test_activity) <- c("Activity")                                                    # add the column header

test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = F)       # read subject_test.txt and check the contents
head(test_subject)
dim(test_subject)
names(test_subject) <- c("Subject")                                                    # add the column header

test_measure <- read.table("./UCI HAR Dataset/test/X_test.txt", header = F)             # read Y_test.txt and check the contents
head(test_measure, n=1)
dim(test_measure)

# read the 561 column names from the features.txt file so that we can apply that to the  measurement column names for the combined data frame
measure_headers <- read.table("UCI HAR Dataset/features.txt", header = F)
names(test_measure) <- measure_headers$V2                                                    # add the column header


## Read the files in "train" folder into data frames, no headers in the files.  
train_activity <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = F)            # read Y_train.txt and check the contents
head(train_activity)
dim(train_activity)
names(train_activity) <- c("Activity")                                                    # add the column header

train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = F)       # read subject_train.txt and check the contents
head(train_subject)
dim(train_subject)
names(train_subject) <- c("Subject")                                                    # add the column header

train_measure <- read.table("./UCI HAR Dataset/train/X_train.txt", header = F)             # read Y_train.txt and check the contents
head(train_measure, n=1)
dim(train_measure)
names(train_measure) <- measure_headers$V2                                                    # add the column header

# Step 4 :  Combine the data sets 
# combined data sets from test and train dataset for Activity, Subject and Measures the subset Measures dataset to only extract Mean and STD columns

combined_activity <- rbind(test_activity, train_activity)
dim(combined_activity)
combined_subject <- rbind(test_subject, train_subject)
dim(combined_subject)
combined_measure <- rbind(test_measure, train_measure)
dim(combined_measure)
head(combined_measure)

# Step 4-1 : Subset the Measure data to only include Mean and Std.


mean_measure <- combined_measure[, grepl("mean", names(combined_measure))]
mean_std <- combined_measure[, grepl("std", names(combined_measure))]

# Step 4-2 : Combine all the data sets 
# create one data frame with all partial data sets:  Activity, Subject, mean_measure and std_measure  

all_data <- cbind(combined_activity, combined_subject, mean_measure, mean_std)
head(all_data, 2)
names(all_data)

# there are some columns with meanFreq in the all_data set, since we want to focus only on Mean and Standard Deviation we will eliminate these columns
all_data <- all_data[, -c(26:28, 32:34,38:40,42, 44,46,48)]

##  Step 5 : Make the Measures columns have descriptive names 

## Make the column headers for Measures more descriptive (less cryptic) - use the gsub function to transform the headers as done below
# From the hints in the README.TXT from the data set we will expand some terms
# Acc: Accelelerometer, Gyro: Gyroscope, Mad = Magnitude, t: time, f: freq 
# Replace duplication BodyBody : Body

names(all_data) <- gsub("^f" ,"freq" , names(all_data))
names(all_data) <- gsub("^t" ,"time" , names(all_data))
names(all_data) <- gsub("Acc" ,"Accelerometer" , names(all_data))
names(all_data) <- gsub("Gyro" ,"Gyroscope" , names(all_data))
names(all_data) <- gsub("Mag" ,"Magnitude" , names(all_data))
names(all_data) <- gsub("BodyBody" ,"Body" , names(all_data))

# Step 6: Make the Activity column readable by using Activity labels  
# The contents of Activity are now 1-5. This needs to be changed to desciptive labels which have been provided in activity_labels.txt
# read in the values and then apply these to the rows in Activity column using the factor() function

# Read in activity_labels.txt

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = F)
head(activity_labels)

# To apply the activity labels to the Activity column, the column needs to be factorized.

all_data$Activity <- factor(all_data$Activity, labels = activity_labels$V2)
head(all_data)

# Step 7: Create the tidy data - analysis on the data which has the average of each variable for each activity and each subject.


# Create the independent tidy data set with the average of each variable (mean and std) for each activity and each subject.
# We need to summarize the averages of the means and std for the activities and the subjects.
# We can melt the data set and then create a tall data set that has activity and subject as the IDs and mean and std as variables. 
# Install reshape2 package to use the melt().

all_data_melt <- melt(all_data, id=c("Activity", "Subject"), measure.var=c(3:68))
head(all_data_melt)
Tidy_data <- dcast(all_data_melt, Activity + Subject ~ variable, mean)
Tidy_data
names(Tidy_data)

# Output the resulting data set (Tidy_data) in to a txt file using the Write.table() function.

write.table(Tidy_data, file = "TidyData_CourseProject.txt", sep = "\t" ,row.names =F)

#### Test that the TidyData_CourseProject.tx file can be read back. Following lines have been commented
# test_read <- read.table("TidyData_CourseProject.txt", header = T)
# head(test_read)

