rm(list=ls()) #clears variables
dev.off() #clears all plots

library(dplyr)
library(ggplot2)
library(data.table)
library(plyr)

#################
## Set Up Data ##
#################
getwd()
setwd("/Users/hallehghaemi/Desktop/Question4_baserunning_data")

altuve<- read.csv(
  "/Users/hallehghaemi/Desktop/Question4_baserunning_data/Altuve_baserunning.csv", 
  header = T)
altuve<- altuve %>%
  group_by(sv_pitch_id) %>%
  filter(time_offset > 0) %>% select(sv_pitch_id, time_offset, x, y)

trout<- read.csv(
  "/Users/hallehghaemi/Desktop/Question4_baserunning_data/Trout_baserunning.csv", 
  header = T)
trout<- trout %>%
  group_by(sv_pitch_id) %>%
  filter(time_offset > 0) %>% select(sv_pitch_id, time_offset, x, y)

#####################
## Calculate Speed ##
#####################
#ALTUVE
time.altuve<-diff(altuve$time_offset) 
x.altuve<-diff(altuve$x)^2
y.altuve<-diff(altuve$y)^2
distance.altuve<-sqrt(x.altuve + y.altuve)
speed.altuve<-distance.altuve/time.altuve #Speed calculation

speed.altuve<-na.omit(speed.altuve) #Remove NA's
speed.altuve<-speed.altuve[ speed.altuve != 0] #Remove 0's
speed.altuve<-speed.altuve[ speed.altuve > 0] #Remove Negative Values
outlier_values.altuve <- boxplot.stats(speed.altuve)$out #Remove Outliers
speed.altuve <- subset(speed.altuve, !(speed.altuve %in% outlier_values.altuve))

#TROUT
time.trout<-diff(trout$time_offset) 
x.trout<-diff(trout$x)^2
y.trout<-diff(trout$y)^2
distance.trout<-sqrt(x.trout + y.trout)
speed.trout<-distance.trout/time.trout #Speed calculation

speed.trout<-na.omit(speed.trout) #Remove NA's
speed.trout<-speed.trout[ speed.trout != 0] #Remove 0's
speed.trout<-speed.trout[ speed.trout > 0] #Remove Negative Values
outlier_values.trout <- boxplot.stats(speed.trout)$out #Remove Outliers
speed.trout <- subset(speed.trout, !(speed.trout %in% outlier_values.trout))

########################
## Stats & Data Frame ##
########################
max.altuve<-max(speed.altuve) 
a.altuve<-mean(speed.altuve)
s.altuve<-sd(speed.altuve)
n.altuve<-length(speed.altuve)
error<- qnorm(0.975)*s.altuve/sqrt(n.altuve)
left.altuve<-a.altuve - error
right.altuve<- a.altuve + error
CI.altuve<-c(left.altuve, right.altuve)
median.altuve<-median(speed.altuve)

max.trout<-max(speed.trout) 
a.trout<-mean(speed.trout)
s.trout<-sd(speed.trout)
n.trout<-length(speed.trout)
error.trout<- qnorm(0.975)*s.trout/sqrt(n.trout)
left.trout<-a.trout - error.trout
right.trout<- a.trout + error.trout
CI.trout<-c(left.trout, right.trout)
median.trout<-median(speed.trout)

#Mode Analysis
Mode<- function(x){
  ux<-unique(x)
  ux[which.max(tabulate(match(x, ux
  )))]
}
mode.altuve<- Mode(speed.altuve[which(speed.altuve >7 )])
mode.trout<- Mode(speed.trout[which(speed.trout > 7 )])

freq.table.altuve<- data.frame(table(speed.altuve))
freq.table.trout<-data.frame(table(speed.trout))
freq.mode.altuve<-sum(freq.table.altuve$Freq[55974:55984])
freq.mode.trout<-sum(freq.table.trout$Freq[71257:71267])

#Final Stats
Altuve.Stats<-c(max.altuve, a.altuve, s.altuve, left.altuve, 
                right.altuve, mode.altuve, freq.mode.altuve, median.altuve)
Stat.Type<-c('Max Speed', 'Average Speed', 'Standard Deviation of Speeds', 
             'Lower Confidence Interval', 'Upper Confidence Interval', 
             'Mode Speed > 7 ft/sec', 'Frequency of Mode Value', 'Medians' )
Trout.Stats<-c(max.trout, a.trout, s.trout, left.trout, 
               right.trout, mode.trout, freq.mode.trout, median.trout)
TroutAltuve.Data<-data.frame(Stat.Type, Altuve.Stats, Trout.Stats)
TroutAltuve.Data

#T-test measuring if there is a difference between the means
t.test(speed.altuve, speed.trout)

################
## Histograms ##
################
qplot(speed.altuve,
      geom = "histogram", 
      binwidth = 0.5, 
      main = "Histogram of Altuve's Speed",
      xlab = "Speed in Feet Per Second",
      fill = I("dark blue"),
      col = I("orange"),
      xlim = c(0,33))
qplot(speed.trout,
      geom = "histogram", 
      binwidth = 0.5, 
      main = "Histogram of Trout's Speed",
      xlab = "Speed in Feet Per Second",
      fill = I("red"),
      col = I("white"),
      xlim = c(0,33))
