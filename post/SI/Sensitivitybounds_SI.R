
data_dir        <- "~/Desktop/Paper_Rethink_Results/data_zenodo"
out_dir_default <- "~/Desktop/Paper_Rethink_Results/figures"


library(ggplot2)
library(readxl)
library(dplyr)
library(tidyr)
library(patchwork)
library(scales)
Sys.setlocale("LC_ALL", "en_US.UTF-8")

options(scipen = 999)

# ── Data from HPC sensitivity results───────────────────────────────
sigmas <- c(1.1, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0)

sharing_ecoactive <- data.frame(
  sigma       = sigmas,
  lowcarbon   = c(-0.0441650390,-0.0318603515,-0.0240966796,-0.0194091796,-0.0164794921,-0.0142822265,-0.0126708984,-0.0113525390,-0.0103271484,-0.0095947265,-0.0088623046),
  cautious    = c(-0.0233642578,-0.0169189453,-0.0129638671,-0.0104736328,-0.0090087890,-0.0078369140,-0.0069580078,-0.0062255859,-0.0057861328,-0.0053466796,-0.0049072265),
  constrained = c( 0.1106689453, 0.0812255859, 0.0617431640, 0.0498779296, 0.0418212890, 0.0361083984, 0.0318603515, 0.0284912109, 0.0257080078, 0.0235107421, 0.0216064453)
)

sharing_affordability <- data.frame(
  sigma       = sigmas,
  lowcarbon   = c( 0.0374267578, 0.0273193359, 0.0208740234, 0.0169189453, 0.0142822265, 0.0123779296, 0.0110595703, 0.0100341796, 0.0091552734, 0.0084228515, 0.0078369140),
  cautious    = c( 0.0150146484, 0.0110595703, 0.0084228515, 0.0069580078, 0.0059326171, 0.0052001953, 0.0046142578, 0.0043212890, 0.0038818359, 0.0035888671, 0.0034423828),
  constrained = c(-0.0687744140,-0.0491455078,-0.0366943359,-0.0292236328,-0.0243896484,-0.0208740234,-0.0183837890,-0.0163330078,-0.0147216796,-0.0134033203,-0.0122314453)
)

sufficiency_ecoactive <- data.frame(
  sigma       = sigmas,
  lowcarbon   = c(-0.0595458984,-0.0585205078,-0.0573486328,-0.0563232421,-0.0551513671,-0.0542724609,-0.0532470703,-0.0523681640,-0.0514892578,-0.0506103515,-0.0497314453),
  cautious    = c(-0.0309814453,-0.0305419921,-0.0299560546,-0.0293701171,-0.0289306640,-0.0283447265,-0.0279052734,-0.0274658203,-0.0270263671,-0.0267333984,-0.0262939453),
  constrained = c( 0.1559326171, 0.1537353515, 0.1510986328, 0.1486083984, 0.1464111328, 0.1442138671, 0.1421630859, 0.1404052734, 0.1385009765, 0.1368896484, 0.1352783203)
)

sufficiency_affordability <- data.frame(
  sigma       = sigmas,
  lowcarbon   = c( 0.0506103515, 0.0497314453, 0.0488525390, 0.0481201171, 0.0472412109, 0.0465087890, 0.0459228515, 0.0451904296, 0.0446044921, 0.0440185546, 0.0434326171),
  cautious    = c( 0.0194091796, 0.0191162109, 0.0188232421, 0.0185302734, 0.0182373046, 0.0179443359, 0.0176513671, 0.0175048828, 0.0172119140, 0.0170654296, 0.0169189453),
  constrained = c(-0.0932373046,-0.0916259765,-0.0897216796,-0.0878173828,-0.0859130859,-0.0840087890,-0.0822509765,-0.0804931640,-0.0788818359,-0.0772705078,-0.0756591796)
)

