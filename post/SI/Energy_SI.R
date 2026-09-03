read_shock_file <- function(path) {
  read.csv(path.expand(path), sep = ";", header = FALSE, stringsAsFactors = FALSE,
           col.names = c("Variable", "Region", "Year", "Value"))
}

rep_lifestyle <- "ecoactive_ecoactive"
rep_scenario_dir  <- "Baseline"
rep_scenario_file <- "Baseline" 
rep_path <- file.path("~/Desktop/Paper_Rethink_Results/Coupling",
                      paste0(rep_lifestyle, "_AE_", rep_scenario_dir),
                      paste0("shocks_final_", rep_lifestyle, "_", rep_scenario_file, ".csv"))

d_check <- read_shock_file(rep_path)

vars_wanted <- c("A_el_WITCH", "A_nel_WITCH", "emissions_el_WITCH", "emissions_nel_WITCH",
                 "g_el_witch", "g_nel_witch")

found_vars <- unique(d_check$Variable)
matches <- vars_wanted %in% found_vars
names(matches) <- vars_wanted
print(matches)
if (!all(matches)) {
  message("Not all requested variables found with assumed casing. Checking case-insensitively:")
  for (v in vars_wanted[!matches]) {
    hits <- found_vars[tolower(found_vars) == tolower(v)]
    if (length(hits) > 0) message("  '", v, "' not found, but close match exists: '", hits, "'")
    else message("  '", v, "' — no case-insensitive match either. Check spelling against the actual file.")
  }
  stop("Fix variable names above (see message output) before proceeding — do not guess and plot silently-wrong data.")
}

prog_path <- file.path("~/Desktop/Paper_Rethink_Results/Coupling",
                       paste0(rep_lifestyle, "_AE_Strong_Progressive"),
                       paste0("shocks_final_", rep_lifestyle, "_Strong.Progressive.csv"))

d_prog_check <- tryCatch(read_shock_file(prog_path), error = function(e) NULL)

if (!is.null(d_prog_check)) {
  baseline_vals <- d_check %>% filter(Variable %in% vars_wanted, Year == 2050) %>%
    transmute(Variable, Baseline = as.numeric(Value))
  prog_vals <- d_prog_check %>% filter(Variable %in% vars_wanted, Year == 2050) %>%
    transmute(Variable, Progressive = as.numeric(Value))
  comparison <- left_join(baseline_vals, prog_vals, by = "Variable") %>%
    mutate(pct_diff = 100 * (Progressive - Baseline) / Baseline)
  message("Baseline vs Progressive at 2050, for these six variables:")
  print(comparison)
  message("If pct_diff is near zero for all six, these are confirmed scenario-invariant ",
          "and reading one representative file (below) is safe. If not, this script needs ",
          "to be extended to read per-scenario instead of assuming invariance.")
} else {
  message("Could not read a second scenario's file to check invariance — proceeding with ",
          "the single representative file, but this assumption is UNVERIFIED. Check manually.")
}

witch_df <- d_check %>%
  filter(Variable %in% vars_wanted) %>%
  mutate(Year = as.integer(Year), Value = as.numeric(Value)) %>%
  filter(Year >= 2020, Year <= 2050) %>%
  mutate(Value = if_else(Variable %in% c("emissions_el_WITCH", "emissions_nel_WITCH"),
                         Value * 1e12, Value)) %>%
  filter(Variable != "emissions_nel_WITCH")

var_labels <- c(
  A_el_WITCH = "Electricity efficiency (A_el)",
  A_nel_WITCH = "Non-electricity efficiency (A_nel)",
  emissions_el_WITCH = "Energy emission factor (Mt CO2/EJ)",
  g_el_witch = "Electricity price growth rate",
  g_nel_witch = "Non-electricity price growth rate"
)

witch_df <- witch_df %>%
  mutate(var_lbl = factor(var_labels[Variable], levels = unname(var_labels)))

efficiency_range <- range(witch_df$Value[witch_df$Variable %in% c("A_el_WITCH","A_nel_WITCH")], na.rm = TRUE)
growth_range     <- range(witch_df$Value[witch_df$Variable %in% c("g_el_witch","g_nel_witch")], na.rm = TRUE)

eff_scale    <- scale_y_continuous(limits = efficiency_range)
growth_scale <- scale_y_continuous(limits = growth_range)

pos_scales_y <- list(eff_scale, eff_scale, NULL, growth_scale, growth_scale)

pWitch <- ggplot(witch_df, aes(Year, Value)) +
  geom_line(colour = "#2166AC", linewidth = 0.6) +
  facet_wrap(~ var_lbl, scales = "free_y", ncol = 3) +
  ggh4x::facetted_pos_scales(y = pos_scales_y) +
  scale_x_continuous(breaks = c(2020, 2035, 2050)) +
  labs(title = "Evolution of exogenous WITCH/SSP2 input variables",
       subtitle = paste0("Representative run: ", rep_lifestyle, ", ", rep_scenario_dir,
                         " scenario. A_el/A_nel share one y-scale, growth rates share another; ",
                         "emission factors remain on independent scales."),
       x = NULL, y = NULL) +
  theme_evo +
  theme(strip.text = element_text(face = "bold", size = 8),
        plot.title = element_text(face = "bold", size = 11),
        plot.subtitle = element_text(size = 8, colour = "grey30"))

ggsave(file.path(out_dir, "fig_witch_ssp2_inputs.pdf"), pWitch, width = 12, height = 7, device = "pdf")
ggsave(file.path(out_dir, "fig_witch_ssp2_inputs.png"), pWitch, width = 12, height = 7, dpi = 300)
message("Saved: fig_witch_ssp2_inputs in ", out_dir)
print(pWitch)