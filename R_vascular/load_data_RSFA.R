#PURPOSE:Load Data from csv table
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

outImageDir = ''

#---- Load Data ----#
rawD <- read.csv(file.path('csv/univariate_vascular_RSFA.csv'), header=TRUE,sep=",")
df = rawD


# Add age tertile
vTert = quantile(df$Age, c(0:3/3)) #rememebr this is useful for plot_model
df$ageTert = with(df, 
                  cut(Age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))

# Now: plot_ROI.R
