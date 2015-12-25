# CodeBook for _Getting and Cleaning Data_ assignment

This is the CodeBook explaining the steps of the _run\_analysis.R_ file from the programming assignment given by the Coursera course _Getting and Cleaning Data_.

## Prerequisites

1. The folder with Samsung sets  contained in this [zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
must be unzipped in the work directory.

2. The package *plyr* need to be installed. It can be done with the following command: `install.packages('plyr')`.

## R Setup

As previously said, the *plyr* package has to be loaded.

The *gather\_data* function has been created to avoid duplication of code when loading the data in *R*. It requires a string (test or train) and looks for the corresponding *X, y, subject* data sets in the data folder, loads and adds the column names and finally *cbind* them together.


```r
require(plyr)
```

```
## Loading required package: plyr
```

```r
library("plyr")  # faster with data.table...

gather_data <- function(test_or_train = "test") {
    ### Merge X and Y from folder_path Argument is test or train The purpose of
    ### this function is to avoid repetition in the code
    tt <- test_or_train
    folder_name <- "UCI HAR Dataset/"
    X_path <- paste0(folder_name, tt, "/X_", tt, ".txt")
    y_path <- paste0(folder_name, tt, "/y_", tt, ".txt")
    subject_path <- paste0(folder_name, tt, "/subject_", tt, ".txt")
    
    X <- read.table(X_path, header = F)
    y <- read.table(y_path, header = F, sep = " ")
    
    subject <- read.table(subject_path, header = F, sep = " ")
    colnames(subject) <- "subject"
    
    x_colnames <- read.csv2(paste0(folder_name, "features.txt"), sep = " ", 
        header = F)
    
    colnames(X) <- x_colnames[, 2]
    colnames(y) <- "y"
    
    return(data.frame(y = y, subject = subject, X))
}
```


## Assignment

### Point 1)
Thanks to the function gather data, appending the test and train sets are three lines. The data.frame _dat_ is the result of the function _rbind_.


```r
test_set <- gather_data("test")
train_set <- gather_data("train")
dat <- rbind(test_set, train_set)
dim(dat)
```

```
## [1] 10299   563
```

```r
print(dat[1:6, 1:4])
```

```
##   y subject tBodyAcc.mean...X tBodyAcc.mean...Y
## 1 5       2            0.2572          -0.02329
## 2 5       2            0.2860          -0.01316
## 3 5       2            0.2755          -0.02605
## 4 5       2            0.2703          -0.03261
## 5 5       2            0.2748          -0.02785
## 6 5       2            0.2792          -0.01862
```


### Point 2)
In order to extract only the mean and standard devation for each measured feature, the *grep* function has been used on the column names of the *dat* data.frame with a regex pattern including "mean" (not followed by the letter F to avoid _meanFreq_) or "std". The resulting vector is then truncated to ignore the angle feature. Finally, a second data.frame _dat2_ is created by subsetting _dat_.


```r
dat_col <- colnames(dat)
idx_mean <- grep("mean[^F]|std", dat_col, ignore.case = T)
dat2 <- dat[, c(1, 2, idx_mean[1:66])]  ### ignore the angle features
```


### Point 5) 
It is easier to perfrom task _5_ before *3* and *4*, because of *ddply* that has strange behavior with factors.

Using the *ddply* function, the data set can be split with the two variables *subject, y* and apply the mean function to each column of the split _data.frame_.


```r
dat3 <- ddply(dat2, .(subject, y), function(x) {
    unlist(lapply(x, mean, na.rm = T))
})
```


### Point 3) and 4)
The response label is transformed to something humanly readable. The activity labels from the file _activity\_labels.txt_ were used.


```r
activity <- read.csv("UCI HAR Dataset/activity_labels.txt", sep = " ", header = F)
dat3$y <- activity[dat3$y, 2]
colnames(dat3)[1] <- "activity"
```


### Point 5) bis: Saving the file
We save the data set into the file with the following command.

```r
write.csv(dat3, file = "tidy_SamsungDS_Coursera.csv")
```


## Conclusion
The Samsung data set has been filtered and a tidy data set has been created from it.
