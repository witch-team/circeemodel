library(tidyverse)
library(patchwork)

base    <- "~/Desktop/Paper_Rethink_Results/Outputs/CIRCEE_output_levels"
out_dir <- "~/Desktop/Paper_Rethink_Results/figures"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

foresight_keep <- "AE"
groups <- c("constrained","cautious","lowcarbon")
scen_levels <- c("Baseline","Strong_Regressive","Strong_Progressive")
scen_labels <- c("Baseline","Regressive","Progressive")
group_levels <- c("Low income","Medium income","High income")

lifestyle_labels <- c(
  ecoactive_ecoactive         = " Ecoactive - All",
  affordability_affordability = " Affordability - All",
  ecoactive_affordability     = " Ecoactive sharing \n Affordability sufficiency",
  affordability_ecoactive     = " Affordability sharing \n Ecoactive sufficiency")

ls_col <- c(" Ecoactive - All"="#1B7837"," Affordability - All"="#762A83",
            " Ecoactive sharing \n Affordability sufficiency"="#E08214",
            " Affordability sharing \n Ecoactive sufficiency"="#2166AC")

scen_shapes    <- c("Baseline"=21,"Regressive"=24,"Progressive"=23)
scen_linetypes <- c("Baseline"="solid","Regressive"="solid","Progressive"="solid")

read_years <- function(path, keep_rows = NULL) {
  df <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  df <- df[!duplicated(df$Row), ]
  ycols <- grep("^Y[0-9]{4}$", names(df), value = TRUE)
  if (!is.null(keep_rows)) df <- df[df$Row %in% keep_rows, ]
  df %>% select(Row, all_of(ycols)) %>%
    pivot_longer(all_of(ycols), names_to="year", values_to="val") %>%
    mutate(year = as.integer(str_remove(year,"^Y")), val = suppressWarnings(as.numeric(val)))
}

all_csv <- list.files(base, pattern="\\.csv$", full.names=TRUE)
fn <- basename(all_csv)
scen_meta <- tibble(path = all_csv[!str_starts(fn,"NoModifiers")]) %>%
  mutate(f=basename(path), m=str_match(f,"^(.+)_(AE|PF)_(.+)\\.csv$"),
         lifestyle=m[,2], foresight=m[,3], scenario=str_replace_all(m[,4],"\\.","_")) %>%
  filter(foresight==foresight_keep, scenario %in% scen_levels)

scen_long <- scen_meta %>% mutate(d=map(path, read_years)) %>%
  select(lifestyle, scenario, d) %>% unnest(d) %>%
  pivot_wider(names_from=Row, values_from=val)

nomod_long <- tibble(path = all_csv[basename(all_csv)==paste0("NoModifiers_",foresight_keep,".csv")]) %>%
  mutate(d=map(path, read_years)) %>% select(d) %>% unnest(d) %>%
  pivot_wider(names_from=Row, values_from=val) %>%
  rename_with(~ ifelse(.x=="year", .x, paste0(.x,"_nomod")))

joined <- left_join(scen_long, nomod_long, by="year")

compute_grp_yr <- function(df, h) {
  inv_pol   <- df[[paste0("Inv_ed_new_",h)]] + df[[paste0("Inv_ed_new_tild_",h)]] + df[[paste0("Inv_ed_repair_",h)]]
  inv_nomod <- df[[paste0("Inv_ed_new_",h,"_nomod")]] + df[[paste0("Inv_ed_new_tild_",h,"_nomod")]] + df[[paste0("Inv_ed_repair_",h,"_nomod")]]
  ratio_pol   <- df[[paste0("ES_sharing_",h)]] / df[[paste0("ES_home_",h)]]
  ratio_nomod <- df[[paste0("ES_sharing_",h,"_nomod")]] / df[[paste0("ES_home_",h,"_nomod")]]
  tibble(lifestyle=df$lifestyle, scenario=df$scenario, year=df$year, grp=h,
         Refuse  = (inv_nomod - inv_pol) / inv_nomod,
         Rethink = (ratio_pol - ratio_nomod) / ratio_nomod)
}

