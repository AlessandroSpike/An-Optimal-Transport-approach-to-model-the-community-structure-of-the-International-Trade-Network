# Load necessary libraries
library(fixest)

# Load the dataset
data <- read.csv("E:/NullModel/Codici/final/FinalMagari/Soc_Net/DatiR.csv")

# Convert exporter and importer to factors
data$Exp <- as.factor(data$Exp) # Exporter
data$Imp <- as.factor(data$Imp) # Importer

# Create a binary indicator for trade relationships
data$Var16 <- ifelse(data$Var1 > 0, 1, 0)


# PPML estimation with fixed effects
modello <- feglm(
  Var1 ~ Var2 + Var3 + Var4 + Var5 + Var6 + Var7 + Var8 + Var9 + Var10 + Var11 + Var12 + Var13 + Var14 + Var15 + Var16| Exp + Imp,
  data = data,
  family = poisson(),
)
summary(modello)                        # Number of coefficients
predetti <- predict(modello, newdata = data)

write.csv(predetti, "E:/NullModel/Codici/final/FinalMagari/Soc_Net/Fit.csv")
write.csv(modello$coefficients, "E:/NullModel/Codici/final/FinalMagari/Soc_Net/Coeff.csv")

