options(scipen = 999)

# df$Age_scale = as.numeric(scale(df$Age))
# df$bhv_scale = as.numeric(scale(df$bhv))
# df$Gender_scale = as.numeric(scale(df$Gender))
# df$handedness_scale = as.numeric(scale(df$handedness))
# df$lSPOC_scale = as.numeric(scale(df$lSPOC))
# df$rMFG_scale = as.numeric(scale(df$rMFG))


lm_model <- lm(scale(lSPOC) ~ scale(Age) * scale(bhv) + scale(Gender),
               data = df); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path('RSFA_regression_bhv.csv'))

#Plot with fit (but no data points scatter)
lm_model <- lm(lSPOC ~ Age * bhv + Gender,
               data = df); summary(lm_model)
p = plot_model(lm_model, type = "pred", terms = c("bhv", "Age [18, 54, 88]"), show.data = TRUE); p # vTert
#formatting
p <- p + #geom_hline(yintercept = 0.5) +
  ylim(-0.5,0.5) +
  xlim(0,60) +
  # scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
  #                    limits = c(15,90)) +
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
ggsave(file.path("RSFA_lSPOC_sjPlot.png"),
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
qq$data[[2]]$colour[1:7] = 'olivedrab'
qq$data[[2]]$colour[8:14] = 'darkturquoise'
qq$data[[2]]$colour[15:21] = 'dodgerblue3'
# #hack plot - CI shaded
qq$data[[3]]$alpha <- 0.2
qq$data[[3]]$fill[1:7] = 'olivedrab'
qq$data[[3]]$fill[8:14] = 'darkturquoise'
qq$data[[3]]$fill[15:21] = 'dodgerblue3'
plot(ggplot_gtable(qq))



#Below is extra code if we were interested in 
#1. Calculating the BayesFactors OR
#2. Reppeating the Vascular control analysis for frontal cortex (no effect in first place!)
  
# #-------------- Get bayes factors --------------#
# #Cant use scale() in lmBF so scale first!
# df2 = df
# df2$age_scale = scale(df$Age)
# df2$bhv_scale = scale(df$bhv)
# df2$bhv_OutOfScanner_scale = scale(df$bhv_outOfScanner)
# df2$STW_scale = scale(df$STW)
# df2$lSPOC_scale = scale(df$lSPOC)
# df2$frontal_scale = scale(df$frontal)
# #extra
# df2$GenderNum_scale = scale(df$Gender)
# df2$handedness_scale = scale(df$handedness)
# 
# full <-           lmBF(lSPOC_scale ~ Age_scale * bhv_scale + GenderNum_scale + handedness_scale,
#                        data = df2)
# noInteraction <-  lmBF(lSPOC_scale ~ Age_scale + bhv_scale + GenderNum_scale + handedness_scale,
#                        data = df2)
# bf10 = full / noInteraction #less than 1 favours models of 
# bf10
# 
# 
# 
# #frontal
# lm_model <- lm(frontal ~ scale(Age) * scale(bhv) + scale(Gender) + scale(handedness),
#                data = df); summary(lm_model)
# lm_model <- lm(frontal ~ scale(Age) * scale(bhv),
#                data = df); summary(lm_model)
# 
# 
# full <-           lmBF(frontal_scale ~ Age_scale * bhv_scale + GenderNum_scale + handedness_scale,
#                        data = df2)
# noInteraction <-  lmBF(frontal_scale ~ Age_scale + bhv_scale + GenderNum_scale + handedness_scale,
#                        data = df2)
# bf10 = full / noInteraction #less than 1 favours models of 
# bf01 = 1/bf10; bf01
# 
# 
# 
# 
# 
# 
# #Plot with fit
# lm_model <- lm(frontal ~ Age * bhv + Gender,
#                data = df); summary(lm_model)
# p = plot_model(lm_model, type = "pred", terms = c("bhv", "Age [18, 54, 88]"), show.data = TRUE); p # vTert
# #formatting
# p <- p +
#   ylim(-1.5,0.9) +
#   xlim(0,60) +
#   # scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
#   #                    limits = c(15,90)) +
#   theme_bw() +
#   theme(panel.border = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = "none",
#         panel.grid.minor = element_blank(),
#         axis.line =
#           element_line(colour = "black",size = 1.5),
#         axis.ticks = element_line(colour = "black",
#                                   size = 1.5),
#         text = element_text(size=24)); p
# # #hack plot
# qq <- ggplot_build(p)
# # #hack plot - scatter
# qq$data[[1]]$shape <- o
# qq$data[[1]]$size <- 2.5
# qq$data[[1]]$stroke <- 1
# qq$data[[1]]$alpha <- 0.5
# qq$data[[1]]$colour[df$ageTert == 'YA'] = 'olivedrab'
# qq$data[[1]]$colour[df$ageTert == 'ML'] = 'darkturquoise'
# qq$data[[1]]$colour[df$ageTert == 'OA'] = 'dodgerblue3'
# # #hack plot - regression line
# qq$data[[2]]$size <- 2.5
# #qq$data[[2]]$y[1:2] = NA # truncate (to match CI shading)
# qq$data[[2]]$colour[1:7] = 'olivedrab'
# qq$data[[2]]$colour[8:14] = 'darkturquoise'
# qq$data[[2]]$colour[15:21] = 'dodgerblue3'
# # #hack plot - CI shaded
# qq$data[[3]]$alpha <- 0.2
# qq$data[[3]]$fill[1:7] = 'olivedrab'
# qq$data[[3]]$fill[8:14] = 'darkturquoise'
# qq$data[[3]]$fill[15:21] = 'dodgerblue3'
# plot(ggplot_gtable(qq))
# 
# 
