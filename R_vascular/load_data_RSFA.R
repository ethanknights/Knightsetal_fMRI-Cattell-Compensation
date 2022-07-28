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
library(grid)
rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots


#---- Setup ----#
# wd <- "/imaging/ek03/MVB/FreeSelection/MVB/R"
wd = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(wd)

rawDir = 'csv'
outImageDir = 'images'
dir.create(outImageDir,showWarnings = FALSE)

pxheight = 600
pxwidth = 800


#---- Load Data ----#
rawD <- read.csv(file.path(rawDir,'univariate_vascular_RSFA.csv'), header=TRUE, sep=",")
df = rawD


#---- Tertile ----#
vTert = quantile(df$Age, c(0:3/3))
df$ageTert = with(df, 
                  cut(Age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))

# Now: plot_ROI.R
