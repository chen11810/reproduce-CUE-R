# Set the working path
#setwd("Set your working path")
# Load necessary packages
library(tidyverse)
library(sf)
library(ggspatial)
library(RColorBrewer)
library(ggtext)
library(meta)
library(metafor)
library(metadat)
library(rcartocolor)
library(ggsci)
library(metaforest)
library(caret)
library(broom)

# Custom colors
my_colormap <- brewer.pal(8, 'Spectral')

#-----1. Sampling point map-----
scatter_df <- read.csv("extracted_data.csv") 
scatter_df_tro <- st_as_sf(scatter_df, coords = c("Longitude", "Latitude"), crs = 4326)

library(rnaturalearth)
library(sf)
global <- ne_countries(scale = "medium", returnclass = "sf")

#The shp file needs to be prepared in advance and placed in the working path.

p0 <- ggplot() + 
  geom_sf(data = global, fill = "lightgray", color = "black", size = 0.6) + 
  geom_sf(data = scatter_df_tro, color = "darkgray", shape = 21, size = 1, fill = "red") + 
  theme_bw() +
  theme(
    plot.title = element_markdown(hjust = 0.5, size = 15, margin = margin(t = 1, b = 12)),
    plot.subtitle = element_markdown(hjust = 0.5, size = 12, color = "#555555", margin = margin(t = 1, b = 12)),
    legend.position = "right", legend.text = element_text(size = 9)
  )

ggsave("Figure 1 Geographic distribution of observational field studies included in the meta-analysis.pdf", 
       p0, width = 7.52, height = 5.69, units = "in", dpi = 500)

#-----2. Effect size calculation and forest plot-----
df <- read.csv("extracted_data.csv", na.strings = c("", "NA"), stringsAsFactors = TRUE)
MetaDataYV <- escalc(measure = "ROM", n1i = tn, n2i = cn, m1i = tm, m2i = cm, sd1i = ts, sd2i = cs, data = df)
MetaDataYV <- MetaDataYV %>% arrange(-yi)
model1 <- rma(yi, vi, data = MetaDataYV, method = "REML")
pdf("Figure 2 Forest plot of the effects of nitrogen addition on soil microbial carbon use efficiency.pdf", 
    width = 8, height = 10)
forest.rma(model1, annotate = FALSE, col = "black", slab = NA, xlab = "Log Response Ratio", 
           pch = 20, efac = 0, cex = 1, psize = 1, xlim = c(-2.5, 2.5), at = c(-3, -2, -1, 0, 1, 2, 3))
addpoly(model1, efac = 1, annotate = FALSE, col = "#1F77B4", cex = 1)
abline(v = coef(model1), lty = "solid", col = "#1F77B4", lwd = 2)
abline(v = 0, lty = "dotted", col = "#2CA02C", lwd = 1.5)
points(MetaDataYV$yi, nrow(MetaDataYV):1, pch = 19, cex = 0.5, col = "#D62728")
title(main = "Forest Plot", cex.main = 1.2)
mtext("Study", side = 2, line = 2, cex = 1.2)
legend(1.2, 110, legend = c("Model effect", "Zero effect", "Effect sizes"), 
       col = c("#1F77B4", "#2CA02C", "#D62728"), lty = c("solid", "dotted", NA), 
       pch = c(NA, NA, 20), pt.cex = c(NA, NA, 1), bty = "n", cex = 1)
grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")
dev.off()

#-----3. Model Diagnosis-----
pdf("Figure S1 Funnel plot with regression test for asymmetry.pdf", width = 8, height = 8)
funnel(model1, yaxis = "vinv", main = "Inverse Sampling Variance")
dev.off()
regtest(model1, model = "rma")

#-----4. Overall effect  and group effect-----
overall.df <- coef(summary(model1)) %>% mutate(type = "Overall", factor = "Overall", size = model1$k)
Model3 <- rma.mv(yi, vi, data = MetaDataYV, mods = ~MAP-1, random = ~ 1 | Site / obs)
Nm.n <- MetaDataYV %>% group_by(MAP) %>% summarise(n = n())
Nm.df <- coef(summary(Model3)) %>% mutate(type = "MAP", factor = levels(MetaDataYV$MAP), size = Nm.n$n) %>%
  mutate(factor = factor(factor, levels = c("<400", "400-800", ">800"))) %>% arrange(factor)
Model5 <- rma.mv(yi, vi, data = MetaDataYV, mods = ~N_addtion-1, random = ~ 1 | Site / obs)
N_addtion.n <- MetaDataYV %>% filter(N_addtion %in% c("<100", "100-200", ">200")) %>% group_by(N_addtion) %>% summarise(n = n())
N_addtion.df <- coef(summary(Model5)) %>% mutate(type = "N_addtion", factor = levels(MetaDataYV$N_addtion), size = N_addtion.n$n) %>%
  mutate(factor = factor(factor, levels = c("<100", "100-200", ">200"))) %>% arrange(factor)
