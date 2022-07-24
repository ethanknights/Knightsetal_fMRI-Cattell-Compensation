#PURPOSE:
#
#Load Data from csv table
#==================================================================
library(sjPlot)
library(MASS)
library(ggplot2)
library(BayesFactor)
library(dplyr)
library(tidyverse)
library(reshape2)
library(ggeffects)
rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots


#---- Setup ----#
# wd <- "/imaging/ek03/MVB/FreeSelection/MVB/R"
wd = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(wd)

rawDir = "csv"
outImageDir = 'images'
dir.create(outImageDir,showWarnings = FALSE)

#---- Load Data ----#
rawD <- read.csv(file.path(rawDir,'univariate.csv'), header=TRUE,sep=",")
df = rawD

#---- Transform some stuff ----#
# df$age_scale = scale(df$Age)
# df$bhv_scale = scale(df$bhv)
# df$bhv_OutOfScanner_scale = scale(df$bhv_outOfScanner)
# df$STW_scale = scale(df$STW)
# df$lSPOC_scale = scale(df$lSPOC)
# df$rMFG_scale = scale(df$rMFG)
# #extra
# df$GenderNum = scale(df$Gender)
# df$handedness = scale(df$handedness)
# df$ageQuad_scale<- poly(df$age_scale,2) #1st linear, 2nd quad


#---- assign subs a tertile age group in df$tert ----#
#https://stackoverflow.com/questions/62574146/how-to-create-tertile-in-r

# Find tertiles
vTert = quantile(df$Age, c(0:3/3)) #rememebr this is useful for plot_model

df$ageTert = with(df, 
                  cut(Age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))
write.csv(df,'T_outputfromR_withAgeTert.csv')

# df_long  <- df %>% gather(CCID,Age, bhv)
# head(long_DF, 24)  # note, for brevity, I only show the data for the first two years 
# 
# 

#---- Run Analyses (manually) ----#
#- plot_bhv.R 
#- plot_ROI.R
#- descriptives.R