options(scipen = 0)


df_bhv = read.csv('../../../../R/csv/univariate.csv')
df_MVB = read.csv('csv/MVB_cuneal.csv')
#df_MVB_shuffledMapping = read.csv('csv/extraData_ShuffledGroupFVals.csv')
df <- inner_join(df_bhv, df_MVB, by="CCID")

#add ageTert
vTert = quantile(df$age, c(0:3/3)) #rememebr this is useful for plot_model
df$ageTert = with(df, 
                  cut(age, 
                      vTert, 
                      include.lowest = T, 
                      labels = c("YA", "ML", "OA")))


df_subset <- df[which(df$idx_couldNotDecode==0), ]
unique(df_subset$ordy)



# Boost ~ Age * Bhv + Sex (mirroring Univariate interaction)
#=====================================================================================
model <- glm(formula = as.factor(ordy) ~ scale(age) * scale(bhv) + scale(Gender),
             family = binomial(), data = df_subset); summary(model)
plot(df$age,df$ordy)


# compare bhv of boost vs noBoost groups
#=====================================================================================
noBoost <- df$bhv[df$ordy == 1]
Boost <- df$bhv[df$ordy == 2]
var.test(noBoost, Boost) #p =.08 (assume homogenous)

t.test(noBoost, Boost, var.equal = TRUE)
# Two Sample t-test
# 
# data:  noBoost and Boost
# t = 2.9198, df = 219, p-value = 0.003869
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   1.550945 7.993280
# sample estimates:
#   mean of x mean of y 
# 42.66071  37.88860 

#However, noBoost bhv > Boost bhv!
mean(noBoost)
# [1] 42.66071
sd(noBoost)
# [1] 6.289399
mean(Boost)
# [1] 37.8886
sd(Boost)
# [1] 8.303129

# quick correlations
#=====================================================================================
cor.test(df$age, df$groupFvals)
# Pearson's product-moment correlation
# 
# data:  df$age and df$groupFvals
# t = -6.5887, df = 219, p-value = 3.256e-10
# alternative hypothesis: true correlation is not equal to 0
# 95 percent confidence interval:
#  -0.5112600 -0.2903452
# sample estimates:
#        cor 
# -0.4067316

cor.test(df$bhv, df$groupFvals)
# Pearson's product-moment correlation
# 
# data:  df$bhv and df$groupFvals
# t = 7.6987, df = 219, p-value = 4.674e-13
# alternative hypothesis: true correlation is not equal to 0
# 95 percent confidence interval:
#  0.3509133 0.5594113
# sample estimates:
#       cor 
# 0.4615117

#partial correlation
library(ppcor)
pcor.test(df$bhv, df$groupFvals, df$Age)
# estimate      p.value statistic   n gp  Method
# 1 0.2810972 2.324256e-05  4.324726 221  1 pearson
plot(df$bhv, df$groupFvals) #note - improve this with ggplot + age-residualisation etc.
#Shows better bhv = higher ModelLogEvidence 

