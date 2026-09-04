data_dir        <- "~/Desktop/Paper_Rethink_Results/data_zenodo"
out_dir_default <- "~/Desktop/Paper_Rethink_Results/figures"

library(tidyverse)
library(patchwork)
library(gridExtra)
library(grid)
library(gtable)

welfare_dir <- file.path(data_dir, "Welfare")
out_dir     <- out_dir_default
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

foresight  <- "AE"
lifestyles <- c("ecoactive_ecoactive", "affordability_affordability",
                "ecoactive_affordability", "affordability_ecoactive")

scen_levels <- c("Baseline", "Regressive", "Progressive")
scen_labels <- c("BAU", "Regressive", "Progressive")

lifestyle_labels <- c(
  ecoactive_ecoactive         = "Ecoactive - All",
  affordability_affordability = "Affordability - All",
  ecoactive_affordability     = " Ecoactive - Sharing \n Affordability - Sufficiency",
  affordability_ecoactive     = " Affordability - Sharing \n Ecoactive - Sufficiency")

group_levels <- c("Lower", "Med", "Higher")
group_labels <- c("Lower income", "Medium income", "Higher income")

pal_sigma <- c(
  "Baseline"           = "#d98ca8",
  "Regressive"  = "#156082",
  "Progressive" = "#66913f")
names(pal_sigma) <- scen_levels

pal_ls <- c("Ecoactive - All"                                     = "#1B7837",
            "Affordability - All"                                  = "#762A83",
            " Ecoactive - Sharing \n Affordability - Sufficiency" = "#E08214",
            " Affordability - Sharing \n Ecoactive - Sufficiency" = "#2166AC")

theme_ns <- function(base = 9) {
  theme_minimal(base_size = base) +
    theme(
      text             = element_text(color = "#1A1A1A"),
      plot.title       = element_text(size = base + 1, face = "bold", hjust = 0,
                                      margin = margin(b = 1)),
      plot.subtitle    = element_text(size = base, color = "#4D4D4D",
                                      margin = margin(b = 5)),
      axis.title       = element_text(size = base),
      axis.text        = element_text(size = base - 1, color = "#4D4D4D"),
      strip.text       = element_text(size = base, face = "bold", color = "#1A1A1A",
                                      margin = margin(2, 2, 2, 2)),
      panel.grid.minor = element_line(color = "white", linewidth = 0.25),
      panel.grid.major = element_line(color = "white", linewidth = 0.5),
      panel.spacing    = unit(0.6, "lines"),
      legend.position  = "bottom",
      legend.title     = element_text(size = base, face = "bold"),
      legend.text      = element_text(size = base),
      legend.key.width = unit(0.8, "cm"),
      legend.key.height= unit(0.3, "cm"),
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "#EBEBEB", color = NA),
      strip.background = element_blank()
    )
}

save_fig <- function(fig, name, w, h) {
  ggsave(file.path(out_dir, paste0(name, ".pdf")), fig, width = w, height = h, device = "pdf")
  ggsave(file.path(out_dir, paste0(name, ".png")), fig, width = w, height = h, dpi = 300)
  message("Saved: ", name)
}

load_welfare <- function(filename) {
  map_dfr(lifestyles, function(ls) {
    path <- file.path(welfare_dir, paste0(ls, "_", foresight), filename)
    if (!file.exists(path)) { message("Missing: ", path); return(NULL) }
    read_csv(path, show_col_types = FALSE) %>% mutate(lifestyle = ls)
  })
}

set_factors <- function(d) d %>%
  mutate(lifestyle = factor(lifestyle, levels = lifestyles,
                            labels = lifestyle_labels[lifestyles]))

keep_scen_fac <- function(d) d %>%
  filter(Scenario %in% scen_levels) %>%
  mutate(Scenario = factor(Scenario, levels = scen_levels)) %>%
  set_factors()

snap_years <- c(2025, 2030, 2035, 2040, 2045, 2050)

