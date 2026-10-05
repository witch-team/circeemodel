library(tidyr)
library(dplyr)
library(stringr)
library(purrr)
library(ggplot2)
library(cowplot)
library(ggh4x)
library(ggnewscale)
library(patchwork)

base    <- "Desktop/Paper_Rethink_Results/Outputs/CIRCEE_output_levels"
out_dir <- "Desktop/Paper_Rethink_Results/figures"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

FIG_W <- 180 / 25.4 
DPI   <- 600              
FONT  <- "sans" 

update_geom_defaults("text",  list(family = FONT))
update_geom_defaults("label", list(family = FONT))
if (requireNamespace("ggrepel", quietly = TRUE))
  update_geom_defaults(ggrepel::GeomTextRepel, list(family = FONT))

save_ns <- function(plot, name, height_in, dir = out_dir) {
  if (inherits(plot, "patchwork"))
    plot <- plot & ggplot2::theme(text = ggplot2::element_text(family = FONT))
  ggsave(file.path(dir, paste0(name, ".pdf")), plot,
         width = FIG_W, height = height_in, units = "in",
         device = "pdf", family = FONT)
  ggsave(file.path(dir, paste0(name, ".png")), plot,
         width = FIG_W, height = height_in, units = "in", dpi = DPI)
  message("Saved ", name, " at 180 mm x ", round(height_in * 25.4), " mm")
}


foresight      <- "AE"
selected_years <- c("Y2030", "Y2040", "Y2050")
year_labels    <- c(Y2030 = "2030", Y2040 = "2040", Y2050 = "2050")

TO_MT <- 1e-12
co2_vars       <- c("CO2_economy", "CO2_incineration") 
cum_start_year <- 2018
CO2_TO_MT <- 1

lifestyles <- c("ecoactive_ecoactive", "affordability_affordability",
                "ecoactive_affordability", "affordability_ecoactive")
lifestyle_labels <- c(
  ecoactive_ecoactive         = "Ecoactive - All",
  affordability_affordability = "Affordability - All",
  ecoactive_affordability     = "Ecoactive\nSharing\nAffordability\nSufficiency",
  affordability_ecoactive     = "Affordability\nSharing\nEcoactive\nSufficiency"
)

scen_levels <- c("Baseline", "Strong.Regressive", "Strong.Progressive")
scen_short  <- c(Baseline = "Current (low)", Strong.Regressive = "Concentrated",
                 Strong.Progressive = "Broad")
add_dmc_split <- function(df) {
  m_vars <- c("M_virgin_nondurable","M_virgin_otherdurable",
              "M_virgin_energydurable","M_virgin_capital",
              "M_recycled_nondurable","M_recycled_otherdurable",
              "M_recycled_energydurable","M_recycled_capital","DMC")
  ycols <- grep("^Y[0-9]{4}$", names(df), value = TRUE)
  
  missing <- setdiff(m_vars, df$Row)
  if (length(missing) > 0) {
    message("Skipping DMC split — missing rows: ", paste(missing, collapse = ", "))
    return(df)
  }
  
  wide <- df[df$Row %in% m_vars, c("Row", ycols)]
  rownames(wide) <- wide$Row
  vals <- as.matrix(wide[, ycols, drop = FALSE])
  
  virgin_tot   <- colSums(vals[c("M_virgin_nondurable","M_virgin_otherdurable",
                                 "M_virgin_energydurable","M_virgin_capital"), , drop = FALSE])
  recycled_tot <- colSums(vals[c("M_recycled_nondurable","M_recycled_otherdurable",
                                 "M_recycled_energydurable","M_recycled_capital"), , drop = FALSE])
  denom <- virgin_tot + recycled_tot
  dmc   <- vals["DMC", ]
  
  make_row <- function(rowname, virgin_row, recycled_row) {
    share <- (vals[virgin_row, ] + vals[recycled_row, ]) / denom
    c(Row = rowname, setNames(as.numeric(dmc * share), ycols))
  }
  
  new_rows <- rbind(
    make_row("DMC_nondurable",    "M_virgin_nondurable",    "M_recycled_nondurable"),
    make_row("DMC_otherdurable",  "M_virgin_otherdurable",  "M_recycled_otherdurable"),
    make_row("DMC_energydurable", "M_virgin_energydurable", "M_recycled_energydurable"),
    make_row("DMC_capital",       "M_virgin_capital",       "M_recycled_capital")
  )
  new_rows <- as.data.frame(new_rows, stringsAsFactors = FALSE)
  new_rows[ycols] <- lapply(new_rows[ycols], as.numeric)
  
  full_cols <- names(df)
  for (col in setdiff(full_cols, names(new_rows))) new_rows[[col]] <- NA
  new_rows <- new_rows[, full_cols]
  
  rbind(df, new_rows)
}

