#======================= Boost Analysis ======================#

#first drop subjects who failed decoding
df_subset <- df[which(df$idx_couldNotDecode==0), ]

unique(df_subset$ordy)


#---------- Version if only 2 levels in ordy (e.g. Boost, Reduction; no equivalent) -------#
#-- First just do linear age (no quadratic) (as ordinal data) --#
model <- glm(formula = ordy ~ scale(age0z2) * scale(GenderNum) + scale(lSPOC),
             family = binomial(logit), data = df_subset)
summary(model)
write.csv(as.data.frame(summary(model)$coef), file=file.path(outImageDir,'glm_MVB_covaryUnivariate.csv'))
#Get Odds ratio
exp(coef(model))
ci<-confint(model)
OR <- exp(cbind(OR = coef(model), ci)); OR
#effect size cohen d? d = b / (sqrt(n)*SE) = b / SE * 1 / sqrt(n)  = z/sqrt(n)
source("getBF_MVB_linearANDQuadratic_fullModel.R") #get BF01 for Boost ~ Age > 0


#Plot - geom_density
#fancier than: plot(df$age,df$ordy)
ggplot(df_subset, aes(age, fill = fct_rev(ordy))) +
  geom_density(position='fill', alpha = 0.75,color="white", kernel = 'cosine') +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        # axis.line.x =
        #   element_line(colour = "black",size = 0),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_line(colour = "black",
                                    size = 1),
        text = element_text(size=24)) +
  #Set Colours
  scale_fill_manual( values = c("limegreen","lightgray")) +
  #Remove space around axis
  coord_cartesian(xlim = c(20,80) , ylim = c(0,1), expand = TRUE)
ggsave(file.path(outImageDir,'Boost_geom_density.png'),
       width = 25, height = 25, units = 'cm', dpi = 300)