data_dir        <- "~/Desktop/Paper_Rethink_Results/data_zenodo"
out_dir_default <- "~/Desktop/Paper_Rethink_Results/figures"

library(tidyverse)
library(patchwork)
library(ggh4x)

base    <- file.path(data_dir, "Outputs", "CIRCEE_output_levels")
out_dir <- out_dir_default
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

read_y2050 <- function(path) {
  df <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  df <- df[!duplicated(df$Row), ]
  setNames(as.list(df$Y2050), df$Row) |> as_tibble()
}

all_csv <- list.files(base, pattern = "\\.csv$", full.names = TRUE)
fn      <- basename(all_csv)

scen_data <- tibble(path = all_csv[!str_starts(fn, "NoModifiers")]) %>%
  mutate(f = basename(path), m = str_match(f, "^(.+)_(AE|PF)_(.+)\\.csv$"),
         lifestyle = m[,2], foresight = m[,3], scenario = str_replace_all(m[,4], "\\.", "_")) %>%
  select(path, lifestyle, foresight, scenario) %>%
  mutate(vals = map(path, read_y2050)) %>% select(-path) %>% unnest(vals)

nomod_data <- tibble(path = all_csv[basename(all_csv) %in% c("NoModifiers_AE.csv","NoModifiers_PF.csv")]) %>%
  mutate(foresight = str_match(basename(path), "^NoModifiers_(AE|PF)\\.csv$")[,2]) %>%
  select(path, foresight) %>%
  mutate(vals = map(path, read_y2050)) %>% select(-path) %>% unnest(vals)

basket_2050_joined <- left_join(scen_data, nomod_data, by = "foresight", suffix = c("", "_nomod"))

groups <- c("constrained", "cautious", "lowcarbon")

lifestyle_labels <- c(
  ecoactive_ecoactive         = "Ecoactive - All",
  affordability_affordability = "Affordability - All",
  ecoactive_affordability     = "Ecoactive - Sharing \nAffordability - Sufficiency",
  affordability_ecoactive     = "Affordability - Sharing \nEcoactive - Sufficiency")

scenario_order_with_base <- c("Baseline","Regressive","Progressive")
scenario_order_behav     <- c("Baseline","Regressive","Progressive")

relabel_groups <- function(grp) factor(case_when(
  grp == "constrained" ~ "Lower income",
  grp == "cautious"    ~ "Medium income",
  grp == "lowcarbon"   ~ "Higher income"
), levels = c("Lower income", "Medium income", "Higher income"))

scenario_labeller <- labeller(scenario_lbl = c(
  Baseline="BAU", Regressive="Regressive", Progressive="Progressive"))

base_theme <- theme_minimal(base_size = 9) +
  theme(strip.placement="outside",
        strip.text.x.bottom = element_text(face="bold", size=8, margin=margin(t=4, b=3)),
        strip.text.y.right  = element_text(face="bold", size=7, angle=270, lineheight=1.05),
        axis.text.x.top=element_text(angle=45, hjust=0, size=8), axis.text.y=element_text(size=7),
        panel.grid=element_blank(), plot.title=element_text(face="bold", size=10),
        legend.title=element_text(size=8), legend.text=element_text(size=8),
        plot.subtitle=element_text(size=8),
        plot.margin = margin(t = 5, r = 20, b = 5, l = 5),
        plot.background=element_rect(fill="white", color=NA))

compute_intensity3 <- function(df, h) {
  inv_pol   <- df[[paste0("Inv_ed_new_", h)]] + df[[paste0("Inv_ed_new_tild_", h)]] + df[[paste0("Inv_ed_repair_", h)]]
  inv_nomod <- df[[paste0("Inv_ed_new_", h, "_nomod")]] + df[[paste0("Inv_ed_new_tild_", h, "_nomod")]] + df[[paste0("Inv_ed_repair_", h, "_nomod")]]
  ratio_pol   <- df[[paste0("ES_sharing_", h)]] / df[[paste0("ES_home_", h)]]
  ratio_nomod <- df[[paste0("ES_sharing_", h, "_nomod")]] / df[[paste0("ES_home_", h, "_nomod")]]
  tibble(scenario=df$scenario, lifestyle=df$lifestyle, foresight=df$foresight, grp=h,
         Refuse_val=(inv_nomod-inv_pol)/inv_nomod,
         Rethink_val=(ratio_pol-ratio_nomod)/ratio_nomod)
}