read_vars <- function(path, vars) {
  df <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  df <- df[!duplicated(df$Row), ]
  df <- add_dmc_split(df)
  keep <- df$Row %in% vars
  df[keep, c("Row", selected_years)] %>%
    pivot_longer(all_of(selected_years), names_to = "Year", values_to = "Value") %>%
    rename(variable = Row)
}

read_series_allyears <- function(path, vars) {
  df <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  df <- df[!duplicated(df$Row), ]
  ycols <- grep("^Y[0-9]{4}$", names(df), value = TRUE)
  keep  <- df$Row %in% vars
  df[keep, c("Row", ycols)] %>%
    pivot_longer(all_of(ycols), names_to = "Year", values_to = "Value") %>%
    mutate(year_num = as.integer(sub("^Y", "", Year))) %>%
    rename(variable = Row)
}

all_vars <- c(
  "DMC_nondurable", "DMC_otherdurable",                      
  "DMC_energydurable", "DMC_capital",
  "MW_energydurables", "MW_otherdurables", "MW_nondurables", "IW"
)

fn  <- list.files(base, pattern = "\\.csv$", full.names = TRUE)
bn  <- basename(fn)

scen_files <- tibble(path = fn, f = bn) %>%
  filter(!str_starts(f, "NoModifiers"),
         str_detect(f, paste0("_", foresight, "_"))) %>%
  mutate(m = str_match(f, "^(.+)_(AE|PF)_(.+)\\.csv$"),
         lifestyle = m[, 2], scenario = m[, 4]) %>%
  filter(lifestyle %in% lifestyles, scenario %in% scen_levels) %>%
  select(path, lifestyle, scenario)

scen_data <- scen_files %>%
  mutate(vals = map(path, ~ read_vars(.x, all_vars))) %>%
  select(-path) %>%
  unnest(vals)

nomod_path <- fn[bn == paste0("NoModifiers_", foresight, ".csv")]
stopifnot(length(nomod_path) == 1)
nomod_data <- read_vars(nomod_path, all_vars) %>%
  rename(Value_nomod = Value)

df <- scen_data %>%
  left_join(nomod_data, by = c("variable", "Year")) %>%
  mutate(Value = (Value - Value_nomod) * TO_MT) %>%
  select(-Value_nomod) %>%
  mutate(
    Year      = factor(year_labels[Year], levels = c("2030", "2040", "2050")),
    combo     = factor(scenario, levels = scen_levels, labels = scen_short[scen_levels]),
    lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels[lifestyles])
  )

all_years  <- c("2030", "2040", "2050")
all_combos <- levels(df$combo)                      
new_levels <- character(0)
for (yr in all_years) {
  for (cb in all_combos) new_levels <- c(new_levels, paste0(yr, "::", cb))
  new_levels <- c(new_levels, paste0("GAp::", yr))
}
new_levels <- new_levels[-length(new_levels)]   

df <- df %>% mutate(YearCombo = factor(paste(Year, combo, sep = "::"), levels = new_levels))

co2_scen <- scen_files %>%
  mutate(vals = map(path, ~ read_series_allyears(.x, co2_vars))) %>%
  select(-path) %>%
  unnest(vals)