deriv_raw <- data.frame(
  sigma     = rep(sigmas, each = 6),
  lifestyle = rep(c("Ecoactive","Ecoactive","Ecoactive",
                    "Affordability","Affordability","Affordability"), 11),
  hh        = rep(c("lowcarbon","cautious","constrained",
                    "lowcarbon","cautious","constrained"), 11),
  first_d = c(
    0.0307617187500000, 0.0161132812500000,-0.0736083985000000,
    -0.0252685547500000,-0.0098876952500000, 0.0490722655000000,
    0.0222981771111111, 0.0115559896666667,-0.0543619792222222,
    -0.0183919271111111,-0.0073242187777778, 0.0356445312222222,
    0.0124511719000000, 0.0064453125000000,-0.0313476563000000,
    -0.0104003906000000,-0.0041015625000000, 0.0199218750000000,
    0.0076171875000000, 0.0039550781000000,-0.0199218750000000,
    -0.0065917969000000,-0.0024902344000000, 0.0123046875000000,
    0.0051269531000000, 0.0026367188000000,-0.0137695312000000,
    -0.0045410157000000,-0.0017578125000000, 0.0083496094000000,
    0.0038085937000000, 0.0020507812000000,-0.0099609375000000,
    -0.0032226562000000,-0.0013183593000000, 0.0060058594000000,
    0.0029296875000000, 0.0016113281000000,-0.0076171875000000,
    -0.0023437500000000,-0.0008789063000000, 0.0045410156000000,
    0.0023437500000000, 0.0011718750000000,-0.0061523437000000,
    -0.0019042969000000,-0.0007324219000000, 0.0036621094000000,
    0.0017578125000000, 0.0008789063000000,-0.0049804688000000,
    -0.0016113281000000,-0.0007324219000000, 0.0029296875000000,
    0.0014648438000000, 0.0008789063000000,-0.0041015625000000,
    -0.0013183594000000,-0.0004394531000000, 0.0024902343000000,
    -0.0017444957272727,-0.0009721235636364, 0.0042746803818182,
    0.0015314275454545, 0.0006525212909091,-0.0024369673272727
  ),
  second_d = c(
    -0.0338541665555556,-0.0182291663333333, 0.0769856771111111,
    0.0275065105555556, 0.0102539058888889,-0.0537109371111111,
    -0.0338541665555556,-0.0182291663333333, 0.0769856771111111,
    0.0275065105555556, 0.0102539058888889,-0.0537109371111111,
    -0.0123046876000000,-0.0058593756000000, 0.0304687500000000,
    0.0099609376000000, 0.0046875004000000,-0.0199218752000000,
    -0.0070312500000000,-0.0041015620000000, 0.0152343752000000,
    0.0052734372000000, 0.0017578120000000,-0.0105468748000000,
    -0.0029296876000000,-0.0011718752000000, 0.0093750000000000,
    0.0029296876000000, 0.0011718756000000,-0.0052734376000000,
    -0.0023437500000000,-0.0011718752000000, 0.0058593748000000,
    0.0023437504000000, 0.0005859372000000,-0.0041015624000000,
    -0.0011718748000000,-0.0005859372000000, 0.0035156252000000,
    0.0011718744000000, 0.0011718748000000,-0.0017578128000000,
    -0.0011718752000000,-0.0011718752000000, 0.0023437500000000,
    0.0005859380000000,-0.0005859372000000,-0.0017578120000000,
    -0.0011718748000000, 0.0000000004000000, 0.0023437496000000,
    0.0005859372000000, 0.0005859372000000,-0.0011718756000000,
    0.0000000000000000,-0.0000000004000000, 0.0011718756000000,
    0.0005859376000000, 0.0005859380000000,-0.0005859372000000,
    0.0010697798424242, 0.0006170099212121,-0.0026944246606061,
    -0.0009011008484848,-0.0003151632969697, 0.0015935724424242
  )
) %>% mutate(row_idx = row_number())

sigma_breaks <- deriv_raw %>% group_by(sigma) %>% slice(1) %>% pull(row_idx)
sigma_labels <- as.character(sigmas)