evo <- map_dfr(groups, ~ compute_grp_yr(joined, .x)) %>%
  filter(scenario %in% scen_levels, year >= 2018, year <= 2050) %>%
  pivot_longer(c(Refuse, Rethink), names_to="indicator", values_to="value") %>%
  mutate(lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         scenario_lbl  = factor(scenario, levels=scen_levels, labels=scen_labels),
         group_lbl     = factor(case_when(grp=="constrained"~"Low income",
                                          grp=="cautious"~"Medium income",
                                          grp=="lowcarbon"~"High income"), levels=group_levels))

theme_ns <- function(base = 9) {
  theme_minimal(base_size = base) +
    theme(
      text             = element_text(color = "#1A1A1A"),
      plot.title       = element_text(size = base + 1, face = "bold", hjust = 0,
                                      margin = margin(b = 5)),
      plot.subtitle    = element_text(size = base-1, color = "#4D4D4D",
                                      margin = margin(b = 5)),
      axis.title       = element_text(size = base),
      axis.text        = element_text(size = base - 1, color = "#4D4D4D"),
      strip.text       = element_text(size = base - 1, face = "bold", color = "#1A1A1A",
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
      strip.background = element_rect(fill = "grey90", colour = NA)
    )
}
theme_evo <- theme_ns()

MAIN_SCENARIO <- "Baseline"

evo_main <- filter(evo, scenario_lbl == MAIN_SCENARIO)

mk_traj <- function(ind, ttl, sub = NULL, data = evo_main, show_ecosystem = FALSE) {
  d <- filter(data, indicator==ind)
  mark_years <- c(2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050)
  p <- ggplot(d, aes(year, value, colour=lifestyle_lbl, group=interaction(lifestyle_lbl, scenario_lbl)))+
    geom_hline(yintercept=0, linetype = "dashed", color = "#9A9A9A", linewidth = 0.4)+
    geom_line(linewidth=0.5)+
    geom_point(data=filter(d, year %in% mark_years), size=1.5, fill="white", stroke=0.6, shape = 21)+
    facet_wrap(~ group_lbl, nrow=1)+
    scale_colour_manual("Behaviour", values=ls_col)+
    scale_y_continuous(labels=scales::percent)+
    scale_x_continuous(breaks=c(2020,2035,2050), limits=c(2018,2050))+
    labs(title=ttl, subtitle=sub, x=NULL, y=NULL)+theme_evo+ theme(axis.text.y = element_text(size = 8))
  if (show_ecosystem) {
    p <- p + aes(shape = scenario_lbl, linetype = scenario_lbl) +
      geom_point(data=filter(d, year %in% mark_years), aes(shape=scenario_lbl), size=1.5, fill="white", stroke=0.6) +
      scale_shape_manual("Infrastructures", values=scen_shapes,
                         guide = guide_legend(override.aes = list(fill = "white", colour = "black", linetype = 0))) +
      scale_linetype_manual("Infrastructures", values=scen_linetypes, guide = "none")
  }
  p
}

pA <- mk_traj("Refuse",  "a. Refuse",
              paste0("Reduction in energy-using goods investments vs. reference run (", MAIN_SCENARIO, "infrasructures)"))
pB <- mk_traj("Rethink", "b. Rethink",
              paste0("PSS to home energy-services ratio vs. reference run (", MAIN_SCENARIO, "infrastructures)"))

pA_SI <- mk_traj("Refuse",  "a. Refuse (all infrastructures configurations)",
                 "Reduction in energy-using goods investments for each scenario in comparison to the reference run",
                 data = evo, show_ecosystem = TRUE)
pB_SI <- mk_traj("Rethink", "b. Rethink (all infrastructures configurations)",
                 "PSS to home energy-services ratio for each scenario in comparison to the reference run",
                 data = evo, show_ecosystem = TRUE)

ew_series <- c(w="Labor", p_e_sharing="Energy",
               p_sharing="Total", r_ed="Rental")

rep_path <- scen_meta %>% filter(lifestyle=="ecoactive_ecoactive", scenario=="Baseline") %>%
  pull(path)

ew_pct <- read_years(rep_path[1], keep_rows=names(ew_series)) %>%
  filter(year %in% c(2018, 2050)) %>%
  pivot_wider(names_from=year, values_from=val, names_prefix="y") %>%
  mutate(pct = 100*(y2050-y2018)/y2018,
         series = ew_series[Row]) %>%
  mutate(series = factor(series, levels = c(
    "Rental",
    "Energy",
    "Labor",
    "Total")))

pC <- ggplot(ew_pct, aes(pct, series, fill = pct))+
  geom_col(width = 0.65, colour = "grey30", linewidth = 0.3)+
  geom_vline(xintercept = 0, colour = "grey40", linewidth = 0.4)+
  geom_text(aes(label = sprintf("%+.1f%%", pct),
                hjust = ifelse(pct > 0, -0.15, 1.15)), size = 3)+
  scale_fill_gradient2(low = "firebrick", mid = "white", high = "steelblue",
                       midpoint = 0, limits = c(-35, 35),
                       oob = scales::squish, guide = "none")+
  scale_x_continuous(limits = c(-60, 60), breaks = seq(-40, 40, 20),
                     labels = function(x) paste0(x, "%"))+
  labs(title = "f. %\u0394 components of the PSS energy-service price between 2018-2050",
       subtitle = "Percentage changes are approximately the same across scenarios.\nRental is per unit of use and corresponds to the equilibrium rental rate of goods determined by\nthe use rate choice and its intertemporal investment decision (the asset price.)", x = NULL, y = NULL)+
  theme_evo + theme(panel.grid.major.y = element_blank(),
                    axis.text.x=element_text(size=8),
                    axis.text.y=element_text(size=8),
                    plot.title = element_text(margin = margin(b = 5)))

ls_series <- c(p_home_constrained="Total (L)", p_home_cautious="Total (M)",
               p_home_lowcarbon="Total (H)",
               p_e_h_lowcarbon="Energy (all)",
               uc_constrained="Ownership (L)", uc_cautious="Ownership (M)",
               uc_lowcarbon="Ownership (H)")

ser_lv <- c("Energy (all)",
            "Ownership (H)", "Total (H)",
            "Ownership (M)", "Total (M)",
            "Ownership (L)", "Total (L)")

uc_denom <- c(uc_constrained="u_lowuse_constrained",
              uc_cautious   ="u_lowuse_cautious",
              uc_lowcarbon  ="u_lowuse_lowcarbon")

read_rows_d <- c(names(ls_series), unname(uc_denom))

dpct <- scen_meta %>%
  mutate(d = map(path, ~ read_years(.x, keep_rows = read_rows_d))) %>%
  select(lifestyle, scenario, d) %>% unnest(d) %>%
  filter(lifestyle %in% c("ecoactive_ecoactive", "affordability_affordability")) %>%
  filter(scenario == "Baseline") %>%
  filter(year %in% c(2018, 2050)) %>%
  pivot_wider(names_from = Row, values_from = val) %>%
  { df <- .
  for (k in names(ls_series)) {
    if (k %in% names(uc_denom)) df[[k]] <- df[[k]] / df[[uc_denom[[k]]]]
  }
  df } %>%
  select(lifestyle, scenario, year, all_of(names(ls_series))) %>%
  pivot_longer(all_of(names(ls_series)), names_to = "Row", values_to = "val") %>%
  pivot_wider(names_from = year, values_from = val, names_prefix = "y") %>%
  mutate(pct = 100*(y2050-y2018)/y2018,
         series = factor(ls_series[Row], levels = ser_lv),
         scen   = factor(scenario, levels = scen_levels,
                         labels = c("Baseline","Regressive","Progressive")),
         ls_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels))