behav_df2 <- map_dfr(groups, ~ compute_intensity3(basket_2050_joined, .x)) %>%
  mutate(
    group_lbl     = relabel_groups(grp),
    lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels)
  ) %>%
  pivot_longer(c(Refuse_val, Rethink_val), names_to = "indicator", values_to = "raw_value") %>%
  mutate(indicator = recode(indicator, Refuse_val = "Refuse", Rethink_val = "Rethink"),
         indicator = factor(indicator, levels = c("Refuse", "Rethink"))) %>%
  filter(foresight == "AE", scenario %in% scenario_order_behav) %>%
  mutate(scenario_lbl = factor(scenario, levels = scenario_order_behav),
         cap = quantile(abs(raw_value), 0.95, na.rm = TRUE),
         value_norm = pmax(pmin(raw_value / cap, 1), -1))

pal_behav <- c("#874500","#D55E00","#FCDFC0","#FFFFFF","#A9D3EC","#0072B2","#00456E")

p3a <- ggplot(behav_df2, aes(indicator, group_lbl, fill=value_norm)) +
  geom_tile(color="white", linewidth=0.5) +
  scale_fill_gradientn(colors=pal_behav, values=scales::rescale(c(-0.7,-0.35,-0.1,0,0.1,0.35,0.7)),
                       limits=c(-1,1), name=NULL, breaks=c(-1,0,1),
                       labels=c("Disengage (-1)","Neutral (0)","Engage (+1)")) +
  scale_y_discrete(limits = c("Lower income", "Medium income", "Higher income")) +
  facet_grid(lifestyle_lbl ~ scenario_lbl, switch="x", labeller=scenario_labeller) +
  scale_x_discrete(position="top", limits=c("Refuse","Rethink")) +
  labs(title="a. Behavioural engagement (2050 snapshot)",
       subtitle="Y2050 vs. reference run with no lifestyle heterogeneity and BAU infrastructures", x=NULL, y=NULL) +
  base_theme

foresight_keep <- "AE"
scen_levels <- c("Baseline","Regressive","Progressive")
scen_labels <- c("BAU","Regressive","Progressive")   # display only; file token stays "Baseline"

lifestyle_labels <- c(
  ecoactive_ecoactive         = " Ecoactive - All",
  affordability_affordability = " Affordability - All",
  ecoactive_affordability     = " Ecoactive sharing \n Affordability sufficiency",
  affordability_ecoactive     = " Affordability sharing \n Ecoactive sufficiency")

ls_col <- c(" Ecoactive - All"="#1B7837"," Affordability - All"="#762A83",
            " Ecoactive sharing \n Affordability sufficiency"="#E08214",
            " Affordability sharing \n Ecoactive sufficiency"="#2166AC")

scen_shapes    <- c("BAU"=21,"Regressive"=24,"Progressive"=23)
scen_linetypes <- c("BAU"="solid","Regressive"="solid","Progressive"="solid")

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

compute_agg_yr <- function(df) {
  inv_pol   <- df[["Inv_ed_new"]] + df[["Inv_ed_new_tild"]] + df[["Inv_ed_repair"]]
  inv_nomod <- df[["Inv_ed_new_nomod"]] + df[["Inv_ed_new_tild_nomod"]] + df[["Inv_ed_repair_nomod"]]
  ratio_pol   <- df[["ES_sharing"]] / df[["ES_home"]]
  ratio_nomod <- df[["ES_sharing_nomod"]] / df[["ES_home_nomod"]]
  tibble(lifestyle=df$lifestyle, scenario=df$scenario, year=df$year, grp="economy",
         Refuse  = (inv_nomod - inv_pol) / inv_nomod,
         Rethink = (ratio_pol - ratio_nomod) / ratio_nomod)
}

group_levels_with_agg <- c("Economy-wide","Higher income","Medium income","Lower income")

evo <- bind_rows(
  map_dfr(groups, ~ compute_grp_yr(joined, .x)),
  compute_agg_yr(joined)
) %>%
  filter(scenario %in% scen_levels, year >= 2018, year <= 2050) %>%
  pivot_longer(c(Refuse, Rethink), names_to="indicator", values_to="value") %>%
  mutate(lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         scenario_lbl  = factor(scenario, levels=scen_levels, labels=scen_labels),
         group_lbl     = factor(case_when(
           grp == "constrained" ~ "Lower income",
           grp == "cautious"    ~ "Medium income",
           grp == "lowcarbon"   ~ "Higher income",
           grp == "economy"     ~ "Economy-wide"
         ), levels = group_levels_with_agg))