ub_x <- deriv_raw %>% filter(sigma == 4.0) %>% slice(1) %>% pull(row_idx)
ub_y <- deriv_raw %>% filter(sigma == 4.0) %>% pull(second_d) %>% mean()

make_long <- function(df, lifestyle, behaviour) {
  df %>%
    pivot_longer(c(lowcarbon, cautious, constrained),
                 names_to = "HH_type", values_to = "Lifestyle_modifier") %>%
    mutate(
      Scenario_lifestyle = lifestyle,
      Behaviour          = behaviour,
      Elasticity         = sigma,
      Income_group       = case_when(
        HH_type == "lowcarbon"   ~ "Higher-income",
        HH_type == "cautious"    ~ "Medium-income",
        HH_type == "constrained" ~ "Lower-income"
      )
    ) %>%
    select(-sigma, -HH_type)
}

df_sharing <- bind_rows(
  make_long(sharing_ecoactive,     "Ecoactive",    "Sharing"),
  make_long(sharing_affordability, "Affordability", "Sharing")
)

df_sufficiency <- bind_rows(
  make_long(sufficiency_ecoactive,     "Ecoactive",    "Sufficiency"),
  make_long(sufficiency_affordability, "Affordability", "Sufficiency")
)

df_all <- bind_rows(df_sharing, df_sufficiency)

df_all$Income_group <- factor(df_all$Income_group,
                              levels = c("Higher-income","Medium-income","Lower-income"))
df_all$Behaviour    <- factor(df_all$Behaviour, levels = c("Sharing","Sufficiency"))

df_levels <- df_all %>%
  filter(round(Elasticity, 1) %in% c(1.1, 2.5, 4.0)) %>%
  mutate(Ecosystem = case_when(
    round(Elasticity, 1) == 1.1 ~ "Lower bound (1.1)",
    round(Elasticity, 1) == 2.5 ~ "Intermediate (2.5)",
    round(Elasticity, 1) == 4.0 ~ "Upper bound (4.0)"
  ))

df_levels$Ecosystem <- factor(df_levels$Ecosystem,
                              levels = c("Lower bound (1.1)",
                                         "Intermediate (2.5)",
                                         "Upper bound (4.0)"))

scenario_colors  <- c("Ecoactive" = "#2166AC", "Affordability" = "#B2182B")
behaviour_shapes <- c("Sharing" = 22, "Sufficiency" = 23)

# ── Theme ─────────────────────────────────────────────────────────────────────
theme_nature <- function() {
  theme_bw(base_size = 10) +
    theme(
      panel.grid.major  = element_line(color = "grey90", linewidth = 0.3),
      panel.grid.minor  = element_blank(),
      panel.border      = element_rect(color = "black", linewidth = 0.5),
      axis.title        = element_text(size = 9),
      axis.text         = element_text(size = 8, color = "black"),
      axis.ticks        = element_line(linewidth = 0.4),
      legend.position   = "bottom",
      legend.title      = element_text(size = 9, face = "bold"),
      legend.text       = element_text(size = 9),
      legend.key.size   = unit(0.4, "cm"),
      legend.background = element_blank(),
      plot.title        = element_text(size = 10, face = "bold", hjust = 0.5),
      plot.margin       = margin(5, 5, 5, 5)
    )
}