message("Loading welfare CSVs (AE)...")
es_dist_raw <- load_welfare("welfare_ES_distribution.csv")

levels_dir  <- file.path(data_dir, "Outputs", "CIRCEE_output_levels")
shocks_csv  <- "~/Desktop/circee_clonetest/data/JPN/raw/shocks.csv"
es_rows     <- c("ES_constrained", "ES_cautious", "ES_lowcarbon")
es_years    <- c("Y2025","Y2030","Y2035","Y2040","Y2045","Y2050")
ratio_years <- c(2025, 2035, 2050)
ratio_levels <- c("low/high", "low/med", "med/high")
pal_ratio    <- c("low/high" = "#1a1a1a",
                  "low/med"  = "#0F8B8D",
                  "med/high" = "#8a5a2b")

omega_raw <- read.csv(shocks_csv, sep = ";", header = FALSE,
                      stringsAsFactors = FALSE,
                      col.names = c("Variable","Region","Year","Value"))
omega_tab <- omega_raw %>%
  filter(Variable %in% c("omegga_lowcarbon","omegga_cautious")) %>%
  transmute(Variable, year = as.integer(Year), Value = as.numeric(Value)) %>%
  pivot_wider(names_from = Variable, values_from = Value) %>%
  transmute(year,
            omega_lowcarbon   = omegga_lowcarbon,
            omega_cautious    = omegga_cautious,
            omega_constrained = 1 - omegga_lowcarbon - omegga_cautious)

read_es_levels <- function(path) {
  d <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  d <- d[!duplicated(d$Row), ]
  d[d$Row %in% es_rows, c("Row", es_years)] %>%
    pivot_longer(all_of(es_years), names_to = "Year", values_to = "level") %>%
    mutate(year = as.integer(str_remove(Year, "^Y"))) %>%
    select(Row, year, level) %>%
    pivot_wider(names_from = Row, values_from = level) %>%
    left_join(omega_tab, by = "year") %>%
    mutate(
      ES_lowcarbon   = ES_lowcarbon   / omega_lowcarbon,
      ES_cautious    = ES_cautious    / omega_cautious,
      ES_constrained = ES_constrained / omega_constrained
    ) %>%
    select(year, ES_constrained, ES_cautious, ES_lowcarbon)
}

make_ratios <- function(d) d %>%
  mutate(`low/high` = ES_constrained / ES_lowcarbon,
         `low/med`  = ES_constrained / ES_cautious,
         `med/high` = ES_cautious   / ES_lowcarbon) %>%
  select(any_of(c("lifestyle","Scenario")), year,
         `low/high`, `low/med`, `med/high`) %>%
  pivot_longer(c(`low/high`, `low/med`, `med/high`),
               names_to = "ratio", values_to = "value")

ratio_scen <- map_dfr(lifestyles, function(ls) {
  map_dfr(scen_levels, function(sc) {
    path <- file.path(levels_dir, paste0(ls, "_", foresight, "_", sc, ".csv"))
    if (!file.exists(path)) { message("Missing: ", path); return(NULL) }
    read_es_levels(path) %>% mutate(lifestyle = ls, Scenario = sc)
  })
})

nomod_es <- read_es_levels(
  file.path(levels_dir, paste0("NoModifiers_", foresight, ".csv")))

accessA2 <- make_ratios(ratio_scen) %>%
  filter(year %in% ratio_years, Scenario %in% scen_levels,
         ratio %in% ratio_levels) %>%
  mutate(ratio    = factor(ratio, levels = ratio_levels),
         Scenario = factor(Scenario, levels = scen_levels)) %>%
  set_factors()

accessA_nomod <- make_ratios(nomod_es) %>%
  filter(year %in% ratio_years, ratio %in% ratio_levels) %>%
  mutate(ratio = factor(ratio, levels = ratio_levels))

