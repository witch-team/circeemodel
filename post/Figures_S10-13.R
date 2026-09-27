library(tidyverse); library(patchwork)

ZEN  <- path.expand("~/Desktop/Paper_Rethink_Results/data_zenodo")
MAIN <- file.path(ZEN, "data_figures_maintext_&_si")
SENS <- file.path(ZEN, "data_figures_sensitivity")
OUT  <- path.expand("~/Desktop/Paper_Rethink_Results/figures")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

drivers <- c("ecoactive_ecoactive", "affordability_affordability")
driver_lbl <- c(ecoactive_ecoactive = "Ecoactive - All",
                affordability_affordability = "Affordability - All")
pal_ls <- c("Ecoactive - All" = "#1B7837", "Affordability - All" = "#762A83")

settings <- tribble(
  ~tag,        ~setting,
  NA,          "Calibrated",
  "HABIT045",  "Habit 0.45",
  "HABIT065",  "Habit 0.65",
  "SIGMAC130", "Elasticity 1.3",
  "SIGMAC160", "Elasticity 1.6")
set_levels <- c("Habit 0.45", "Calibrated", "Habit 0.65", "Elasticity 1.3", "Elasticity 1.6")

pick <- function(...) { p <- file.path(...); f <- sub("\\.csv$", "_CFfix.csv", p)
if (file.exists(f)) f else p }

scen_path <- function(ls, tag) {
  if (is.na(tag)) {
    file.path(MAIN, "Outputs/CIRCEE_output_levels", paste0(ls, "_AE_Baseline.csv"))
  } else {
    pick(SENS, "Outputs/CIRCEE_output_levels", paste0(ls, "_AE_Baseline_", tag, ".csv"))
  }
}

ref_path <- function(tag) {
  if (is.na(tag)) {
    file.path(MAIN, "Outputs/CIRCEE_output_levels", "NoModifiers_AE.csv")
  } else {
    pick(SENS, "Outputs/NoModifiers_levels", paste0("NoModifiers_", tag, ".csv"))
  }
}

wel_path <- function(ls, tag) {
  if (is.na(tag)) {
    file.path(MAIN, "Welfare", paste0(ls, "_AE"), "welfare_CEV_lifetime.csv")
  } else {
    file.path(SENS, "Welfare", paste0(ls, "_AE_Baseline_", tag), "welfare_CEV_lifetime.csv")
  }
}

lev <- function(p) { d <- read.csv(p, check.names = FALSE); d[!duplicated(d$Row), ] }
gv  <- function(d, row, yr = 2050) {
  x <- d[d$Row == row, paste0("Y", yr)]
  if (!length(x)) NA_real_ else as.numeric(x)
}
nhh <- function(d, g, yr = 2050) gv(d, paste0("CF_", g), yr) /
  gv(d, paste0("CF_", g, "_percapita"), yr)

rows <- list()
for (ls in drivers) for (i in seq_len(nrow(settings))) {
  tag <- settings$tag[i]; set <- settings$setting[i]
  ps <- scen_path(ls, tag); pr <- ref_path(tag)
  if (!file.exists(ps) || !file.exists(pr)) { message("missing: ", ps); next }
  s <- lev(ps); r <- lev(pr)
  
  pct  <- function(k) 100 * (gv(s, k) / gv(r, k) - 1)
  pcap <- function(pre, g) 100 * ((gv(s, paste0(pre, "_", g)) / nhh(s, g)) /
                                    (gv(r, paste0(pre, "_", g)) / nhh(r, g)) - 1)
  inv  <- function(d) sum(sapply(c("constrained","cautious","lowcarbon"),
                                 function(g) gv(d, paste0("Inv_ed_new_tild_", g))))
  pss  <- function(d, g) {
    a <- gv(d, "p_sharing") * gv(d, paste0("ES_sharing_", g))
    b <- gv(d, paste0("p_home_", g)) * gv(d, paste0("ES_home_", g))
    100 * a / (a + b)
  }
  acc  <- function(d) {
    (gv(d, "ES_constrained") / nhh(d, "constrained")) /
      (gv(d, "ES_lowcarbon")   / nhh(d, "lowcarbon"))
  }
  
  cev <- c(NA_real_, NA_real_)
  wp <- wel_path(ls, tag)
  if (file.exists(wp)) {
    w <- read.csv(wp, check.names = FALSE)
    w <- w[trimws(w[[1]]) == "Baseline", , drop = FALSE]
    if (nrow(w)) cev <- c(as.numeric(w$CEV_lifetime_constrained),
                          as.numeric(w$CEV_lifetime_aggregate))
  }
  
  rows[[length(rows)+1]] <- tibble(
    driver = driver_lbl[ls], setting = set,
    `Refuse (new durables)`        = 100*(inv(s)/inv(r) - 1),
    `PSS share of ES spending`     = pss(s, "constrained"),
    `Carbon footprint, lower inc.` = pcap("CF","constrained"),
    `Waste footprint, lower inc.`  = pcap("WF","constrained"),
    `Material footprint, lower inc.`= pcap("MF","constrained"),
    `CO2 emissions`                = pct("CO2"),
    `Domestic material consumption`= pct("DMC"),
    `In-use material stock`        = pct("M_stock"),
    `Access ratio (low/high)`      = acc(s),
    `Lifetime CEV, lower income`   = cev[1],
    `Lifetime CEV, aggregate`      = cev[2])
}
D <- bind_rows(rows) %>%
  mutate(driver  = factor(driver, levels = driver_lbl),
         setting = factor(setting, levels = set_levels),
         calib   = setting == "Calibrated")