meta.df <- rbind(overall.df, Nm.df, N_addtion.df)
p <- meta.df %>%
  mutate(factor = factor(factor, levels = c("<400", "400-800", ">800", "<100", "100-200", ">200", "Overall")),
         type = factor(type, levels = rev(unique(type)))) %>%
  ggplot(aes(x = estimate, y = factor, col = type)) +
  geom_point(size = 4) +
  geom_errorbarh(aes(xmax = ci.ub, xmin = ci.lb), height = 0.1) +
  geom_vline(xintercept = 0, linetype = "dotted", color = "darkgray", size = 1) +
  geom_hline(yintercept = c(3.5, 6.5), linetype = "dashed", color = "black", size = 1) +
  geom_text(aes(label = paste0("n = ", size)), hjust = -0.2, size = 3.5, color = "black") +
  geom_text(aes(label = sprintf("%.2f", estimate)), vjust = 1.7, size = 3.5, color = "black") +
  xlim(-0.3, 0.3) +
  labs(x = "Mean Effect Size (Log Response Ratio)", y = "", 
       title = "Effect Size of Nitrogen Addition on Soil Microbial Carbon Use Efficiency", 
       subtitle = "Grouped by MAP and N Addition Levels") +
  theme_bw() + theme(panel.grid = element_blank()) + scale_color_npg()
ggsave("Figure 3 Effects of nitrogen addition on soil microbial carbon use efficiency across precipitation and nitrogen addition levels.pdf", 
       p, width = 6, height = 5.69, units = "in", dpi = 500)
meta.df <- meta.df %>% filter(factor != "Overall")
meta.df$SD <- meta.df$se * sqrt(meta.df$size)
results <- compare_subgroups <- function(data) {
  results <- data.frame()
  for (group in unique(data$type)) {
    group_data <- subset(data, type == group)
    subgroups <- unique(group_data$factor)
    for (i in 1:(length(subgroups) - 1)) {
      for (j in (i + 1):length(subgroups)) {
        mean1 <- group_data$estimate[group_data$factor == subgroups[i]]
        mean2 <- group_data$estimate[group_data$factor == subgroups[j]]
        se1 <- group_data$se[group_data$factor == subgroups[i]]
        se2 <- group_data$se[group_data$factor == subgroups[j]]
        n1 <- group_data$size[group_data$factor == subgroups[i]]
        n2 <- group_data$size[group_data$factor == subgroups[j]]
        se_diff <- sqrt(se1^2 + se2^2)
        t_value <- (mean1 - mean2) / se_diff
        df <- n1 + n2 - 2
        p_value <- 2 * pt(-abs(t_value), df = df)
        results <- rbind(results, data.frame(type = group, Subgroup1 = subgroups[i], Subgroup2 = subgroups[j], 
                                             t_value = t_value, p_value = p_value, df = df))
      }
    }
  }
  results
}
print(compare_subgroups(meta.df))

#-----5. Continuous variable regression test-----
vars <- c("pH", "MAT", "SOC", "TN", "TP", "CNR", "NPR", "MBC", "MBN", "MCNR")
plots <- list()
qq_plots <- list()
for (i in seq_along(vars)) {
  var <- vars[i]
  df_var <- MetaDataYV %>% drop_na(!!sym(var))
  model <- rma.mv(yi, vi, data = df_var, mods = as.formula(paste("~", var)), random = ~ 1 | Site / obs)
  xs <- seq(min(df_var[[var]]), max(df_var[[var]]), length.out = 100)
  pred <- predict(model, newmods = xs)
  pred_df <- data.frame(xs = xs, pred = pred$pred, ci.lb = pred$ci.lb, ci.ub = pred$ci.ub)
  plots[[i]] <- ggplot(df_var, aes_string(x = var, y = "yi")) +
    geom_point(aes(size = 1/vi), shape = 21, color = "black", fill = "#36BED9", stroke = 0.25) +
    scale_size(range = c(3, 10)) +
    
    geom_line(data = pred_df, aes(x = xs, y = pred), color = "#FF0000", size = 1.5) +
    geom_ribbon(data = pred_df, aes(x = xs, y = pred, ymin = ci.lb, ymax = ci.ub), fill = "#E64B34", alpha = 0.1) +
    theme_minimal(base_family = "serif") +
    theme(
      axis.line = element_line(size = 0.5, color = "black"),
      axis.title = element_text(size = 14, face = "bold"),
      axis.text = element_text(size = 12, color = "black"),
      legend.position = "right", panel.border = element_rect(colour = "black", fill = NA, size = 1),
      panel.grid.major = element_line(color = "gray80", linetype = "dotted"), panel.grid.minor = element_blank()
    ) + labs(x = var, y = "Yi") + ggtitle(paste0("(", letters[i], ")"))
  df_var[[paste0("Metayi_", var)]] <- predict(model, df_var[[var]]) %>% as.data.frame() %>% pull(pred)
  print(summary(lm(as.formula(paste0("Metayi_", var, "~yi")), data = df_var)))
  residuals <- residuals(model)
  shapiro_result <- shapiro.test(residuals) %>% tidy() %>% 
    mutate(label = paste("Shapiro-Wilk normality test\nW =", round(statistic, 4), "\np-value =", round(p.value, 4)))
  qq_plots[[i]] <- ggplot(data.frame(residuals = residuals), aes(sample = residuals)) +
    stat_qq() + stat_qq_line(col = "red") +
    labs(title = "QQ Plot of Residuals", x = "Theoretical Quantiles", y = "Sample Quantiles") +
    theme_minimal() + theme_bw() +
    annotate("text", x = Inf, y = -Inf, label = shapiro_result$label, hjust = 1.1, vjust = -0.5, size = 4, color = "blue") +
    ggtitle(paste0("(", letters[i], ")"))
}
install.packages("patchwork")
library(patchwork)
p21 <- wrap_plots(plots, nrow = 2) + plot_layout(guides = "collect") & theme(legend.position = "bottom")
ggsave("Figure 4 Meta regression analysis.pdf", p21, width = 15, height = 7.5, units = "in", dpi = 500)
p22 <- wrap_plots(qq_plots, nrow = 2) + plot_layout(guides = "collect") & theme(legend.position = "bottom")
ggsave("Figure S4 Quantile-quantile plots of residuals from meta-regression models.pdf", p22, width = 15, height = 7.5, units = "in", dpi = 500)

