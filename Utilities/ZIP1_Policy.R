# Load necessary libraries
library(fixest)
library(dplyr)


# Load the dataset
data <- read.csv("E:/NullModel/Codici/final/FinalMagari/Soc_Net/DatiR.csv")
# Load the dataset
dataShock <- read.csv("E:/NullModel/Codici/final/FinalMagari/Soc_Net/DatiRShock.csv")

# PPML estimation with fixed effects
modello <- feglm(
  Var1 ~ Var2 + Var3 + Var4 + Var5 + Var6 + Var7 + Var8 + Var9 + Var10 + Var11 + Var12 + Var13 + Var14 + Var15,
  data = data,
  family = poisson(),
)
predetti <- predict(modello, newdata = data)
predettiShock <- predict(modello, newdata = dataShock)

write.csv(predetti, "E:/NullModel/Codici/final/FinalMagari/Soc_Net/Fit.csv")
write.csv(predettiShock, "E:/NullModel/Codici/final/FinalMagari/Soc_Net/FitShock.csv")