cev_life <- load_welfare("welfare_CEV_lifetime.csv")
panelB_df <- cev_life %>%
  filter(Scenario %in% scen_levels) %>%
  select(lifestyle, Scenario,
         Lower = CEV_lifetime_constrained,
         Med = CEV_lifetime_cautious,
         Higher = CEV_lifetime_lowcarbon) %>%
  pivot_longer(c(Lower, Med, Higher), names_to = "group", values_to = "cev") %>%
  mutate(group = factor(group, levels = group_levels, labels = group_labels),
         Scenario = factor(Scenario, levels = scen_levels)) %>%
  set_factors()

tidy_dist <- function(df, prefix) {
  df %>%
    pivot_longer(matches(paste0("^", prefix, "_")), names_to = "name", values_to = "value") %>%
    mutate(stub = str_remove(name, paste0("^", prefix, "_")),
           year = suppressWarnings(as.integer(str_extract(stub, "\\d{4}$"))),
           metric = str_remove(stub, "_?\\d{4}$")) %>%
    select(lifestyle, Scenario, metric, year, value)
}

fp_specs <- list(
  ES  = "welfare_ES_distribution.csv",
  CF  = "welfare_CF_distribution.csv",
  MF  = "welfare_MF_distribution.csv",
  EXP = "welfare_expenditure_distribution.csv")
fp_labels <- c(ES = "Energy services", CF = "Carbon", MF = "Material",
               EXP = "Consumption")

dist_all <- imap_dfr(fp_specs, function(fname, pref) {
  raw <- load_welfare(fname)
  if (is.null(raw) || !nrow(raw)) { message("Missing footprint file: ", fname); return(NULL) }
  if (pref == "EXP") raw <- raw %>% rename_with(~ paste0("EXP_", .x),
                                                .cols = matches("^(Gini|Palma|Atkinson)"))
  tidy_dist(raw, pref) %>% mutate(footprint = fp_labels[[pref]])
})

footprint_levels <- c("Energy services", "Carbon", "Material")
kf <- function(d) d %>%
  filter(Scenario %in% scen_levels) %>%
  mutate(Scenario  = factor(Scenario, levels = scen_levels),
         footprint = factor(footprint, levels = footprint_levels)) %>%
  set_factors()

dist_all <- dist_all %>% filter(footprint != "Consumption")  
carbon_material_supp <- dist_all %>%
  filter(footprint %in% c("Carbon", "Material"), year == 2050,
         metric %in% c("Gini", "Palma")) %>%
  rename(measure = metric) %>%
  mutate(Scenario = factor(Scenario, levels = scen_levels, labels = scen_labels)) %>%
  filter(!is.na(Scenario)) %>%
  set_factors() %>%
  arrange(footprint, measure, lifestyle, Scenario)
write_csv(carbon_material_supp, file.path(out_dir, "table_carbon_material_inequality_supplementary.csv"))

gp <- dist_all %>%
  filter(year == 2050, metric %in% c("Gini", "Palma"), footprint == "Energy services") %>%
  rename(measure = metric) %>%
  mutate(footprint = factor(footprint, levels = "Energy services")) %>%
  kf()

scen_shapes <- c(21, 24, 23, 22)
scen_fills  <- c("white", "white", "white", "white")
names(scen_shapes) <- scen_levels
names(scen_fills)  <- scen_levels

scen_shape_scale <- scale_shape_manual(
  values = scen_shapes, breaks = scen_levels, labels = scen_labels,
  name = "Infrastructures (substitution elasticity)",
  guide = guide_legend(order = 2,
                       override.aes = list(fill = "white", color = "black")))

# ---- Panel A ---------------------------------------------------------------
ratio_color <- scale_color_manual(
  values = pal_ratio, breaks = ratio_levels, name = "Lifestyle pair",
  guide = guide_legend(order = 1,
                       override.aes = list(linetype = 1, shape = NA, linewidth = 1.4, alpha = 1)))

