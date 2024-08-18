#---------- MVB Mapping (Shuffled GroupFVals) ---------#
source("R_rainclouds.R") ## Retrieve from: https://github.com/RainCloudPlots/RainCloudPlots/blob/master/tutorial_R/R_rainclouds.R

extraData <- read.csv(file.path(rawDir,"extradata_ShuffledGroupFVals.csv"), header=TRUE,sep=",")
t = t.test(extraData$Log, alternative = 'greater', mu = 3)
group = rep(1,nrow(extraData))
extradf = cbind(extraData,group)
extradf$Gender = df_univariate$Gender

t$statistic/ sqrt(nrow(df)) #cohenD
#  ES.t.one( t = t$statistic, df = t$parameter, alternative = 'one.sided' )    #doublecheck cohenD

ggplot(extradf,aes(x=group,y=Log)) +
  geom_flat_violin(position = position_nudge(x = .2, y = 0),adjust =2,alpha=.5,size=1.5, fill = 'sienna4') +
  geom_point(position = position_jitter(width = .15), shape = 21, size = 3, colour = "black", fill = 'sienna4', stroke = 2) +
#  geom_hline(yintercept = 0, linetype = "dotted", color = 'black', size = 1.5) + #baseline (real vs shuffled)
  geom_hline(yintercept = 3, linetype = "longdash", color = 'black', size = 1.5) + #bayesian hypothesised mean test
  theme_bw() +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), legend.position = "none",panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black", size = 1), axis.ticks = element_line(colour = "black", size = 1), text = element_text(size=24),
        axis.text.x = element_blank(),axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.line.x = element_blank()) + # remove y axis
  scale_y_continuous(breaks = round(seq(0, max(100), by = 25),1), expand = c(0.025,0.025), limits = c(-5,105))
ggsave(file.path(outImageDir,'control-frontalROI_shuffledMVB.png'),
       width = 15, height = 15, units = 'cm', dpi = 300)


#----- check relationship with age -----%
# extradf$age0z = df$age

extradf$probGreater3 = as.factor(extradf$Log >= 3)

lm(probGreater3 ~ age,
   data = extradf)

# Drop poor decoding subjects as in MVN analyses
extradf <- extradf[extradf$probGreater3 == TRUE, ]

# #-- 1. does probablity of >3 change with age? --#
# model <- glm(formula = probGreater3  ~ age, 
#              family = binomial(logit), data = extradf)
# summary(model)
# #Get Odds ratio
# exp(coef(model))
# ci<-confint(model)
# OR <- exp(cbind(OR = coef(model), ci)); OR
# 
# #Plot scatter
# plot(extradf$age,extradf$probGreater3)
# extradf$age
# extradf$probGreater3

#Plot - geom_density
# ggplot(extradf, aes(age, fill = probGreater3)) + 
#   geom_density(position='fill', alpha = 0.75,color="white", kernel = 'cosine')


# --- add Log ~ Age approach for reviewer comment re. lenient multivariate
# functional compensation criteria where an ROI could simply carry task-related
# information (not necessarily beyond MDN task-relevant network) --- #

lm_model <- lm(scale(Log) ~ scale(age) + scale(Gender),
               data = extradf); summary(lm_model)

p <- ggplot(extradf, aes(x = age, y = Log)) +
  geom_point(shape = 21, size = 3, colour = 'black', fill = 'sienna4', stroke = 1.25) + 
  geom_smooth(method = 'lm', se = TRUE, colour = 'sienna4', size = 2) +
  ylim(-5, 110) + 
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20), 1), limits = c(15, 90)) +
  theme_bw() + 
  theme(
    panel.border = element_blank(), 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    legend.position = 'none',
    axis.line = element_line(colour = "black", size = 2), 
    axis.ticks = element_line(colour = "black", size = 2),
    text = element_text(size = 24)
  ); p
ggsave(file.path(outImageDir,'frontalROI_Log~Age.png'),
       width = 25, height = 25, units = 'cm', dpi = 300)