create_levels_panel <- function(data, scenario_name, title, show_y_label = TRUE) {
  subset_data <- data %>% filter(Scenario_lifestyle == scenario_name)
  
  ggplot(subset_data,
         aes(x     = Income_group,
             y     = Lifestyle_modifier,
             color = Scenario_lifestyle,
             shape = Behaviour,
             group = interaction(Income_group, Scenario_lifestyle, Behaviour))) +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = Inf,
             fill = "grey90", alpha = 0.5) +
    geom_hline(yintercept = 0, linetype = "dashed",
               color = "grey50", linewidth = 0.25) +
    annotate("text", x = "Medium-income", y = 0.14,
             label = "Uptake of ownership",
             hjust = 0.5, vjust = 1, size = 2.8,
             color = "grey30", fontface = "bold") +
    annotate("text", x = "Medium-income", y = -0.09,
             label = "Uptake of non-ownership",
             hjust = 0.5, vjust = 0, size = 2.8,
             color = "grey30", fontface = "bold") +
    geom_line(linewidth = 0.3, color = "grey70") +
    geom_point(aes(fill = Ecosystem), size = 2.25, stroke = 0.5) +
    scale_color_manual(values = scenario_colors, guide = "none") +
    scale_shape_manual(values = behaviour_shapes, name = "Lifestyle") +
    scale_fill_manual(
      values = c("Lower bound (1.1)"  = "white",
                 "Intermediate (2.5)"  = "grey70",
                 "Upper bound (4.0)"   = "grey20"),
      name = "Substitution elasticity"
    ) +
    guides(
      shape = guide_legend(order = 1,
                           override.aes = list(size = 3, fill = "white",
                                               color = "grey30")),
      fill  = guide_legend(order = 2,
                           override.aes = list(shape = 21, size = 3,
                                               color = "grey30"))
    ) +
    labs(
      x     = NULL,
      y     = if (show_y_label) "Behavioural modifier value" else NULL,
      title = title
    ) +
    scale_y_continuous(breaks = seq(-0.10, 0.15, by = 0.05),
                       labels = number_format(accuracy = 0.05)) +
    coord_cartesian(ylim = c(-0.10, 0.15), clip = "off") +
    theme_nature()
}

p_eco    <- create_levels_panel(df_levels, "Ecoactive",    "Ecoactive",
                                show_y_label = TRUE)
p_afford <- create_levels_panel(df_levels, "Affordability", "Affordability",
                                show_y_label = FALSE)

top_row <- (p_eco | p_afford) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

heatmap_data <- df_sharing %>%
  group_by(Scenario_lifestyle, Income_group) %>%
  mutate(
    best_case      = Lifestyle_modifier[which.max(Elasticity)],
    diff_from_best = Lifestyle_modifier - best_case,
    effort_gap     = abs(diff_from_best)
  ) %>%
  ungroup()

heatmap_filtered <- heatmap_data %>%
  filter(
    (Scenario_lifestyle == "Ecoactive"    & Income_group == "Higher-income")   |
      (Scenario_lifestyle == "Ecoactive"    & Income_group == "Medium-income") |
      (Scenario_lifestyle == "Affordability" & Income_group == "Lower-income")
  ) %>%
  mutate(
    Group_label = case_when(
      Scenario_lifestyle == "Ecoactive"    & Income_group == "Higher-income"   ~
        "Ecoactive\nHigher-income",
      Scenario_lifestyle == "Ecoactive"    & Income_group == "Medium-income" ~
        "Ecoactive\nMedium-income",
      Scenario_lifestyle == "Affordability" & Income_group == "Lower-income"    ~
        "Affordability\nLower-income"
    ),
    Elasticity_rounded = round(Elasticity, 1)
  ) %>%
  group_by(Scenario_lifestyle, Income_group, Group_label, Elasticity_rounded) %>%
  summarise(effort_gap = mean(effort_gap), .groups = "drop")

heatmap_filtered$Group_label <- factor(heatmap_filtered$Group_label,
                                       levels = c("Ecoactive\nHigher-income",
                                                  "Ecoactive\nMedium-income",
                                                  "Affordability\nLower-income"))

max_effort <- max(heatmap_filtered$effort_gap, na.rm = TRUE)
if (!is.finite(max_effort)) max_effort <- 1

heatmap_filtered <- heatmap_filtered %>%
  mutate(
    effort_norm = effort_gap / max_effort,
    fill_color  = case_when(
      Scenario_lifestyle == "Ecoactive" ~ rgb(
        red   = 1 - effort_norm * (1 - 0.13),
        green = 1 - effort_norm * (1 - 0.40),
        blue  = 1 - effort_norm * (1 - 0.67)
      ),
      Scenario_lifestyle == "Affordability" ~ rgb(
        red   = 1 - effort_norm * (1 - 0.70),
        green = 1 - effort_norm * (1 - 0.09),
        blue  = 1 - effort_norm * (1 - 0.17)
      )
    )
  )