co2_nomod <- read_series_allyears(nomod_path, co2_vars) %>%
  rename(Value_nomod = Value)

co2_cum <- co2_scen %>%
  left_join(co2_nomod, by = c("variable", "Year", "year_num")) %>%
  mutate(diff = (Value - Value_nomod) * CO2_TO_MT) %>%
  filter(year_num >= cum_start_year) %>%
  arrange(lifestyle, scenario, variable, year_num) %>%
  group_by(lifestyle, scenario, variable) %>%
  mutate(cum = cumsum(diff)) %>%
  ungroup()

co2_df <- co2_cum %>%
  filter(year_num %in% c(2030, 2040, 2050)) %>%
  transmute(
    lifestyle, scenario, variable,
    Value = cum,
    Year  = factor(as.character(year_num), levels = c("2030", "2040", "2050")),
    combo = factor(scenario, levels = scen_levels, labels = scen_short[scen_levels]),
    lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels[lifestyles])
  ) %>%
  mutate(
    variable  = factor(variable, levels = co2_vars),
    YearCombo = factor(paste(Year, combo, sep = "::"), levels = new_levels)
  )

x_lab_fun <- function(x) {
  vapply(x, function(lvl) {
    if (grepl("^GAp::", lvl)) return("")
    parts <- strsplit(lvl, "::")[[1]]
    if (parts[2] == "Concentrated") parts[1] else ""   
  }, character(1))
}

base_theme <- theme_gray(base_size = 7) +
  theme(
    axis.text.x      = element_text(angle = 45, hjust = 1, size = 5),
    axis.text.y      = element_text(size = 6),
    axis.title       = element_text(size = 6),
    axis.ticks.x     = element_blank(),
    panel.grid.major = element_line(color = "white"),
    panel.grid.minor = element_line(color = "white"),
    strip.text       = element_text(size = 5, color = "black", face = "bold",
                                    lineheight = 0.85),
    legend.position  = "right",
    legend.box       = "vertical",
    legend.box.just  = "left",
    legend.title     = element_text(size = 6),
    legend.text      = element_text(size = 5),
    legend.key.size  = unit(0.28, "cm"),
    legend.spacing.y = unit(0.10, "cm"),
    legend.margin    = margin(l = 0, r = 0),
    plot.title       = element_text(size = 7, face = "bold",
                                    margin = margin(b = 2)),
    plot.margin      = margin(t = 2, r = 2, b = 2, l = 2)
  )

add_total_points <- function(p, totals_df) {
  p +
    ggnewscale::new_scale_fill() +
    ggnewscale::new_scale_color() +
    geom_point(
      data = totals_df,
      aes(x = YearCombo, y = total, shape = combo, fill = combo, color = combo),
      size = 1.0, stroke = 0.6, inherit.aes = FALSE
    ) +
    scale_shape_manual(name = "Infrastructure enablement",
                       values = setNames(c(21, 24, 23), c("Current (low)", "Concentrated", "Broad"))) +
    scale_fill_manual(name = "Infrastructure enablement",
                      values = setNames(rep("white", 3), c("Current (low)", "Concentrated", "Broad"))) +
    scale_color_manual(name = "Infrastructure enablement",
                       values = setNames(rep("black", 3), c("Current (low)", "Concentrated", "Broad"))) +
    guides(fill = "none", color = "none",
           shape = guide_legend(order = 2, override.aes = list(
             fill  = "white",
             color = "black")))
}

y_lab <- expression("Relative to reference in Mt year"^-1)

