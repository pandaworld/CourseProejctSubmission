===============================================================  

## Course Project for Getting and Cleaning Data 
### Dilip Soman - 25 july 2015
## Tidy Data analysis from:
##Summary of Human  Recognition Using Smartphones Dataset
##Version 1.0 from 
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Universit‡ degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws
================================================================== 

#Background: 

The objective of the project is to create a tidy data set from raw data that is downloaded from following url: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The raw data set linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The project requires that a R Script, run_analysis.R is used to perform the following transformations to the raw data set:

1) Merges the training and the test sets to create one data set.
2) Extracts only the measurements on the mean and standard deviation for each measurement. 
3) Uses descriptive activity names to name the activities in the data set
4) Appropriately labels the data set with descriptive variable names. 
5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.(


# Description of files being submitted :

1) TidyData_CourseProject.txt    - this file contains the average of means and std for each activity and each subject 
2) CodeBook.md - the codebook describes the fields and variable s contained in the TidyData_CourseProject.txt and additional information of the source data.
3) run_analysis.R - script file that was used to transform the raw data (UCI HAR Dataset.zip) to the TidyData_CourseProject.txt
4) readme.txt (this file)  - description of steps performed to transform the data

# How was the data transformed

## Introduction: 

I used R Studio to create a script file called run_analysis.R to produce the tidy data set from the raw data set derived from the following repository: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

Note: The script includes steps to download the zipped source data set from the url. However, since the assigment assumes that the data file will be 
in the working directory, these steps are commented out in the submitted script. 
This script assumes that the data has been downloaded and is available in the working directory. The script will unzip the file and perform the steps as described in comments to product the tidy data set of averages for means and standard deviations in the raw data set for each activity and each subject.

## Step 1: Download raw data set using url and unzip into working directory
This step is only performed once to bring down the data. 
As such it will be commented in the script, and will assume that the data is already available in the working directory. 

  unzip("UCI HAR Dataset.zip")

## Step 2: Examine the files
I reviewed the raw data set and determine which files are needed to produce the tidy data set required for the course project. The focus of the assignement is on the "mean" and "standard deviation"(std) variables. The mean and std data is within the files in the test and train folders (not the Inertial Signals sub-folders.)

The folder UCI HAR Dataset contains 4 files which describe the data set and 2 folders, "test" and "train".
  The "test" and "train" folders each contain 3 files: subject_test.txt, X_????.txt, Y_????.txt (where ???? = test or train) and a folder Inertial Signals.    
  The Inertial Signal folders contain raw data collected from smart phones. 

I reviewed the README.txt and checking the diamension of the files to determine how to merge the files.  

 "Subject" files contain the Subject (1-30) data
 "Y" files contain Activity (1-6) data 
 "X" files contains variable Measurements data

The approach taken was to combine the respective files (Subject, Y and X) from test and train folders. 
The data frame with the Measurements (X) file was subsetted to include mean and std data. Additional cleanup was performed as well. 
Then the Activity, Subject and Measure data frames were combined. 
Details of steps performed follow. 

## Step 3: Read in the data and Add column headings 

Read the files in "test" folder into data frames, no headers in the files.  Assign column headers.

  test_activity <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = F)           
  names(test_activity) <- c("Activity")                                                  
  test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = F)
  names(test_subject) <- c("Subject")                                              
  test_measure <- read.table("./UCI HAR Dataset/test/X_test.txt", header = F)      

Read the 561 column names from the features.txt file so that we can apply the variables to the measurement column names for the data frame

  measure_headers <- read.table("UCI HAR Dataset/features.txt", header = F)
  names(test_measure) <- measure_headers$V2

Read the files in "train" folder into data frames, no headers in the files.  

  train_activity <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = F) 
  names(train_activity) <- c("Activity")                                          
  train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = F)
  names(train_subject) <- c("Subject")  
  train_measure <- read.table("./UCI HAR Dataset/train/X_train.txt", header = F) 
  names(train_measure) <- measure_headers$V2                                     

## Step 4 :  Combine the data sets 

Combined data sets from test and train dataset for Activity, Subject and Measures the subset Measures dataset to only extract Mean and STD columns

  combined_activity <- rbind(test_activity, train_activity)
  combined_subject <- rbind(test_subject, train_subject)
  combined_measure <- rbind(test_measure, train_measure)

## Step 4-1 : Subset the Measure data to only include Mean and Std.

We only need the mean and std variables. So I used the grepl() function to subset the column headers which contain either "mean"" or "std". 

  mean_measure <- combined_measure[, grepl("mean", names(combined_measure))]
  mean_std <- combined_measure[, grepl("std", names(combined_measure))]

This still results in some columns with "mean"" still included. These are removed later. 

## Step 4-2 : Combine all the data sets 

Create one data frame with all partial data sets:  Activity, Subject, mean_measure and std_measure  using cbind. 

  all_data <- cbind(combined_activity, combined_subject, mean_measure, mean_std)

There are some columns with "meanFreq"" in the all_data set. These are not considered mean or std for this exercise. These are removed as follows: 
  
  all_data <- all_data[, -c(26:28, 32:34,38:40,42, 44,46,48)]

##  Step 5 : Make the Measures columns have descriptive names 

Make the column headers for Measures variables more descriptive (less cryptic) - use the gsub function to transform the headers as done below.
From the hints in the README.TXT from the data set expand some of the terms:
 Acc: Accelelerometer, Gyro: Gyroscope, Mad = Magnitude, t: time, f: freq 
 Replace duplication BodyBody : Body

  names(all_data) <- gsub("^f" ,"freq" , names(all_data))
  names(all_data) <- gsub("^t" ,"time" , names(all_data))
  names(all_data) <- gsub("Acc" ,"Accelerometer" , names(all_data))
  names(all_data) <- gsub("Gyro" ,"Gyroscope" , names(all_data))
  names(all_data) <- gsub("Mag" ,"Magnitude" , names(all_data))
  names(all_data) <- gsub("BodyBody" ,"Body" , names(all_data))

## Step 6: Make the Activity column readable by using Activity labels  
 The contents of Activity are now 1-5. This needs to be changed to desciptive labels which have been provided in activity_labels.txt
 read in the values and then apply these to the rows in Activity column using the factor() function

 Read in activity_labels.txt

  activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = F)

 To apply the activity labels to the Activity column, the column needs to be factorized.

  all_data$Activity <- factor(all_data$Activity, labels = activity_labels$V2)

## Step 7: Create the tidy data - analysis on the data which has the average of each variable for each activity and each subject.


Create the independent tidy data set with the average of each variable (mean and std) for each activity and each subject.
Need to summarize the averages of the means and std for the activities and the subjects.
Melt the data set and then create a tall data set that has activity and subject as the IDs and mean and std as variables. 


  all_data_melt <- melt(all_data, id=c("Activity", "Subject"), measure.var=c(3:68))
  Tidy_data <- dcast(all_data_melt, Activity + Subject ~ variable, mean)
  Tidy_data

Output the resulting data set (Tidy_data) in to a txt file using the Write.table() function.

  write.table(Tidy_data, file = "TidyData_CourseProject.txt", sep = "\t" ,row.names =F)

Verify that the results are correct by reading the data back into R. 
Test that the TidyData_CourseProject.tx file can be read back. Following lines have been commented in the script. 
 test_read <- read.table("TidyData_CourseProject.txt", header = T)
 head(test_read)