pD <- ggplot(dpct, aes(scen, fct_rev(series), fill=pct))+
  geom_tile(colour="white", linewidth=0.5)+
  geom_text(aes(label=sprintf("%+.0f", pct)), size=2.5)+
  facet_wrap(~ ls_lbl, nrow=1)+
  scale_fill_gradient2(low="firebrick", mid="white", high="steelblue", midpoint=0,
                       name=NULL,
                       limits = c(-35, 35),
                       breaks = c(35, 0, -35),
                       labels = c("Increase", "No change", "Decrease"),
                       oob = scales::squish)+
  labs(title = "e. %\u0394 components of home energy-service costs between 2018-2050", subtitle="Affordability sharing / Ecoactive sufficiency is nearly identical to Ecoactive - All \nEcoactive sharing / Affordability sufficiency is nearly identical to Affordability - All \nThe (intertemporal) ownership cost is per unit of use\nL = Low-income, M = Medium-income, H = High-income",
       x=NULL, y=NULL)+
  theme_evo+theme(panel.grid=element_blank(),
                  axis.text.x=element_text(angle=0, size=8),
                  axis.text.y=element_text(size=8),
                  plot.title = element_text(margin = margin(b = 8)),
                  legend.text = element_text(size = 8))

ulow <- joined %>%
  filter(scenario %in% scen_levels, year >= 2018, year <= 2050) %>%
  select(lifestyle, scenario, year,
         constrained = u_lowuse_constrained,
         cautious    = u_lowuse_cautious,
         lowcarbon   = u_lowuse_lowcarbon) %>%
  pivot_longer(c(constrained, cautious, lowcarbon),
               names_to = "grp", values_to = "value") %>%
  mutate(lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         scenario_lbl  = factor(scenario, levels = scen_levels, labels = scen_labels),
         group_lbl     = factor(case_when(grp=="constrained"~"Low income",
                                          grp=="cautious"~"Medium income",
                                          grp=="lowcarbon"~"High income"),
                                levels = group_levels))

