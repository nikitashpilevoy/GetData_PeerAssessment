require(plyr)
library('plyr')

dating <- function(test = 'test'){
    t <- test
    folder_name <- 'UCI HAR Dataset/'
    Xp <- paste0(folder_name, t, '/X_', t, '.txt')
    yp <- paste0(folder_name, t, '/y_', t, '.txt')
    subj_path <-paste0(folder_name, t, '/subject_', t, '.txt')

    X <- read.table(Xp, header = F)
    y <- read.table(yp, header = F,  sep = ' ')

    subj <- read.table(subj_path, header = F,  sep=' ')
    colnames(subj) <- 'subject'

    x_colnames <-
        read.csv2(paste0(folder_name, 'features.txt'), sep=' ', header = F)

    colnames(X) <- x_colnames[, 2]
    colnames(y) <- 'y'
    
    return(data.frame(y = y, subj = subj, X))
}

test_set <- dating('test')
train_set <- dating('train')
dat <- rbind(test_set, train_set)
dim(dat)
head(dat)


dat_col <- colnames(dat)
idx_mean <- grep('mean[^F]|std', dat_col, ignore.case = T)
dat2 <- dat[, c(1, 2, idx_mean[1:66])]


dat3 <- ddply(dat2, .(subject, y), function(x){
    unlist(lapply(x, mean, na.rm = T))
    })


activity <- read.csv('UCI HAR Dataset/activity_labels.txt',
                     sep = ' ', header = F)
dat3$y <- activity[dat3$y, 2]
colnames(dat3)[1] <- 'activity'
write.csv(dat3, file = 'tidy_SamsungDS_Coursera.csv')


