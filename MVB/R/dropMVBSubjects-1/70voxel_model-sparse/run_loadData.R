#PURPOSE: Load MVB summary data into df dataframe
#
#Then use 'df' in the other scripts for:
#- MVB boost (ordinal category codes)
#- MVB multivariate mapping (real vs. shuffled onsets)

library(ggplot2)
library(Hmisc)
library(MASS)
library(reshape2)
library(sfsmisc)
library(sjPlot)
library(BayesFactor)
library(sjmisc)
library(dplyr)
library(tidyverse)
library(broom)
library(Rcpp)
library(stringi)
library(foreign)
library(mdscore)
library(compute.es)
library(pracma)

rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots

options(scipen = 0) #0 = re-enable. Add to ~/.RProfile to set as default.

#---- Setup ----#
wd = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(wd)

rawDir = "csv"
outImageDir = 'images'
dir.create(outImageDir)


#---- Load Data ----#
rawD <- read.csv(file.path(rawDir,'data.csv'), header=TRUE,sep=",")
df = rawD

#---- Transform some stuff ----#
#Age quadratic expansion
df$age0z2 <- scale(poly(scale(df$age),2)) #1st linear, 2nd quad
#make variablers factors
df$ordy <- as.factor(df$ordy) #Check it worked: sapply(df, class)

#---- assign subs a tertile age group in df$tert ----#
#https://stackoverflow.com/questions/62574146/how-to-create-tertile-in-r

# Find tertiles
vTert = quantile(df$age, c(0:3/3)) #rememebr this is useful for plot_model

df$ageTert = with(df, 
                  cut(age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))

## RUN ANALYSES:
# run_fMRI_spread.R
# run_fMRI_MVB.R
# run_fMRI_MVB_predict_Behaviour.R