theme_ns <- function(base = 9) {
  theme_minimal(base_size = base) +
    theme(
      text             = element_text(color = "#1A1A1A"),
      plot.title       = element_text(size = base + 1, face = "bold", hjust = 0, margin = margin(b = 5)),
      plot.subtitle    = element_text(size = base-1, color = "#4D4D4D", margin = margin(b = 5)),
      axis.title       = element_text(size = base),
      axis.text        = element_text(size = base - 1, color = "#4D4D4D"),
      strip.text       = element_text(size = base - 1, face = "bold", color = "#1A1A1A", margin = margin(2, 2, 2, 2)),
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

evo <- evo %>%
  mutate(enablement_grp = factor(if_else(scenario_lbl == "BAU", "BAU", "Enabling"),
                                 levels = c("BAU", "Enabling")))

enable_shapes    <- c(BAU = 21, Enabling = 24)
enable_linetypes <- c(BAU = "solid", Enabling = "solid")

mk_traj <- function(ind, ttl, sub = NULL, data = evo, show_ecosystem = FALSE, ylim = NULL,
                    ylab = NULL, peak_band = NULL, peak_label = NULL,
                    peak_label_vjust = 1.1) {
  d <- filter(data, indicator==ind)
  mark_years <- c(2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050)
  
  band <- if (is.null(peak_band)) NULL else list(
    annotate("rect", xmin = peak_band[1], xmax = peak_band[2],
             ymin = -Inf, ymax = Inf, fill = "white", alpha = 0.60),
    annotate("segment", x = peak_band[1], xend = peak_band[1],
             y = -Inf, yend = Inf, colour = "#7A7A7A", linewidth = 0.3, linetype = "dotted"),
    annotate("segment", x = peak_band[2], xend = peak_band[2],
             y = -Inf, yend = Inf, colour = "#7A7A7A", linewidth = 0.3, linetype = "dotted")
  )
  
  lab_layer <- if (is.null(peak_band) || is.null(peak_label)) NULL else {
    y_top <- if (!is.null(ylim)) ylim[2] else max(d$value, na.rm = TRUE)
    lab_df <- tibble(group_lbl = factor(group_levels_with_agg[1], levels = group_levels_with_agg),
                     year = mean(peak_band), value = y_top, label = peak_label)
    geom_text(data = lab_df, aes(x = year, y = value, label = label),
              inherit.aes = FALSE, size = 2.5, vjust = peak_label_vjust,
              lineheight = 0.9, colour = "#4D4D4D")
  }
  if (show_ecosystem) {
    p <- ggplot(d, aes(year, value, colour=lifestyle_lbl, group=interaction(lifestyle_lbl, scenario_lbl)))+
      band+
      geom_hline(yintercept=0, linetype="dashed", color="#9A9A9A", linewidth=0.4)+
      geom_line(aes(linetype=scenario_lbl), linewidth=0.4)+
      geom_point(data=filter(d, year %in% mark_years), aes(shape=scenario_lbl), size=1.5, fill="white", stroke=0.6)+
      facet_wrap(~ group_lbl, nrow=1)+
      scale_colour_manual("Behaviour", values=ls_col)+
      scale_shape_manual("Infrastructures", values=scen_shapes,
                         guide=guide_legend(override.aes=list(fill="white", colour="black", linetype=0)))+
      scale_linetype_manual("Infrastructures", values=scen_linetypes, guide="none")+
      scale_y_continuous(labels=scales::percent, limits=ylim)+
      scale_x_continuous(breaks=c(2020,2035,2050), limits=c(2018,2050))+
      labs(title=ttl, subtitle=sub, x=NULL, y=ylab)+lab_layer+theme_evo+
      theme(axis.text.y=element_text(size=8), axis.title.y=element_text(size=8))
  } else {
    p <- ggplot(d, aes(year, value, colour=lifestyle_lbl, group=interaction(lifestyle_lbl, scenario_lbl)))+
      band+
      geom_hline(yintercept=0, linetype="dashed", color="#9A9A9A", linewidth=0.4)+
      geom_line(aes(linetype=enablement_grp), linewidth=0.5)+
      geom_point(data=filter(d, year %in% mark_years), aes(shape=enablement_grp), size=1.5, fill="white", stroke=0.6)+
      facet_wrap(~ group_lbl, nrow=1)+
      scale_colour_manual("Behaviour", values=ls_col)+
      scale_shape_manual("Infrastructures", values=enable_shapes,
                         labels=c(BAU="BAU", Enabling="Enabling (Progressive or Regressive)"),
                         guide=guide_legend(override.aes=list(fill="white", colour="black", linetype=0)))+
      scale_linetype_manual("Infrastructures", values=enable_linetypes, guide="none")+
      scale_y_continuous(labels=scales::percent, limits=ylim)+
      scale_x_continuous(breaks=c(2020,2035,2050), limits=c(2018,2050))+
      labs(title=ttl, subtitle=sub, x=NULL, y=ylab)+lab_layer+theme_evo+
      theme(axis.text.y=element_text(size=8), axis.title.y=element_text(size=8))
  }
  p
}

shared_ylim <- range(evo$value[evo$indicator %in% c("Refuse","Rethink")], na.rm = TRUE)
shared_ylab <- "% vs. reference run"

pB <- mk_traj("Refuse",  "b. Refuse",
              "Reduction in investment in energy-using goods (new purchases and repairs)",
              data = evo, show_ecosystem = TRUE, ylim = shared_ylim, ylab = shared_ylab)
pC <- mk_traj("Rethink", "c. Rethink",
              "Increase in the PSS-to-home energy-services ratio",
              data = evo, show_ecosystem = TRUE, ylim = shared_ylim, ylab = shared_ylab,
              peak_band = c(2030, 2035), peak_label = "Peak\n2030\u20132035",
              peak_label_vjust = 0.9)

top <- (plot_spacer() | p3a | plot_spacer()) + plot_layout(widths = c(0.5, 1, 0.5))

MERGE_BC <- FALSE

if (!MERGE_BC) {
  
  pB_stack <- pB + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
  bottom <- (pB_stack / pC) + plot_layout(guides = "collect") &
    theme(legend.position = "right", legend.justification = "center")
  
} else {
  
  mark_years <- c(2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050)
  ind_labels <- c("b. Refuse", "c. Rethink")
  
  bc_data <- evo %>%
    filter(indicator %in% c("Refuse", "Rethink")) %>%
    mutate(indicator = factor(indicator, levels = c("Refuse", "Rethink"), labels = ind_labels))
  
  band_df <- tibble(indicator = factor(ind_labels[2], levels = ind_labels),
                    xmin = 2030, xmax = 2035)
  lab_df  <- tibble(indicator = factor(ind_labels[2], levels = ind_labels),
                    group_lbl = factor(group_levels_with_agg[1], levels = group_levels_with_agg),
                    year = 2032.5, value = shared_ylim[2], label = "Peak\n2030\u20132035")
  
  bottom <- ggplot(bc_data, aes(year, value, colour = lifestyle_lbl,
                                group = interaction(lifestyle_lbl, scenario_lbl))) +
    geom_rect(data = band_df, aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf),
              inherit.aes = FALSE, fill = "white", alpha = 0.60) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "#9A9A9A", linewidth = 0.4) +
    geom_line(aes(linetype = scenario_lbl), linewidth = 0.4) +
    geom_point(data = filter(bc_data, year %in% mark_years), aes(shape = scenario_lbl),
               size = 1.5, fill = "white", stroke = 0.6) +
    geom_text(data = lab_df, aes(x = year, y = value, label = label), inherit.aes = FALSE,
              size = 2.5, vjust = 1.1, lineheight = 0.9, colour = "#4D4D4D") +
    facet_grid(indicator ~ group_lbl) +
    scale_colour_manual("Behaviour", values = ls_col) +
    scale_shape_manual("Infrastructures", values = scen_shapes,
                       guide = guide_legend(override.aes = list(fill = "white", colour = "black", linetype = 0))) +
    scale_linetype_manual("Infrastructures", values = scen_linetypes, guide = "none") +
    scale_y_continuous(labels = scales::percent, limits = shared_ylim) +
    scale_x_continuous(breaks = c(2020, 2035, 2050), limits = c(2018, 2050)) +
    labs(x = NULL, y = shared_ylab) +
    theme_evo +
    theme(legend.position = "right", legend.justification = "center",
          axis.text.y = element_text(size = 8), axis.title.y = element_text(size = 8))
}

fig <- (wrap_elements(top) / wrap_elements(bottom)) +
  plot_layout(heights = c(1, 1.35))

ggsave(file.path(out_dir, "fig_behavioural_engagement.pdf"), fig, width = 11, height = 15, device = "pdf")
ggsave(file.path(out_dir, "fig_behavioural_engagement.png"), fig, width = 11, height = 15, dpi = 300)
message("Saved: fig_behavioural_engagement in ", out_dir)
print(fig)