make_panel <- function(vars, fills, fill_labels, fill_name, title, fill_breaks = NULL) {
  d_long <- df %>% filter(variable %in% vars) %>%
    mutate(variable = factor(variable, levels = vars))
  totals <- d_long %>%
    group_by(lifestyle_lbl, YearCombo, combo) %>%
    summarise(total = sum(Value), .groups = "drop")
  
  fm <- scale_fill_manual(values = fills, name = fill_name, labels = fill_labels)
  if (!is.null(fill_breaks)) fm <- scale_fill_manual(values = fills, name = fill_name,
                                                     labels = fill_labels, breaks = fill_breaks)
  
  p <- ggplot(d_long, aes(x = YearCombo, y = Value, fill = variable)) +
    geom_bar(stat = "identity", position = "stack", color = "black", linewidth = 0.2) +
    fm +
    guides(fill = guide_legend(order = 1)) +
    geom_hline(yintercept = 0, color = "black", linewidth = 0.4) +
    facet_wrap(~ lifestyle_lbl, nrow = 1, scales = "free_x") +
    scale_x_discrete(guide = guide_axis_nested(), drop = FALSE, labels = x_lab_fun) +
    scale_y_continuous(breaks = seq(-3, 3, 1)) +
    coord_cartesian(ylim = c(-3, 3.6)) +
    labs(x = "Year", y = y_lab, title = title) +
    base_theme
  add_total_points(p, totals)
}

make_co2_panel <- function(d_long, title) {
  totals <- d_long %>%
    group_by(lifestyle_lbl, YearCombo, combo) %>%
    summarise(total = sum(Value), .groups = "drop")
  
  p <- ggplot(d_long, aes(x = YearCombo, y = Value, fill = variable)) +
    geom_bar(stat = "identity", position = "stack", color = "black", linewidth = 0.2) +
    scale_fill_manual(
      values = c(CO2_economy = "plum1", CO2_incineration = "yellow1"),
      name   = expression("Cumulative CO"[2]),
      labels = c(CO2_economy = "Economy (energy)", CO2_incineration = "Incineration")
    ) +
    guides(fill = guide_legend(order = 1)) +
    geom_hline(yintercept = 0, color = "black", linewidth = 0.4) +
    facet_wrap(~ lifestyle_lbl, nrow = 1, scales = "free_x") +
    scale_x_discrete(guide = guide_axis_nested(), drop = FALSE, labels = x_lab_fun) +
    labs(x = "Year",
         y = expression("Mt CO"[2]),
         title = title) +
    base_theme
  add_total_points(p, totals)
}

p_dmc <- make_panel(
  vars = c("DMC_nondurable", "DMC_otherdurable", "DMC_energydurable", "DMC_capital"),
  fills = c(DMC_nondurable    = "#E69F00",
            DMC_otherdurable  = "#F0E442",
            DMC_energydurable = "#CC79A7",
            DMC_capital       = "#009E73"),
  fill_labels = c(DMC_nondurable    = "Non-durable goods",
                  DMC_otherdurable  = "Other durable goods",
                  DMC_energydurable = "Energy-using goods",
                  DMC_capital       = "Capital goods"),
  fill_name = "Material flows",
  title = "a. Domestic Material Consumption")

p_waste <- make_panel(
  vars = c("MW_energydurables", "MW_otherdurables", "MW_nondurables", "IW"),
  fills = c(MW_energydurables = "#CC79A7", MW_otherdurables = "#F0E442",
            MW_nondurables = "#E69F00", IW = "#0072B2"),
  fill_labels = c(MW_energydurables = "Energy-using goods",
                  MW_otherdurables  = "Other durable goods",
                  MW_nondurables    = "Non-durable goods",
                  IW                = "Industrial waste"),
  fill_name = "Waste flows",
  fill_breaks = c("MW_nondurables", "MW_otherdurables", "MW_energydurables", "IW"),
  title = "b. Municipal and industrial waste flows") +
  guides(shape = "none")   # same enablement legend as panel a

p_co2 <- make_co2_panel(
  co2_df,
  title = expression(bold("c. Cumulative CO"[2]*" emissions")))
co2_df_2050 <- co2_df %>% filter(Year == "2050")
co2_2050_levels <- all_combos
co2_df_2050 <- co2_df_2050 %>%
  mutate(combo_only = factor(combo, levels = all_combos))

