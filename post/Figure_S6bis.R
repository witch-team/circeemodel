library(tidyverse)
library(ggrepel)

stopifnot(exists("accessA2"), exists("welfare_ineq"), exists("theme_ns"))

read_levels <- function(path) {
  d <- read.csv(path, check.names = FALSE); d[!duplicated(d$Row), ]
}
val <- function(d, row, yr) { x <- as.numeric(d[d$Row == row, paste0("Y", yr)])
if (!length(x)) NA_real_ else x }
n_households <- function(d, g, yr) val(d, paste0("CF_", g), yr) / val(d, paste0("CF_", g, "_percapita"), yr)

wf_total <- function(path, yr = 2050) {
  if (!file.exists(path)) return(NA_real_)
  d <- read_levels(path)
  g <- c("constrained", "cautious", "lowcarbon")
  sum(vapply(g, function(x) val(d, paste0("WF_", x, "_percapita"), yr) * n_households(d, x, yr), numeric(1)))
}

access_ratio_yr <- function(path, yr) {
  d <- read_levels(path)
  (val(d, "ES_constrained", yr) / n_households(d, "constrained", yr)) /
    (val(d, "ES_lowcarbon",  yr) / n_households(d, "lowcarbon",  yr))
}

ref_path      <- file.path(levels_dir, paste0("NoModifiers_", foresight, ".csv"))
wf_ref        <- wf_total(ref_path, 2050)
wf_ref_2020   <- wf_total(ref_path, 2020)
access_2020   <- access_ratio_yr(ref_path, 2020)
access_2050_r <- access_ratio_yr(ref_path, 2050)
message(sprintf("Reference: waste %.1f Mt (2020) -> %.1f Mt (2050); access ratio %.2f (2020) -> %.2f (2050)",
                wf_ref_2020 / 1e12, wf_ref / 1e12, access_2020, access_2050_r))

tri_levels <- levels(accessA2$Scenario)
tri_labels <- c("Current", "Concentrated", "Broad")
tri_shapes <- setNames(c(21, 24, 23), tri_levels)
stopifnot(length(tri_levels) == 3)

ls_labels_ref <- levels(accessA2$lifestyle)
stopifnot(length(ls_labels_ref) == length(lifestyles))

waste_out <- expand_grid(lifestyle_token = lifestyles, Scenario = tri_levels) %>%
  mutate(wf_tot  = map2_dbl(lifestyle_token, Scenario,
                            ~ wf_total(file.path(levels_dir,
                                                 paste0(.x, "_", foresight, "_", .y, ".csv")))),
         wst_pct = wf_tot / wf_ref - 1,
         # token -> label, positionally, using the reference levels
         lifestyle = factor(lifestyle_token, levels = lifestyles, labels = ls_labels_ref),
         Scenario  = factor(Scenario, levels = tri_levels))

trilemma_wf <- waste_out %>%
  left_join(accessA2 %>%
              filter(ratio == "low/high", year == max(ratio_years)) %>%
              select(lifestyle, Scenario, access_ratio = value),
            by = c("lifestyle", "Scenario")) %>%
  left_join(welfare_ineq %>% select(lifestyle, Scenario, spread),
            by = c("lifestyle", "Scenario")) %>%
  mutate(scen_lab = factor(Scenario, levels = tri_levels, labels = tri_labels))

stopifnot(nrow(trilemma_wf) == length(lifestyles) * length(tri_levels))

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
  annotate("text", x = 1, y = Inf, vjust = 1.4, hjust = 1.05, size = 2.4,
           colour = "grey40", label = "equal access") +
  geom_vline(xintercept = access_2020, linetype = "solid", colour = "grey75", linewidth = 0.4) +
  annotate("text", x = access_2020, y = Inf, vjust = 1.4, hjust = -0.05, size = 2.4,
           colour = "grey40", label = sprintf("2020: %.2f", access_2020)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60", linewidth = 0.4) +
  geom_point(aes(shape = Scenario, fill = lifestyle, size = spread),
             colour = "grey20", stroke = 0.4) +
  geom_text_repel(aes(label = scen_lab), size = 2.5, colour = "grey25",
                  seed = 1, segment.colour = NA,
                  box.padding = 0.45, point.padding = 0.7,
                  force = 1.5, force_pull = 0.6,
                  max.overlaps = Inf, max.time = 1.5, max.iter = 50000) +
  scale_shape_manual(values = tri_shapes, breaks = tri_levels,
                     labels = tri_labels, guide = "none") +
  scale_fill_manual(values = pal_ls, name = "Behaviour") +
  scale_x_continuous(labels = scales::number_format(accuracy = 0.01)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.01),
                     limits = c(-1, 1) * wst_lim,
                     breaks = seq(-1, 1, by = 0.5) * wst_lim) +
  guides(fill = guide_legend(order = 1, nrow = 1,
                             override.aes = list(shape = 21, size = 3.5)),
         size = guide_legend(order = 2, nrow = 1,
                             override.aes = list(shape = 21, fill = "grey70"))) +
  scale_size_continuous(range = c(2, 5.5), breaks = c(1, 2, 3),
                        name = "Welfare gap between best- and worst-off\nlifestyle group (lifetime CEV, p.p.)") +
  labs(title = "Waste footprint, access equity and welfare gap in 2050",
       subtitle = paste0("Down = lower waste footprint; right = more equal access; larger = wider welfare gap.\n",
                         sprintf("Reference waste footprint: %.0f Mt in 2020, %.0f Mt in 2050.",
                                 wf_ref_2020 / 1e12, wf_ref / 1e12)),
       x = "Access equity (energy services per household, lower- / higher-income lifestyle group, 2050)",
       y = "Change in waste footprint vs. Reference") +
  theme_ns() +
  theme(legend.position = "bottom", legend.box = "vertical",
        legend.box.just = "left")

pdf_path <- file.path(out_dir, "figS_trilemma_waste.pdf")
ggsave(pdf_path, g_trilemma_wf, width = 7.5, height = 6.5, device = "pdf")
if (!file.exists(pdf_path)) warning("PDF was not written: ", pdf_path)
ggsave(file.path(out_dir, "figS_trilemma_waste.png"), g_trilemma_wf,
       width = 7.5, height = 6.5, dpi = 600)

write_csv(trilemma_wf %>%
            select(lifestyle, Scenario, access_ratio, waste_pct = wst_pct,
                   cev_spread = spread),
          file.path(out_dir, "table_trilemma_waste_supplementary.csv"))

message("Wrote to ", normalizePath(out_dir), ":\n  ",
        paste(list.files(out_dir, pattern = "trilemma_waste"), collapse = "\n  "))