pA <- ggplot(accessA2,
             aes(year, value, color = ratio,
                 group = interaction(ratio, Scenario))) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 1,
           fill = "#EBEBEB", alpha = 1) +                  
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 1, ymax = Inf,
           fill = "#E3EEF2", alpha = 1) +                      
  geom_hline(yintercept = seq(0.6, 1.1, 0.1),  color = "white", linewidth = 0.5) + 
  geom_hline(yintercept = seq(0.65, 1.05, 0.1), color = "white", linewidth = 0.25) + 
  geom_vline(xintercept = c(2025, 2035, 2050), color = "white", linewidth = 0.5) +   
  geom_hline(yintercept = 1, color = "white", linewidth = 0.9) +                    
  geom_line(data = accessA_nomod,
            aes(year, value, group = ratio, color = ratio),
            inherit.aes = FALSE, linetype = "dashed",
            linewidth = 0.45, alpha = 0.55, show.legend = FALSE) +
  geom_line(linewidth = 0.5, alpha = 0.85,
            show.legend = c(colour = TRUE, shape = FALSE)) +
  geom_point(aes(shape = Scenario), size = 1.9, stroke = 0.8, fill = "white",
             show.legend = c(colour = FALSE, shape = TRUE)) +
  facet_wrap(~ lifestyle, nrow = 1) +
  scale_x_continuous(breaks = c(2025, 2035, 2050)) +
  ratio_color + scen_shape_scale +
  labs(title = "a. Per-household energy-service access ratios by lifestyle pair",
       subtitle = "Dashed = reference run with no lifestyle heterogeneity and BAU infrastructures",
       x = NULL, y = "Access ratio (per household)") +
  theme_ns() +
  theme(panel.grid = element_blank(), 
        panel.background = element_blank())

pB <- ggplot(panelB_df, aes(x = group, y = cev, group = Scenario)) +
  geom_hline(yintercept = 0, color = "#9A9A9A", linewidth = 0.4, linetype = "dashed") +
  geom_point(aes(shape = Scenario), color = "black", fill = "white",
             size = 2.2, stroke = 0.7,
             position = position_dodge(width = 0.55)) +
  facet_wrap(~ lifestyle, nrow = 1) +
  scen_shape_scale +
  guides(shape = "none") +
  labs(title = "b. Lifetime CEV by lifestyle group in comparison to the reference run",
       x = NULL, y = "Lifetime CEV (%)") +
  theme_ns() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ls_fill <- scale_fill_manual(values = pal_ls, name = "Behaviour")
xlabs <- setNames(scen_labels, scen_levels)

welfare_ineq <- cev_life %>%
  filter(Scenario %in% scen_levels) %>%
  transmute(lifestyle, Scenario,
            Lower  = CEV_lifetime_constrained,
            Med  = CEV_lifetime_cautious,
            Higher = CEV_lifetime_lowcarbon) %>%
  mutate(Scenario = factor(Scenario, levels = scen_levels)) %>%
  set_factors() %>%
  rowwise() %>%
  mutate(spread = max(c(Lower, Med, Higher)) - min(c(Lower, Med, Higher)),
         gap    = Higher - Lower) %>%
  ungroup() %>%
  mutate(row_label = factor("Welfare (CEV)"))