u2018_c <- ulow %>% filter(year == 2018) %>%
  group_by(group_lbl) %>% summarise(u0 = mean(value), .groups = "drop")

mark_years <- c(2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050)

ulow_main <- filter(ulow, scenario_lbl == MAIN_SCENARIO)

pE <- ggplot(ulow_main, aes(year, value, colour = lifestyle_lbl,
                            group = interaction(lifestyle_lbl, scenario_lbl))) +
  geom_hline(data = u2018_c, aes(yintercept = u0),
             inherit.aes = FALSE,
             linetype = "dashed", color = "#9A9A9A", linewidth = 0.4) +
  geom_line(linewidth = 0.5) +
  geom_point(data = filter(ulow_main, year %in% mark_years),
             size = 1.5, fill = "white", stroke = 0.6, shape = 21) +
  facet_wrap(~ group_lbl, nrow = 1) +
  scale_colour_manual("Behaviour", values = ls_col) +
  scale_x_continuous(breaks = c(2020,2035,2050), limits = c(2018,2050)) +
  labs(title = "c. Use rate of (household) owned energy-using goods",
       subtitle = paste0(MAIN_SCENARIO, "infrasructures"),
       x = NULL, y = NULL) +
  theme_evo + theme(axis.text.y = element_text(size = 8),
                    strip.background = element_rect(fill = "grey85", colour = NA),
                    strip.text = element_text(size = 8))

