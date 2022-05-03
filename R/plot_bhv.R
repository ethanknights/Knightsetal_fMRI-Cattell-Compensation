options(scipen = 0)
#put relevant stuff in wide and long format
wide <- data.frame(
  CCID = df$CCID,
  age = df$Age,
  bhv.STW = scale(df$STW),
  bhv.outScanner = scale(df$bhv_outOfScanner),
  bhv.inScanner = scale(df$bhv),
  GenderNum = scale(df$Gender), #-1.0022 is male
  handedness = scale(df$handedness),
  ageTert = df$ageTert
)
long <- wide %>% gather(Key, Performance, bhv.outScanner, bhv.inScanner, bhv.STW)#, GenderNum, handedness)

wide$ageLin_scale = scale(wide$age)
wide$ageLinQuad_scale = poly(scale(wide$age),2)
#wide$ageQuadOnly_scale = wide$ageLin_scale ^ 2 #doesnt orthogonalise like poly!

#=====================================
#inscanner
#=====================================

#lm()
#-------------------------------------
lm_model <- lm(bhv.inScanner ~ ageLinQuad_scale * GenderNum, #these are all already scaled!
               data = wide); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path(outImageDir,'regression_bhv.csv'))
#p = plot_model(lm_model, type = 'pred', terms = c('GenderNum', 'ageLinQuad_scale'), show.data = TRUE); p

#Plot lm()
#-------------------------------------
lm_model <- lm(bhv.inScanner ~ age * factor(GenderNum),
               data = wide); summary(lm_model)
p = plot_model(lm_model, type = 'pred', terms = c('age','GenderNum'), show.data = TRUE); p
p = p +
  ylim(-4.5,2) + 
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = 'none', #"right",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24)); p
qq <- ggplot_build(p)
# #hack plot - scatter
#qq$data[[1]]$shape <- o
qq$data[[1]]$size <- 2.5
qq$data[[1]]$stroke <- 2
qq$data[[1]]$alpha <- 0.5
qq$data[[1]]$colour[round(wide$GenderNum) == 1] = 'orange'
qq$data[[1]]$colour[round(wide$GenderNum) == -1] = 'purple'
# #hack plot - regression line
qq$data[[2]]$size <- 2
qq$data[[2]]$colour[1:9] = 'orange'
qq$data[[2]]$colour[10:18] = 'purple'
# #hack plot - CI shaded
qq$data[[3]]$alpha <- 0.2
qq$data[[3]]$fill[1:9] = 'orange'
qq$data[[3]]$fill[10:18] = 'purple'
plot(ggplot_gtable(qq))
#ggsave(file.path(outImageDir,"bhv_fluid_withGenderInteraction.png"),
#       width = 25, height = 25, units = 'cm', dpi = 300); p

#BF10
#-------------------------------------

full <- lmBF(bhv.inScanner ~ ageLin_scale + GenderNum,
               data = wide)
part <- lmBF(bhv.inScanner ~ GenderNum,
             data = wide)
bf10 = full / part; bf10  #1/full
bf01 = 1/bf10; bf01

full <- lmBF(bhv.inScanner ~ ageLin_scale + GenderNum,
             data = wide)
part <- lmBF(bhv.inScanner ~ ageLin_scale * GenderNum,
             data = wide)
bf10 = full / part; bf10  #1/full
bf01 = 1/bf10; bf01


#outscanner
#====================================
lm_model <- lm(bhv.outScanner ~ ageLinQuad_scale * GenderNum,
               data = wide); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path(outImageDir,'regression_bhv-outScanner.csv'))

# in/out-of-scanner correlation
cor.test(x = wide$bhv.inScanner, y = wide$bhv.outScanner)

full <- correlationBF(x = wide$bhv.inScanner, y = wide$bhv.outScanner)
1 / full


icc(
  wide[c('bhv.inScanner','bhv.outScanner')],
    model = "oneway", type = "agreement", unit = "single")

#plot in-out correlation
p <- ggplot(wide, aes(x = bhv.inScanner, y = bhv.outScanner, colour = age))
p <- p + geom_point(shape = 16, size = 5, stroke = 2, alpha = 0.5) +
  geom_abline(intercept = 0, size = 2) +
  ylim(-4.05,2.1) + xlim(-4.05,2.1) +
  scale_color_gradient(low="blue", high="red")
p = p +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = 'right', #"right",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24));
ggsave(file.path(outImageDir,"bhv_correlation.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p

# 
# #######################################################
# ## STW
# long_fluid = long[!long$Key == 'bhv.STW',]
# write.csv(long_fluid,'tmp_long_fluid.csv')
# 
# lm_model <- lm(bhv.STW ~ ageLin_scale,
#                data = wide); summary(lm_model)
# lm_model <- lm(bhv.STW ~ ageLinQuad_scale + GenderNum + handedness,
#                data = wide); summary(lm_model)
# 
# #
# long_crystal = long[long$Key == 'bhv.STW',]
# 
# p <- ggplot(long_crystal, aes(x = age, y = Performance))
# p <- p + geom_point(shape = 20, size = 4, stroke = 2, alpha = 0.75, colour = 'lightpink') +
#   stat_smooth(method = "lm", size = 2, fill = 'grey60', colour = 'lightpink') +
#   ylim(-6,2) +
#   scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
#                      limits = c(15,90)) +
#   theme_bw() + 
#   theme(panel.border = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = 'right', #"right",
#         panel.grid.minor = element_blank(),
#         axis.line = 
#           element_line(colour = "black",size = 1.5), 
#         axis.ticks = element_line(colour = "black",
#                                   size = 1.5),
#         text = element_text(size=24));
# ggsave(file.path(outImageDir,"bhv_crystal.png"),
#        width = 25, height = 25, units = 'cm', dpi = 300); p
# 
# 
# 
# #Plot subject CFIT joined timepoints
# long2 = long <- data.frame(
#   bhv.outScanner = scale(df$bhv_outOfScanner),
#   bhv.inScanner = scale(df$bhv),
#   age = df$Age
# )
# long2 <- long2 %>% gather(Key, Performance, bhv.outScanner, bhv.inScanner)
# 
# p <- ggplot(long2, aes(x = age, y = Performance, colour = Key, fill = Key))
# p <- p + geom_point(shape = 21,size = 4, colour = 'black', stroke = 2, alpha = 0.75)
# p
# 
# 
# 