heatmap_filtered$effort_for_legend <- heatmap_filtered$effort_gap

h_combined <- ggplot(heatmap_filtered,
                     aes(x = factor(Elasticity_rounded), y = Group_label)) +
  geom_tile(aes(fill = fill_color), color = "white", linewidth = 0) +
  scale_fill_identity() +
  geom_point(aes(color = effort_for_legend), alpha = 0, size = 0) +
  scale_color_gradient(
    low    = "white", high = "grey20",
    name   = "Behavioural effort",
    breaks = c(0, max_effort / 2, max_effort),
    labels = c("Lower", "Medium", "Higher"),
    guide  = guide_colorbar(direction      = "vertical",
                            title.position = "top",
                            barwidth       = 0.6,
                            barheight      = 3)
  ) +
  geom_text(aes(label = sprintf("%.2f", effort_gap)),
            color = "black", size = 2.5) +
  scale_y_discrete(labels = c(
    "Ecoactive\nHigher-income"   = expression(atop(bold("Ecoactive"),    "Higher-income")),
    "Ecoactive\nMedium-income" = expression(atop(bold("Ecoactive"),    "Medium-income")),
    "Affordability\nLower-income" = expression(atop(bold("Affordability"), "Lower-income"))
  )) +
  labs(x = "Substitution elasticity", y = NULL, title = "") +
  theme_nature() +
  theme(
    axis.text.x       = element_text(hjust = 0.5, size = 8),
    axis.text.y       = element_text(size = 9),
    axis.title.x      = element_text(vjust = 0, margin = margin(t = 5, b = 10)),
    panel.grid        = element_blank(),
    panel.border      = element_blank(),
    panel.background  = element_blank(),
    plot.background   = element_blank(),
    legend.position   = "right",
    legend.direction  = "vertical",
    legend.key.height = unit(0.8, "cm"),
    legend.key.width  = unit(0.3, "cm"),
    legend.title      = element_text(size = 9, face = "bold"),
    legend.text       = element_text(size = 9),
    legend.margin     = margin(0, 0, 0, 0),
    plot.margin       = margin(0, 50, 0, 50)
  ) +
  coord_cartesian(clip = "off")

p3 <- ggplot(deriv_raw, aes(x = row_idx)) +
  geom_line(aes(y = first_d,  color = "First Derivative"),  linewidth = 0.5) +
  geom_line(aes(y = second_d, color = "Second Derivative"), linewidth = 0.5) +
  geom_vline(xintercept = ub_x, linetype = "dashed",
             color = "red", linewidth = 0.5) +
  annotate("text", x = ub_x + 0.5,
           y = ub_y + 0.005,
           label = "Upper bound", color = "red",
           size = 2.5, hjust = -0.1, vjust = -2) +
  scale_x_continuous(breaks = sigma_breaks, labels = sigma_labels) +
  scale_color_manual(values = c("First Derivative"  = "blue",
                                "Second Derivative" = "green"),
                     name = "Derivative Type") +
  labs(x     = "Substitution elasticity",
       y = expression(Delta * " Behavioural modifier"),
       title = "") +
  theme_nature() +
  theme(
    axis.title.y = element_text(vjust = 4,  margin = margin(r = -10)),
    axis.title.x = element_text(vjust = -3, margin = margin(r = -10))
  )

h_wrapped  <- plot_spacer() + h_combined + plot_spacer() +
  plot_layout(widths = c(1, 500, 1))
p3_wrapped <- plot_spacer() + p3 + plot_spacer() +
  plot_layout(widths = c(1, 2, 1))

combined <- top_row / h_wrapped / p3_wrapped +
  plot_layout(heights = c(5.5, 2, 1.5)) +
  plot_annotation(tag_levels = "a") &
  theme(plot.tag = element_text(size = 12, face = "bold"))

combined