# SI: full 3-scenario version
pE_SI <- ggplot(ulow, aes(year, value, colour = lifestyle_lbl,
                          group = interaction(lifestyle_lbl, scenario_lbl))) +
  geom_hline(data = u2018_c, aes(yintercept = u0),
             inherit.aes = FALSE,
             linetype = "dashed", color = "#9A9A9A", linewidth = 0.4) +
  geom_line(aes(linetype = scenario_lbl), linewidth = 0.4) +
  geom_point(data = filter(ulow, year %in% mark_years),
             aes(shape = scenario_lbl), size = 1.5, fill = "white", stroke = 0.6) +
  facet_wrap(~ group_lbl, nrow = 1) +
  scale_colour_manual("Behaviour", values = ls_col) +
  scale_shape_manual("Infrastructures", values = scen_shapes,
                     guide = guide_legend(override.aes = list(fill="white", colour="black", linetype=0))) +
  scale_linetype_manual("Infrastructures", values = scen_linetypes, guide = "none") +
  scale_x_continuous(breaks = c(2020,2035,2050), limits = c(2018,2050)) +
  labs(title = "a. Use rate of (household) owned energy-using goods",
       x = NULL, y = NULL) +
  theme_evo + theme(axis.text.y = element_text(size = 8),
                    strip.background = element_rect(fill = "grey85", colour = NA),
                    strip.text = element_text(size = 8))

uhigh <- joined %>%
  filter(scenario %in% scen_levels, year >= 2018, year <= 2050) %>%
  select(lifestyle, scenario, year, value = u_highuse) %>%
  mutate(lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         scenario_lbl  = factor(scenario, levels = scen_levels, labels = scen_labels))

u2018_d <- uhigh %>% filter(year == 2018) %>% summarise(u0 = mean(value)) %>% pull(u0)

uhigh_main <- filter(uhigh, scenario_lbl == MAIN_SCENARIO)

pF <- ggplot(uhigh_main, aes(year, value, colour = lifestyle_lbl,
                             group = interaction(lifestyle_lbl, scenario_lbl))) +
  geom_hline(yintercept = u2018_d,
             linetype = "dashed", color = "#9A9A9A", linewidth = 0.4) +
  geom_line(linewidth = 0.5) +
  geom_point(data = filter(uhigh_main, year %in% mark_years),
             size = 1.5, fill = "white", stroke = 0.6, shape = 21) +
  scale_colour_manual("Behaviour", values = ls_col) +
  scale_x_continuous(breaks = c(2020,2035,2050), limits = c(2018,2050)) +
  labs(title = "d. Use rate of PSS energy-using goods",
       subtitle = paste0(MAIN_SCENARIO, "infrastructures"),
       x = NULL, y = NULL) +
  theme_evo + theme(axis.text.y = element_text(size = 8))

pF_SI <- ggplot(uhigh, aes(year, value, colour = lifestyle_lbl,
                           group = interaction(lifestyle_lbl, scenario_lbl))) +
  geom_hline(yintercept = u2018_d,
             linetype = "dashed", color = "#9A9A9A", linewidth = 0.4) +
  geom_line(aes(linetype = scenario_lbl), linewidth = 0.4) +
  geom_point(data = filter(uhigh, year %in% mark_years),
             aes(shape = scenario_lbl), size = 1.5, fill = "white", stroke = 0.6) +
  scale_colour_manual("Behaviour", values = ls_col) +
  scale_shape_manual("Infrastructures", values = scen_shapes,
                     guide = guide_legend(override.aes = list(fill="white", colour="black", linetype=0))) +
  scale_linetype_manual("Infrastructures", values = scen_linetypes, guide = "none") +
  scale_x_continuous(breaks = c(2020,2035,2050), limits = c(2018,2050)) +
  labs(title = "b. Use rate of PSS energy-using goods",
       x = NULL, y = NULL) +
  theme_evo + theme(axis.text.y = element_text(size = 8))

fig <- (pE_SI | pF_SI) +
  plot_layout(guides = "collect") &
  theme(legend.position = "right", legend.justification = "center",
        legend.box = "vertical", legend.key = element_rect(fill = "#EBEBEB", colour = NA))

ggsave(file.path(out_dir, "fig_userate_ecosystem.pdf"), fig, width = 15, height = 6, device = "pdf")
ggsave(file.path(out_dir, "fig_userate_ecosystem.png"), fig, width = 15, height = 6, dpi = 300)
message("Saved: fig_userate_ecosystem in ", out_dir)
print(fig)