g_welfare_spread <- ggplot(welfare_ineq, aes(Scenario, spread, fill = lifestyle)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  scale_x_discrete(labels = xlabs, expand = expansion(add = 0.4)) + ls_fill +
  labs(title = "c. Welfare (CEV) spread across lifestyle groups",
       subtitle = "Max \u2212 min lifetime CEV, percentage points", x = NULL, y = NULL) +
  theme_ns() + theme(axis.title.x = element_text(color = "white"))

gini_ratio_supp <- gp %>%
  select(lifestyle, Scenario, footprint, measure, value) %>%
  mutate(measure = recode(measure, Palma = "High-to-low ratio")) %>%
  arrange(footprint, measure, lifestyle, Scenario)
write_csv(gini_ratio_supp, file.path(out_dir, "table_energy_services_inequality_supplementary.csv"))

welfare_gap_supp <- welfare_ineq %>%
  select(lifestyle, Scenario, gap) %>%
  arrange(lifestyle, Scenario)
write_csv(welfare_gap_supp, file.path(out_dir, "table_welfare_gap_supplementary.csv"))

cf_total_2050 <- function(path) {
  if (!file.exists(path)) return(NA_real_)
  d  <- read.csv(path, check.names = FALSE); d <- d[!duplicated(d$Row), ]
  yc <- grep("^Y[0-9]{4}$", names(d), value = TRUE)
  g1 <- function(v) { x <- as.numeric(d[d$Row == v, yc])
  if (!length(x)) NA_real_ else x[yc == "Y2050"] }
  sum(vapply(c("CF_constrained", "CF_cautious", "CF_lowcarbon"), g1, numeric(1)))
}

cf_ref_total <- cf_total_2050(file.path(levels_dir, paste0("NoModifiers_", foresight, ".csv")))

env_out <- expand_grid(lifestyle = lifestyles, Scenario = scen_levels) %>%
  mutate(cf_tot = map2_dbl(lifestyle, Scenario,
                           ~ cf_total_2050(file.path(levels_dir,
                                                     paste0(.x, "_", foresight, "_", .y, ".csv")))),
         env_pct = cf_tot / cf_ref_total - 1) %>%
  keep_scen_fac()

access_eq <- accessA2 %>%
  filter(ratio == "low/high", year == max(ratio_years)) %>%
  select(lifestyle, Scenario, access_ratio = value)

welfare_eq <- welfare_ineq %>% select(lifestyle, Scenario, spread)

trilemma <- env_out %>%
  left_join(access_eq,  by = c("lifestyle", "Scenario")) %>%
  left_join(welfare_eq, by = c("lifestyle", "Scenario")) %>%
  mutate(scen_lab = factor(Scenario, levels = scen_levels, labels = scen_labels))

stopifnot(nrow(trilemma) == length(lifestyles) * length(scen_levels))
if (anyNA(trilemma$env_pct) || anyNA(trilemma$access_ratio) || anyNA(trilemma$spread))
  message("trilemma: NAs present - check that all 12 scenario files were found")

has_repel <- requireNamespace("ggrepel", quietly = TRUE)
label_layer <- if (has_repel) {
  ggrepel::geom_text_repel(aes(label = scen_lab), size = 2.5, colour = "grey25",
                           seed = 1,
                           segment.colour = NA,
                           box.padding   = 0.12,
                           point.padding = 0.05,
                           force         = 0.25,
                           force_pull    = 3,
                           max.overlaps  = Inf,
                           max.time      = 1, max.iter = 20000)
} else {
  message("ggrepel not installed - using fixed nudge; check label overlap")
  geom_text(aes(label = scen_lab), size = 2.6, colour = "grey25",
            hjust = -0.15, vjust = -0.5)
}

g_trilemma <- ggplot(trilemma, aes(access_ratio, env_pct)) +
  geom_vline(xintercept = 1, linetype = "dotted", colour = "grey60", linewidth = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60", linewidth = 0.4) +
  geom_point(aes(shape = Scenario, fill = lifestyle, size = spread),
             colour = "grey20", stroke = 0.4) +
  label_layer +
  scale_shape_manual(values = scen_shapes, breaks = scen_levels,
                     labels = scen_labels, guide = "none") +
  scale_fill_manual(values = pal_ls, name = "Behaviour") +
  scale_size_continuous(range = c(2.2, 7),
                        name = "Welfare spread\n(max \u2212 min CEV, p.p.)") +
  scale_x_continuous(labels = scales::number_format(accuracy = 0.01)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1),
                     limits = c(-0.015, 0.015),
                     breaks = seq(-0.015, 0.015, by = 0.005)) +
  guides(fill = guide_legend(order = 1, override.aes = list(shape = 21, size = 3.5)),
         size = guide_legend(order = 2, override.aes = list(shape = 21, fill = "grey70"))) +
  labs(title = "c. The trilemma",
       subtitle = "Down = lower carbon footprint; right = more equal access; larger = wider welfare gap",
       x = "Access equity (lower/higher-income access ratio, 2050)",
       y = "Carbon footprint vs. reference run") +
  theme_ns()

TRILEMMA_PANEL <- TRUE
pC <- if (TRILEMMA_PANEL) g_trilemma else g_welfare_spread
top <- pA + plot_layout(guides = "collect") &
  theme(legend.position = "bottom", legend.justification = "center",
        legend.box = "horizontal")

middle <- (pB | pC) + plot_layout(guides = "collect", widths = c(1.6, 1)) &
  theme(legend.position = "bottom", legend.justification = "center",
        legend.box = "horizontal")

fig <- (wrap_elements(top) / wrap_elements(middle)) +
  plot_layout(heights = c(1.3, 1.1))

message("Writing CEV + CV tables to CSV (Supplementary)...")

scen_levels_tab <- c("Baseline", "Regressive",
                     "Progressive")
scen_labels_tab <- c("BAU", "Regressive", "Progressive")
grp_levels_tab <- c("constrained", "cautious", "lowcarbon")
grp_labels_tab <- c("Lower", "Medium", "Higher")

cev_tab <- cev_life %>%
  select(lifestyle, Scenario,
         constrained = CEV_lifetime_constrained,
         cautious    = CEV_lifetime_cautious,
         lowcarbon   = CEV_lifetime_lowcarbon) %>%
  pivot_longer(c(constrained, cautious, lowcarbon),
               names_to = "group", values_to = "CEV")

cv_tab <- load_welfare("welfare_CV_EV.csv") %>%
  select(lifestyle, Scenario, group = Group, CV = CV_2050)

welfare_table <- left_join(cev_tab, cv_tab,
                           by = c("lifestyle", "Scenario", "group")) %>%
  filter(Scenario %in% scen_levels_tab, group %in% grp_levels_tab) %>%
  mutate(
    Lifestyle      = factor(lifestyle, levels = lifestyles,
                            labels = lifestyle_labels[lifestyles]),
    Scenario       = factor(Scenario, levels = scen_levels_tab, labels = scen_labels_tab),
    grp            = factor(group, levels = grp_levels_tab, labels = grp_labels_tab),
    CEV            = round(CEV, 2),
    CV             = round(CV, 2)
  ) %>%
  arrange(Lifestyle, Scenario, grp)

welfare_table %>%
  transmute(Lifestyle, Scenario, `lifestyle group` = grp,
            `CEV (%)` = CEV, `CV (%)` = CV) %>%
  write_csv(file.path(out_dir, "table_cev_cv_full.csv"))

wide <- welfare_table %>%
  select(Lifestyle, Scenario, grp, CEV, CV) %>%
  pivot_wider(names_from = grp, values_from = c(CEV, CV),
              names_glue = "{grp}_{.value}") %>%
  select(Lifestyle, Scenario,
         Lower_CEV, Medium_CEV, Higher_CEV, Lower_CV, Medium_CV, Higher_CV)
write_csv(wide, file.path(out_dir, "table_cev_cv_wide.csv"))

save_fig(fig, "fig_welfare_equity_v26", w = 15, h = 8)

cat("\n=== CEV (lifetime welfare, %) + CV (2050 price index, %), vs no lifestyle changes ===\n")
print(as.data.frame(welfare_table %>%
                      transmute(Lifestyle, Scenario, `lifestyle group` = grp,
                                `CEV (%)` = CEV, `CV (%)` = CV)),
      row.names = FALSE)

print(fig)