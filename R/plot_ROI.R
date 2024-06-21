options(scipen = 0)

# Cuneus
#----------

#lm()
lm_model <- lm(lSPOC ~ scale(Age) * scale(bhv) + scale(Gender),
               data = df); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path(outImageDir,'regression_ROI_cuneal.csv'))

#Plot lm()
lm_model <- lm(lSPOC ~ Age * bhv,
               data = df); summary(lm_model)
p = plot_model(lm_model, type = "pred", terms = c("bhv", "Age [18, 54, 88]"), show.data = TRUE); p # vTert
p <- p +
  ylim(-1,1) +
  xlim(0,60) +
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
# #hack plot
qq <- ggplot_build(p)
# #hack plot - scatter
qq$data[[1]]$shape <- 21
qq$data[[1]]$size <- 6
qq$data[[1]]$stroke <- 0.75
qq$data[[1]]$colour = 'black'
qq$data[[1]]$alpha <- 1
qq$data[[1]]$fill[df$ageTert == 'YA'] = 'olivedrab'
qq$data[[1]]$fill[df$ageTert == 'ML'] = 'darkturquoise'
qq$data[[1]]$fill[df$ageTert == 'OA'] = 'dodgerblue3'
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
#truncate (to match CI shading)
plot(ggplot_gtable(qq))
grid.draw(plot(ggplot_gtable(qq)))
dev.copy(device = tiff, filename = file.path(outImageDir,'cuneal_interaction_plot.tiff'), width = pxwidth, height = pxheight); dev.off()


# Frontal
#----------

#lm()
lm_model <- lm(frontal ~ scale(Age) * scale(bhv) + scale(Gender),
               data = df); summary(lm_model)
write.csv(as.data.frame(summary(lm_model)$coef), file=file.path(outImageDir,'regression_ROI_frontal.csv'))


#Plot lm()
lm_model <- lm(frontal ~ Age * bhv,
               data = df); summary(lm_model)
p = plot_model(lm_model, type = "pred", terms = c("bhv", "Age [18, 54, 88]"), show.data = TRUE); p # vTert
#formatting
p <- p +
  ylim(-1,1) +
  xlim(0,60) +
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
qq <- ggplot_build(p)
# #hack plot - scatter
qq$data[[1]]$shape <- 21
qq$data[[1]]$size <- 6
qq$data[[1]]$stroke <- 0.75
qq$data[[1]]$colour = 'black'
qq$data[[1]]$alpha <- 1
qq$data[[1]]$fill[df$ageTert == 'YA'] = 'olivedrab'
qq$data[[1]]$fill[df$ageTert == 'ML'] = 'darkturquoise'
qq$data[[1]]$fill[df$ageTert == 'OA'] = 'dodgerblue3'
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
grid.draw(plot(ggplot_gtable(qq)))
dev.copy(device = tiff, filename = file.path(outImageDir,'frontal_interaction_plot.tiff'), width = pxwidth, height = pxheight); dev.off()