#-----6. Machine Learning-----
MLData <- MetaDataYV %>% select(obs, yi, vi, MAP, N_addtion, pH, MAT, SOC, TN, TP, CNR, NPR, MBC, MBN, MCNR) %>% drop_na()
set.seed(123)
check_conv <- MetaForest(yi ~ ., vi = "vi", method = "REML", data = MLData, study = "obs", whichweights = "random", num.trees = 15000)
pdf("Figure S2_a_Convergence_plot.pdf")
plot(check_conv)
dev.off()
mf_rep <- MetaForest(yi ~ ., vi = "vi", method = "REML", data = MLData, study = "obs", whichweights = "random", num.trees = 8000)
preselected <- preselect(mf_rep, replications = 100, algorithm = "recursive")
data_long <- preselected$selected %>% gather(key = "Variable", value = "Importance") %>%
  group_by(Variable) %>% mutate(median_importance = median(Importance, na.rm = TRUE)) %>% arrange(desc(median_importance))
p <- ggplot(data_long, aes(x = Importance, y = reorder(Variable, median_importance), fill = Variable)) +
  geom_boxplot() + geom_jitter(width = 0, height = 0.12, size = 1, alpha = 0.6, color = "black") +
  labs(x = "Recursive variable Importance (Permutation importance)", y = "") +
  theme_bw() + scale_fill_brewer(palette = "Set3") + theme(legend.position = "none")
ggsave("Figure S3 Replicated variable importance for moderator pre-selection.pdf", p, width = 5.99, height = 6.73, units = "in", dpi = 500)
retain_mods <- preselect_vars(preselected, cutoff = .5)
X <- MLData[, c("obs", "vi", retain_mods)]
tuning_grid <- expand.grid(whichweights = c("random", "fixed", "unif"), mtry = 1:(ncol(X)-2), min.node.size = 1:(ncol(X)-2))
mf_cv <- train(y = MLData$yi, x = X, study = "obs", method = ModelInfo_mf(), 
               trControl = trainControl(method = "cv", index = groupKFold(MLData$obs, k = 10)), 
               tuneGrid = tuning_grid, num.trees = 8000)
final <- mf_cv$finalModel
pdf("Figure S2_b_Convergence_plot_for_final_model.pdf", width = 7, height = 7)
plot(final)
dev.off()
MLData$predyi <- predict(mf_cv, newdata = X)
p1 <- ggplot(MLData, aes(x = predyi, y = yi)) +
  geom_point() + geom_smooth(method = "lm") +
  scale_x_continuous(limits = c(-0.3, 0.4)) + scale_y_continuous(limits = c(-0.5, 0.5)) +
  coord_fixed(ratio = 1) + geom_abline(intercept = 0, slope = 1, size = 0.5, linetype = 2) +
  theme_bw()
ggsave("Figure S5 Relationship between predicted and observed log response ratio of carbon use efficiency.pdf", 
       p1, width = 5.42, height = 5.08, units = "in", dpi = 500)
print(summary(lm(predyi ~ yi, data = MLData)))
importance_data <- data.frame(Variable = names(final$forest$variable.importance), 
                              Importance = final$forest$variable.importance) %>% arrange(desc(Importance))
p_final <- ggplot(importance_data, aes(x = reorder(Variable, Importance), y = Importance, fill = Variable)) +
  geom_bar(stat = "identity") + coord_flip() +
  labs(title = "Variable Importance in Final Model", x = "Variables", y = "Importance") +
  theme_bw() + scale_fill_brewer(palette = "Set3") + theme(legend.position = "none")
ggsave("Figure 5 Variable importance plot.pdf", p_final, width = 7, height = 7)
pdf("Figure 6 Partial dependence plots of important predictors for the effect of nitrogen addition on soil microbial carbon use efficiency.pdf", 
    width = 8, height = 6)
plot(PartialDependence(final, vars = names(final$forest$variable.importance)[order(final$forest$variable.importance, decreasing = TRUE)], 
                       rawdata = TRUE, pi = .95))
dev.off()