make_co2_panel_2050 <- function(d_long, title) {
  totals <- d_long %>%
    group_by(lifestyle_lbl, combo_only) %>%
    summarise(total = sum(Value), .groups = "drop")
  
  p <- ggplot(d_long, aes(x = combo_only, y = Value, fill = variable)) +
    geom_bar(stat = "identity", position = "stack", color = "black", linewidth = 0.2) +
    scale_fill_manual(
      values = c(CO2_economy = "#CC79A7", CO2_incineration = "#F0E442"),
      name   = expression("Cumulative CO"[2]),
      labels = c(CO2_economy = "Economy (energy)", CO2_incineration = "Incineration")
    ) +
    guides(fill = guide_legend(order = 1)) +
    geom_hline(yintercept = 0, color = "black", linewidth = 0.4) +
    facet_wrap(~ lifestyle_lbl, nrow = 1) +
    ggnewscale::new_scale_fill() +
    ggnewscale::new_scale_color() +
    geom_point(data = totals, aes(x = combo_only, y = total, shape = combo_only,
                                  fill = combo_only, color = combo_only),
               size = 1.2, stroke = 0.6, inherit.aes = FALSE) +
    scale_shape_manual(name = "Infrastructure enablement",
                       values = setNames(c(21, 24, 23), c("Current (low)", "Concentrated", "Broad"))) +
    scale_fill_manual(name = "Infrastructure enablement",
                      values = setNames(rep("white", 3), c("Current (low)", "Concentrated", "Broad"))) +
    scale_color_manual(name = "Infrastructure enablement",
                       values = setNames(rep("black", 3), c("Current (low)", "Concentrated", "Broad"))) +
    guides(fill = "none", color = "none",
           shape = guide_legend(order = 2, override.aes = list(
             fill = "white", color = "black"))) +
    labs(x = NULL, y = expression("Mt CO"[2]*" relative to the reference"), title = title) +
    base_theme + theme(axis.text.x = element_blank())
  p
}

p_co2_main <- make_co2_panel_2050(
  co2_df_2050,
  title = expression(bold("c. Cumulative CO"[2]*" emissions to 2050")))
lifestyles_hm <- c("ecoactive_ecoactive","affordability_ecoactive",
                   "ecoactive_affordability","affordability_affordability")
scenarios_hm  <- c("Baseline","Strong.Regressive","Strong.Progressive")
hm_scalar <- function(d,v){ yc<-grep("^Y[0-9]{4}$",names(d),value=TRUE); as.numeric(d[d$Row==v,yc])[yc=="Y2050"] }
hm_series <- function(d,v){ yc<-grep("^Y[0-9]{4}$",names(d),value=TRUE); setNames(as.numeric(d[d$Row==v,yc]),as.integer(sub("Y","",yc))) }

ref_hm <- read.csv(file.path(base,"NoModifiers_AE.csv"), check.names=FALSE)
ref_hm <- ref_hm[!duplicated(ref_hm$Row),]

grid <- expand.grid(lifestyle=lifestyles_hm, scenario=scenarios_hm, stringsAsFactors=FALSE)
grid$env_co2 <- NA_real_; grid$eq_accessgap <- NA_real_
ratio_ref <- hm_scalar(ref_hm,"ES_constrained") / hm_scalar(ref_hm,"ES_lowcarbon")
for(i in seq_len(nrow(grid))){
  f <- file.path(base, paste0(grid$lifestyle[i],"_AE_",grid$scenario[i],".csv"))
  if(!file.exists(f)){ cat("missing scenario file:", f, "\n"); next }
  d <- read.csv(f, check.names=FALSE); d <- d[!duplicated(d$Row),]
  co2 <- (hm_series(d,"CO2_economy")      - hm_series(ref_hm,"CO2_economy")) +
    (hm_series(d,"CO2_incineration") - hm_series(ref_hm,"CO2_incineration"))
  yr <- as.integer(names(co2))
  grid$env_co2[i]      <- sum(co2[yr>=cum_start_year & yr<=2050])
  ratio_scen <- hm_scalar(d,"ES_constrained") / hm_scalar(d,"ES_lowcarbon")
  grid$eq_accessgap[i] <- 100*(ratio_scen - ratio_ref)/ratio_ref      
}                                                                

