
rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots

#Firt load behavioural data 
df_bhv = read.csv('/imaging/camcan/sandbox/ek03/projects/cattellComp/linkToKT/R/csv/T.csv')
df_MVB = read.csv('csv/data.csv')

df <- inner_join(df_bhv, df_MVB, by="CCID")
df$age0z2 <- scale(poly(scale(df$age),2)) #1st linear, 2nd quad

#add ageTert
vTert = quantile(df$age, c(0:3/3)) #rememebr this is useful for plot_model
df$ageTert = with(df, 
                  cut(age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))

df_subset <- df[which(df$idx_couldNotDecode==0), ]

unique(df_subset$ordy)


#df$ordy <- as.factor(df$ordy) %stops plots!

#ORIGINAL MODEL: ENSURE AGE EFFECT:
# model <- glm(formula = ordy ~ scale(age0z2) * scale(GenderNum),
#              family = binomial(logit), data = df); summary(model)



# Try plot Boost ~ Age * Bhv to mirror univariate interaction (not reproted)
#=====================================================================================

model <- glm(formula = as.factor(ordy) ~ scale(age) * scale(bhv),
             family = binomial(), data = df_subset); summary(model)

## Get Bayes Factor
# Libraries
library(brms)
library(polspline)

# Set seed
set.seed(20210209)

df2 <- data.frame(df_subset$ordy, scale(df_subset$age), scale(df_subset$bhv))
names(df2) <- c("y","s_x",'s_x2')


# Priors
priors_student_1  <- c(prior(student_t(7, 0, 10) , class = "Intercept"),
                       prior(student_t(7, 0, 1) , class = "b")) 

# Fit BRMS model
baseModel_student_1 <- brm(y ~ s_x + s_x2,
                           data = df2,
                           prior = priors_student_1,
                           family = bernoulli(),
                           chains = 8,
                           save_all_pars = TRUE,
                           sample_prior = TRUE,
                           save_dso = TRUE, 
                           seed = 6353) 


# Extract posterior distribution to calculate BF
postDist_slope <- posterior_samples(baseModel_student_1)$b_s_x2

# Get prior density
priorDensity <- dstudent_t(0, 7, 0, 1) # I calculate this instead of using the sampled prior dists

# Calculate BF manually
fit.posterior  <- logspline(postDist_slope)
posterior      <- dlogspline(0, fit.posterior) 
prior          <- priorDensity # Precalculated density
bf             <- prior/posterior # Getting savage dickey ratio

# Calculate OR (order-restricted aka two-tailed) BF manually 
areaPosterior <- sum(postDist_slope > 0)/length(postDist_slope)
posterior.OR  <- posterior/areaPosterior  # Divide by the cut-off area to ensure that dist sums to 1
prior.OR      <- prior/0.5 # Divide by 0.5 to ensure that the prior sums to 1
bf_OR         <- prior.OR/posterior.OR # Getting savage dickey ratio

# Print results
cat(paste("Two-tailed BF10 =", round(bf), "\nOne-tailed BF10 =", round(bf_OR)))


#EK: get BF01 (one-tailed for > 0)
bf01 <- 1 / bf_OR
bf01




lm_model <- lm(bhv ~ as.factor(ordy) * Age ,
               data = df); summary(lm_model)
# p = plot_model(lm_model, type = "pred", terms = c("as.factor(ordy)", "Age [18, 54, 88]"), show.data = TRUE); p # vTert


lm_model <- lm(bhv ~ ordy * Age ,
               data = df); summary(lm_model)
p = plot_model(lm_model, type = "pred", terms = c("ordy", "Age [18, 54, 88]"), show.data = TRUE); p # vTert
#formatting
p <- p +
  ylim(0,60) +
  xlim(1,2) +
  scale_x_continuous(breaks = round(seq(1, max(2), by = 1),1),
                     limits = c(1,2)) +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line =
          element_line(colour = "black",size = 1.5),
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24)); p
ggsave(file.path('images',"lSPOC_MVB-bhv.png"),
       width = 25, height = 25, units = 'cm', dpi = 300)
# #hack plot
qq <- ggplot_build(p)
# #hack plot - scatter
qq$data[[1]]$shape <- o
qq$data[[1]]$size <- 2.5
qq$data[[1]]$stroke <- 1
qq$data[[1]]$alpha <- 0.5
qq$data[[1]]$colour[df$ageTert == 'YA'] = 'olivedrab'
qq$data[[1]]$colour[df$ageTert == 'ML'] = 'darkturquoise'
qq$data[[1]]$colour[df$ageTert == 'OA'] = 'dodgerblue3'
# #hack plot - regression line
qq$data[[2]]$size <- 2.5
qq$data[[2]]$colour[1:2] = 'olivedrab'
qq$data[[2]]$colour[3:4] = 'darkturquoise'
qq$data[[2]]$colour[5:6] = 'dodgerblue3'
# #hack plot - CI shaded
qq$data[[3]]$alpha <- 0.2
qq$data[[3]]$fill[1:2] = 'olivedrab'
qq$data[[3]]$fill[3:4] = 'darkturquoise'
qq$data[[3]]$fill[5:6] = 'dodgerblue3'
plot(ggplot_gtable(qq))

#Predict log-evidence from behaviour (age tert split)
#======================================================================


model <- lm(formula = groupFvals ~ scale(age) * scale(bhv),
            data = df_subset); summary(model)

#Plot it (non-scaled)
model <- lm(groupFvals ~ age * bhv,
            data = df_subset); summary(model)
