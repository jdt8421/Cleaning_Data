
filename = "dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

library(reshape2)

# Load activity labels + features
activity.label = read.table("UCI HAR Dataset/activity_labels.txt")
activity.label[,2] = as.character(activity.label[,2])
features = read.table("UCI HAR Dataset/features.txt")
features[,2] = as.character(features[,2])

# Extract the features with either mean and standard deviation in the name
# Process the names from the features wanted

features.wanted = grep(".*mean.*|.*std.*", features[,2])
features.wanted.names = features[features.wanted,2]

## clean up the names
features.wanted.names = gsub('-mean', 'Mean', features.wanted.names)
features.wanted.names = gsub('-std', 'Std', features.wanted.names)
features.wanted.names = gsub('[-()]', '', features.wanted.names)

# Load the datasets
train = read.table("UCI HAR Dataset/train/X_train.txt")[features.wanted] #select only the features wanted
train.activities = read.table("UCI HAR Dataset/train/Y_train.txt")
train.subjects = read.table("UCI HAR Dataset/train/subject_train.txt")
train = cbind(train.subjects, train.activities, train) #merge the data together

test = read.table("UCI HAR Dataset/test/X_test.txt")[features.wanted] #select only the features wanted
test.activities = read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects = read.table("UCI HAR Dataset/test/subject_test.txt")
test = cbind(testSubjects, test.activities, test) #merge the data together

# merge datasets and add labels
merged.data = rbind(train, test)
colnames(merged.data) = c("subject", "activity", features.wanted.names)

# turn activities & subjects into factors
merged.data$activity = factor(merged.data$activity, levels = activity.label[,1], labels = activity.label[,2])
merged.data$subject = as.factor(merged.data$subject)

merged.data.melted = melt(merged.data, id = c("subject", "activity"))
merged.data.mean = dcast(merged.data.melted, subject + activity ~ variable, mean)

write.table(merged.data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)