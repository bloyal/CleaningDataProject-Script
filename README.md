---
title: "README"
author: "Brian Loyal"
---

*run_analysis.R* summarizes smartphone accelerometer and gyroscope data collected from 30 individuals. To perform the anaylsis, update the hard-coded paths to the data set and run the script as:

```
run_analysis()
```

The script will then extract the raw data from the dataset folder and export the summarized results to a file named "summarizedData.txt". 

The script follows these steps to perform the analysis:

1. The *loadData* function takes in a vector of paths to the source data and uses read.file to load them into a list.
2. The *getFeatureNames* function takes in the path to the features.txt file and saves the feature names to a vector.
3. The *getActivityNames* function takes in the path to the activity_labels.txt file and saves the activity keys and names to a 6 x 2 data frame. This will be used as a lookup table for the merge later on.
4. The *combineDataSet* function takes in the raw data list from step #1 and the feature name vector from step #2 and uses them to organize the test and training data set into a single, large dataframe. Each row of this dataframe represents a single observation, is labeled with the subject ID (column 1) and the activity ID (column 2), and contains 561 feature values.
5. The *selectMeanAndStdData* function uses a column name grep to limit the dataset to only the mean and std value features. It exludes the meanFreq features.
6. The *labelActivities* function uses the merge() command to perform an inner join between the extracted mean and standard deviation data obtained in step #5 with the activity lookup table from step #3. 
7. The *summarizeData* function takes in the labeled mean and standard deviation data from step #6 and summarizes it into a tidy, wide data set. This provides the average value of each of the extracted measurements by subject ID and activty name. The resulting columns are renamed by appending "avg- " to the front of each one.
8. The tidy dataset is saved as a .txt file in the working  directory.