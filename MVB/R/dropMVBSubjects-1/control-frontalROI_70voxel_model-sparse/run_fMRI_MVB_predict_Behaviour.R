
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


#df$ordy <- as.factor(df$ordy) %stops plots!

#ORIGINAL MODEL: ENSURE AGE EFFECT:
# model <- glm(formula = ordy ~ scale(age0z2) * scale(GenderNum),
#              family = binomial(logit), data = df); summary(model)


#Predict behaviour (age tert split)
#======================================================================

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
ggsave(file.path('images',"frontal_MVB-bhv.png"),
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