p = plot_model(model, type = "pred", terms = c("bhv", "age [18, 54, 88]"), show.data = TRUE); p # vTert
#formatting
p <- p +
  #ylim(0,60) +
  #xlim(1,2) +
  #scale_x_continuous(breaks = round(seq(1, max(2), by = 1),1),
  #                   limits = c(1,2)) +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "right",
        panel.grid.minor = element_blank(),
        axis.line =
          element_line(colour = "black",size = 1.5),
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24)); p
# #hack plot
qq <- ggplot_build(p)
# #hack plot - scatter
qq$data[[1]]$shape <- o
qq$data[[1]]$size <- 2.5
qq$data[[1]]$stroke <- 1
qq$data[[1]]$alpha <- 0.5
qq$data[[1]]$colour[df$ageTert == 'YA'] = 'olivedrab'
qq$data[[1]]$colour[df$ageTert == 'ML'] = 'darkturquoise'
qq$data[[1]]$colour[df$ageTert == 'OA'] = 'dodgerblue3'
# #hack plot - regression line
qq$data[[2]]$size <- 2.5
qq$data[[2]]$colour[1:7] = 'olivedrab'
qq$data[[2]]$colour[8:14] = 'darkturquoise'
qq$data[[2]]$colour[15:21] = 'dodgerblue3'
# #hack plot - CI shaded
qq$data[[3]]$alpha <- 0.2
qq$data[[3]]$fill[1:7] = 'olivedrab'
qq$data[[3]]$fill[8:14] = 'darkturquoise'
qq$data[[3]]$fill[15:21] = 'dodgerblue3'
plot(ggplot_gtable(qq))




#Predict behaviour (age tert split)
#======================================================================
# lm_model <- lm(as.factor(ordy) ~ Age * bhv,
#                data = df); summary(lm_model)
# p = plot_model(lm_model, type = "pred", terms = c("as.factor(ordy)", "Age [18, 54, 88]"), show.data = TRUE); p # vTert


lm_model <- lm(ordy ~ Age * bhv,
               data = df); summary(lm_model)
p = plot_model(lm_model, type = "pred", terms = c("bhv", "Age [18, 54, 88]"), show.data = TRUE); p # vTert
#formatting
p <- p +
  #ylim(0,60) +
  #xlim(1,2) +
  #scale_x_continuous(breaks = round(seq(1, max(2), by = 1),1),
  #                   limits = c(1,2)) +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "right",
        panel.grid.minor = element_blank(),
        axis.line =
          element_line(colour = "black",size = 1.5),
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24)); p
ggsave(file.path('images',"lSPOC_MVB-bhvInteraction.png"),
       width = 25, height = 25, units = 'cm', dpi = 300)
# #hack plot
qq <- ggplot_build(p)
# #hack plot - scatter
qq$data[[1]]$shape <- o
qq$data[[1]]$size <- 2.5
qq$data[[1]]$stroke <- 1
qq$data[[1]]$alpha <- 0.5
qq$data[[1]]$colour[df$ageTert == 'YA'] = 'olivedrab'
qq$data[[1]]$colour[df$ageTert == 'ML'] = 'darkturquoise'
qq$data[[1]]$colour[df$ageTert == 'OA'] = 'dodgerblue3'
# #hack plot - regression line
qq$data[[2]]$size <- 2.5
qq$data[[2]]$colour[1:2] = 'olivedrab'
qq$data[[2]]$colour[3:4] = 'darkturquoise'
qq$data[[2]]$colour[5:6] = 'dodgerblue3'
# #hack plot - CI shaded
qq$data[[3]]$alpha <- 0.2
qq$data[[3]]$fill[1:2] = 'olivedrab'
qq$data[[3]]$fill[3:4] = 'darkturquoise'
qq$data[[3]]$fill[5:6] = 'dodgerblue3'
plot(ggplot_gtable(qq))







# #Old stuff
# #======================================================================
# 
# #New models: Cuneal Boost predicts worse performance
# lm_model <- lm(bhv ~ as.factor(ordy),
#                data = df); summary(lm_model)
# #p <- ggplot(df, aes(y = bhv, x = as.factor(ordy)))
# p <- ggplot(df, aes(y = bhv, x = ordy))
# p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
# p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
# #formatting
# p <- p + #xlim() + #ylim(0,400) +
#   theme_bw() + theme(panel.border = element_blank(), legend.position = "none",text = element_text(size=14),
#                      panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black",size = 1.5),axis.ticks = element_line(colour = "black", size = 1.5))
# ggsave(file.path('images',"BhvPredictedByBoost.png"), width = 25, height = 25, units = 'cm', dpi = 300); p
# 
# 
# #New models: Though likely driven by age effect, as dissapears if controlling for age
# lm_model <- lm(bhv ~ as.factor(ordy) + age0z2,
#                data = df); summary(lm_model)
# 
# 
# 
# #Is mean activation positive in Mid/Old adults who show a boost? Eye movement explanation would predict yes.
# tmpDF <- df[with(df, ageTert == 'ML' | ageTert == 'OA'),]
# tmpDF <- tmpDF[with(tmpDF, ordy == '2'),]
# 
# mean(tmpDF$lSPOC)
# p <- ggplot(tmpDF, aes(y = lSPOC, x = age))
# p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
# p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3); p
# 
# 
# #Old adult only..
# tmpDF <- df[with(df, ageTert == 'ML'),]
# tmpDF <- tmpDF[with(tmpDF, ordy == '2'),]
# 
# mean(tmpDF$lSPOC)
# p <- ggplot(tmpDF, aes(y = lSPOC, x = age))
# p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
# p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3); p
# 
# 
# 
# 
# 