welfare_base <- "~/Desktop/Paper_Rethink_Results/Welfare"
grid$cev_gap <- NA_real_
for(i in seq_len(nrow(grid))){
  wf <- file.path(welfare_base, paste0(grid$lifestyle[i],"_AE"), "welfare_CEV_lifetime.csv")
  if(!file.exists(wf)){ cat("missing CEV file:", wf, "\n"); next }
  w <- read.csv(wf, check.names=FALSE)
  r <- w[w$Scenario == grid$scenario[i], ]
  if(nrow(r)==1) grid$cev_gap[i] <- r$CEV_lifetime_constrained - r$CEV_lifetime_lowcarbon
}
cat("CEV gap NA count (should be 0):", sum(is.na(grid$cev_gap)), "\n")

grid$ls_f <- factor(grid$lifestyle, levels = lifestyles_hm,
                    labels = c("Ecoactive - All","Affordability sharing\nEcoactive sufficiency","Ecoactive sharing\nAffordability sufficiency","Affordability - All"))
grid$sc_f <- factor(grid$scenario, levels = scenarios_hm,
                    labels = c("Current (low)","Concentrated","Broad"))
p_heatmap <- ggplot(grid, aes(eq_accessgap, cev_gap)) +
  annotate("rect", xmin = 0, xmax = Inf, ymin = 0, ymax = Inf,
           fill = "#EAF3DE", alpha = 0.6) +
  geom_hline(yintercept = 0, color = "#B4B2A9", linewidth = 0.4) +
  geom_vline(xintercept = 0, color = "#B4B2A9", linewidth = 0.4) +
  geom_point(aes(fill = env_co2, shape = sc_f), size = 2, stroke = 0.2, color = "black") +
  scale_fill_gradient2(low = "#27500A", mid = "#F1EFE8", high = "#791F1F",
                       midpoint = 0, name = expression(atop("Cumulative CO"[2], "vs reference")),
                       breaks = c(-90, 0, 90), labels = c("-90 Mt", "0 Mt", "90 Mt")) +
  scale_shape_manual(values = c(21, 24, 23), name = "Infrastructure enablement") + 
  guides(fill = guide_colourbar(order = 1),
         shape = guide_legend(order = 2, override.aes = list(fill = "grey50"))) +
  facet_wrap(~ ls_f, nrow = 2) +
  labs(x = "Access-gap equity (right: gap narrows toward parity, %)",
       y = "Welfare-gap equity (up: gap narrows, pp)",
       title = "d. Environmental and equity trade-off") +
  base_theme +
  theme(panel.grid.minor = element_blank(),
        legend.position = "right",
        legend.key.height = unit(0.4, "cm"),
        panel.spacing = unit(0.6, "lines"))

top_row_main <- (p_dmc | p_waste) +
  plot_layout(guides = "collect") &
  theme(legend.position = "right", legend.justification = "center")

bottom_row_main <- (plot_spacer() | p_co2_main | plot_spacer()) +
  plot_layout(widths = c(0.5, 1, 0.5))

main_plot <- (wrap_elements(top_row_main) + theme(plot.margin = margin(b = 0))) /
  (wrap_elements(bottom_row_main) + theme(plot.margin = margin(t = 0))) +
  plot_layout(heights = c(1, 0.8))

save_ns(main_plot, "fig5_main", height_in = 5.20)
print(main_plot)

si_plot <- plot_grid(p_co2, p_heatmap, ncol = 1, rel_heights = c(1, 1.2))

save_ns(si_plot, "fig5_supplementary_co2_and_tradeoff", height_in = 6.61)
