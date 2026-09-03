library(tidyverse)
library(ggrepel)

stopifnot(exists("accessA2"), exists("welfare_ineq"), exists("theme_ns"))

wf_total_2050 <- function(path) {
  if (!file.exists(path)) return(NA_real_)
  d  <- read.csv(path, check.names = FALSE); d <- d[!duplicated(d$Row), ]
  yc <- grep("^Y[0-9]{4}$", names(d), value = TRUE)
  g1 <- function(v) { x <- as.numeric(d[d$Row == v, yc])
  if (!length(x)) NA_real_ else x[yc == "Y2050"] }
  g  <- c("constrained", "cautious", "lowcarbon")
  N  <- vapply(paste0("CF_", g), g1, numeric(1)) /
    vapply(paste0("CF_", g, "_percapita"), g1, numeric(1))
  sum(vapply(paste0("WF_", g, "_percapita"), g1, numeric(1)) * N)
}

wf_ref <- wf_total_2050(file.path(levels_dir, paste0("NoModifiers_", foresight, ".csv")))

ls_labels_ref <- levels(accessA2$lifestyle)
stopifnot(length(ls_labels_ref) == length(lifestyles))

waste_out <- expand_grid(lifestyle_token = lifestyles, Scenario = scen_levels) %>%
  mutate(wf_tot  = map2_dbl(lifestyle_token, Scenario,
                            ~ wf_total_2050(file.path(levels_dir,
                                                      paste0(.x, "_", foresight, "_", .y, ".csv")))),
         wst_pct = wf_tot / wf_ref - 1,
         # token -> label, positionally, using the reference levels
         lifestyle = factor(lifestyle_token, levels = lifestyles, labels = ls_labels_ref),
         Scenario  = factor(Scenario, levels = scen_levels))

trilemma_wf <- waste_out %>%
  left_join(accessA2 %>%
              filter(ratio == "low/high", year == max(ratio_years)) %>%
              select(lifestyle, Scenario, access_ratio = value),
            by = c("lifestyle", "Scenario")) %>%
  left_join(welfare_ineq %>% select(lifestyle, Scenario, spread),
            by = c("lifestyle", "Scenario")) %>%
  mutate(scen_lab = factor(Scenario, levels = scen_levels, labels = scen_labels))

stopifnot(nrow(trilemma_wf) == length(lifestyles) * length(scen_levels))

n_bad <- sum(is.na(trilemma_wf$wst_pct) | is.na(trilemma_wf$access_ratio) |
               is.na(trilemma_wf$spread))
if (n_bad > 0) {
  message("waste trilemma: ", n_bad, " of ", nrow(trilemma_wf),
          " rows incomplete - check that lifestyle levels match:")
  print(trilemma_wf %>% filter(is.na(access_ratio) | is.na(spread) | is.na(wst_pct)) %>%
          select(lifestyle, Scenario, wst_pct, access_ratio, spread))
}

wst_lim <- ceiling(max(abs(trilemma_wf$wst_pct), na.rm = TRUE) * 1000) / 1000

g_trilemma_wf <- ggplot(trilemma_wf, aes(access_ratio, wst_pct)) +
  geom_vline(xintercept = 1, linetype = "dotted", colour = "grey60", linewidth = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60", linewidth = 0.4) +
  geom_point(aes(shape = Scenario, fill = lifestyle, size = spread),
             colour = "grey20", stroke = 0.4) +
  geom_text_repel(aes(label = scen_lab), size = 2.5, colour = "grey25",
                  seed = 1, segment.colour = NA,
                  box.padding = 0.45, point.padding = 0.7,
                  force = 1.5, force_pull = 0.6,
                  max.overlaps = Inf, max.time = 1.5, max.iter = 50000) +
  scale_shape_manual(values = scen_shapes, breaks = scen_levels,
                     labels = scen_labels, guide = "none") +
  scale_fill_manual(values = pal_ls, name = "Behaviour") +
  scale_x_continuous(labels = scales::number_format(accuracy = 0.01)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1),
                     limits = c(-1, 1) * wst_lim,
                     breaks = seq(-1, 1, by = 0.5) * wst_lim) +
  guides(fill = guide_legend(order = 1, nrow = 1,
                             override.aes = list(shape = 21, size = 3.5)),
         size = guide_legend(order = 2, nrow = 1,
                             override.aes = list(shape = 21, fill = "grey70"))) +
  scale_size_continuous(range = c(2, 5.5), breaks = c(1, 2, 3),
                        name = "Welfare spread (max \u2212 min CEV, p.p.)") +
  labs(title = "The trilemma, waste footprint",
       subtitle = "Down = lower waste footprint; right = more equal access; larger = wider welfare gap",
       x = "Access equity (lower/higher-income access ratio, 2050)",
       y = "Waste footprint vs. reference run") +
  theme_ns() +
  theme(legend.position = "bottom", legend.box = "vertical",
        legend.box.just = "left")

ggsave(file.path(out_dir, "figS_trilemma_waste.pdf"), g_trilemma_wf,
       width = 7.5, height = 6.5, device = "pdf")
ggsave(file.path(out_dir, "figS_trilemma_waste.png"), g_trilemma_wf,
       width = 7.5, height = 6.5, dpi = 300)

write_csv(trilemma_wf %>%
            select(lifestyle, Scenario, access_ratio, waste_pct = wst_pct,
                   cev_spread = spread),
          file.path(out_dir, "table_trilemma_waste_supplementary.csv"))

message("Wrote figS_trilemma_waste.{pdf,png} and table_trilemma_waste_supplementary.csv")