mk <- function(vars, ttl, sub, ylab, file, ncol = 2, hline = 0) {
  d <- D %>% select(driver, setting, calib, all_of(vars)) %>%
    pivot_longer(all_of(vars), names_to = "indicator", values_to = "value") %>%
    mutate(indicator = factor(indicator, levels = vars))
  p <- ggplot(d, aes(setting, value, colour = driver, group = driver)) +
    (if (!is.na(hline)) geom_hline(yintercept = hline, colour = "grey75", linewidth = 0.3)
     else geom_blank()) +
    geom_line(linewidth = 0.4, alpha = 0.6) +
    geom_point(aes(shape = calib, size = calib), fill = "white", stroke = 0.7) +
    facet_wrap(~ indicator, ncol = ncol, scales = "free_y") +
    scale_colour_manual("Lifestyle driver", values = pal_ls) +
    scale_shape_manual(values = c(`FALSE` = 21, `TRUE` = 23), guide = "none") +
    scale_size_manual(values  = c(`FALSE` = 1.8, `TRUE` = 2.8), guide = "none") +
    labs(title = ttl, subtitle = sub, x = NULL, y = ylab,
         caption = paste("Diamonds: calibrated run (habit persistence 0.55, elasticity of substitution\nbetween energy services and other consumption 0.98).",
                         "Each cell is compared with its own zero-modifier reference.")) +
    theme_minimal(base_size = 9) +
    theme(panel.grid.minor = element_blank(),
          strip.text = element_text(face = "bold", size = 8),
          axis.text.x = element_text(size = 7),
          legend.position = "bottom",
          plot.caption = element_text(hjust = 0, size = 7, colour = "grey30"))
  ggsave(file.path(OUT, paste0(file, ".pdf")), p, width = 7.5,
         height = 2 + 2.2*ceiling(length(vars)/ncol), device = "pdf")
  ggsave(file.path(OUT, paste0(file, ".png")), p, width = 7.5,
         height = 2 + 2.2*ceiling(length(vars)/ncol), dpi = 600)
  p
}

p2 <- mk(c("Refuse (new durables)", "PSS share of ES spending"),
         "Sensitivity of engagement (Fig. 2 indicators)",
         "2050. Refuse: % vs reference. PSS share: % of energy-service spending, lower income.",
         NULL, "figS_sens_fig2")

p3 <- mk(c("Carbon footprint, lower inc.", "Waste footprint, lower inc.",
           "Material footprint, lower inc."),
         "Sensitivity of per-household footprints (Fig. 3 indicators)",
         "2050, lower-income group, % vs each cell's own reference.",
         "% vs reference", "figS_sens_fig3")

p4 <- mk(c("CO2 emissions", "Domestic material consumption", "In-use material stock"),
         "Sensitivity of economy-wide flows (Fig. 4 indicators)",
         "2050, % vs each cell's own reference.",
         "% vs reference", "figS_sens_fig4")

p5 <- mk(c("Access ratio (low/high)", "Lifetime CEV, lower income",
           "Lifetime CEV, aggregate"),
         "Sensitivity of access and welfare (Fig. 5 indicators)",
         "Access ratio in levels; CEV in % of lifetime consumption.",
         NULL, "figS_sens_fig5", hline = NA)

write_csv(D, file.path(OUT, "table_sensitivity_indicators.csv"))
message("Wrote to ", OUT, ":\n  ",
        paste(list.files(OUT, pattern = "sens_fig|sensitivity_indicators"), collapse = "\n  "))
print(D, width = Inf)