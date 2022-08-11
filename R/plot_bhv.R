options(scipen = 0)

wide <- data.frame(
  CCID                  = df$CCID,
  age                   = df$Age,
  age_scale             = scale(df$Age),
  bhv.outScanner        = df$bhv_outOfScanner,
  bhv.outScanner_scale  = scale(df$bhv_outOfScanner),
  bhv.inScanner         = df$bhv,
  bhv.inScanner_scale   = scale(df$bhv),
  GenderNum             = df$Gender,
  GenderNum_scale       = scale(df$Gender), #-1.0022 is male
  ageTert               = df$ageTert
)


#inScanner
#=====================================

#lm()
#-------------------------------------
lm_model <- lm(bhv.inScanner ~ age_scale + GenderNum_scale,
               data = wide); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path(outImageDir,'regression_bhv.csv'))

idx.female = round(wide$GenderNum_scale,3) == 0.993
idx.male = round(wide$GenderNum_scale,3) == -1.002
mean(wide$bhv.inScanner[idx.female])
mean(wide$bhv.inScanner[idx.male])
sd(wide$bhv.inScanner[idx.female])
sd(wide$bhv.inScanner[idx.male])

#Plot lm()
#-------------------------------------
lm_model <- lm(bhv.inScanner ~ age,
               data = wide); summary(lm_model)
p = plot_model(lm_model, type = 'pred', terms = c('age'), show.data = TRUE); p
p = p +
  ylim(0,60) + 
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = 'none', #"right",
        axis.line = element_line(colour = "black", size = 2), 
        axis.ticks = element_line(colour = "black", size = 2),
        text = element_text(size=24)); p
qq <- ggplot_build(p)
# #hack plot - scatter
qq$data[[1]]$shape = 21
qq$data[[1]]$stroke <- 0.75
qq$data[[1]]$fill = 'azure4'
qq$data[[1]]$colour = 'black'
qq$data[[1]]$alpha = 0.6
qq$data[[1]]$size = 6
# #hack plot - regression line
qq$data[[2]]$size <- 2
qq$data[[2]]$colour = 'black'
# #hack plot - CI shaded
qq$data[[3]]$alpha <- 0.2
qq$data[[3]]$fill = 'black'
plot(ggplot_gtable(qq))
grid.draw(ggplot_gtable(qq))
dev.copy(device = tiff, filename = file.path(outImageDir,'bhv_plot.tiff'), width = pxwidth, height = pxheight); dev.off()

#outscanner
#====================================

#lm()
#------------------------------------
lm_model <- lm(bhv.outScanner ~ age_scale + GenderNum_scale,
               data = wide); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path(outImageDir,'regression_bhv-outScanner.csv'))

idx.female = round(wide$GenderNum_scale,3) == 0.993
idx.male = round(wide$GenderNum_scale,3) == -1.002
mean(wide$bhv.outScanner[idx.female])
mean(wide$bhv.outScanner[idx.male])
sd(wide$bhv.outScanner[idx.female])
sd(wide$bhv.outScanner[idx.male])

#in/out-of-scanner correlation
#------------------------------------
cor.test(x = wide$bhv.inScanner_scale, y = wide$bhv.outScanner_scale, method = 'pearson', alternative = 'greater') #predict positive

#plot in-out correlation
p <- ggplot(wide, aes(x = bhv.inScanner_scale, y = bhv.outScanner_scale, fill = age))
p <- p + geom_point(shape = 21, size = 6, stroke = 1.25, alpha = 1, colour = 'black') +
  geom_abline(intercept = 0, size = 2) +
  ylim(-4.05,2.1) + xlim(-4.05,2.1) +
  scale_fill_gradient(low="green", high="blue") +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "right",
        axis.line = element_line(colour = "black", size = 2), 
        axis.ticks = element_line(colour = "black", size = 2),
        text = element_text(size=24)); p
dev.copy(device = tiff, filename = file.path(outImageDir,'corr_plot.tiff'), width = pxwidth, height = pxheight); dev.off()