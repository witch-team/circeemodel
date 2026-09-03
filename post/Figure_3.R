library(tidyverse)
library(patchwork)
library(ggh4x)

base    <- "~/Desktop/Paper_Rethink_Results/Outputs/CIRCEE_output_levels"
out_dir <- "~/Desktop/Paper_Rethink_Results/figures"
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

scenario_order_with_base <- c("Baseline","Strong_Regressive","Strong_Progressive")
scenario_order_behav     <- c("Baseline","Strong_Regressive","Strong_Progressive")
group_levels <- c("Lower income","Medium income","Higher income")

relabel_groups <- function(grp) factor(case_when(
  grp=="constrained"~"Lower income", grp=="cautious"~"Medium income", grp=="lowcarbon"~"Higher income"),
  levels = group_levels)

scenario_labeller <- labeller(scenario_lbl = c(
  Baseline="BAU", Strong_Regressive="Regressive", Strong_Progressive="Progressive"))

base_theme <- theme_minimal(base_size = 9) +
  theme(strip.placement="outside",
        strip.text.x.bottom = element_text(face="bold", size=8, margin=margin(t=4,b=3)),
        strip.text.y.right  = element_text(face="bold", size=7, angle=270, lineheight=0.9),
        axis.text.x.top=element_text(angle=45, hjust=0, size=8), axis.text.y=element_text(size=7),
        panel.grid=element_blank(), plot.title=element_text(face="bold", size=10),
        legend.title=element_text(size=8), legend.text=element_text(size=8),
        plot.subtitle=element_text(size=8),
        plot.background=element_rect(fill="white", color=NA))

shapes_sc  <- c("Higher income"=15, "Medium income"=16, "Lower income"=17, "Economy-wide"=18)
eco_colors <- c("BAU"="grey50", "Regressive"="#B2182B", "Progressive"="#2166AC")

pop_lookup <- basket_2050_joined %>%
  transmute(scenario, lifestyle, foresight,
            N_constrained = CF_constrained / CF_constrained_percapita,
            N_cautious    = CF_cautious    / CF_cautious_percapita,
            N_lowcarbon   = CF_lowcarbon   / CF_lowcarbon_percapita,
            N_total       = (CF_constrained / CF_constrained_percapita) +
              (CF_cautious    / CF_cautious_percapita)    +
              (CF_lowcarbon   / CF_lowcarbon_percapita))

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
  mutate(group_lbl=relabel_groups(grp),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         scenario=factor(scenario, levels=scenario_order_with_base)) %>%
  pivot_longer(c(Refuse_val,Rethink_val), names_to="indicator", values_to="raw_value") %>%
  mutate(indicator=recode(indicator, Refuse_val="Refuse", Rethink_val="Rethink"),
         indicator=factor(indicator, levels=c("Refuse","Rethink"))) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(scenario_lbl=factor(scenario, levels=scenario_order_behav),
         cap=quantile(abs(raw_value),0.95,na.rm=TRUE),
         value_norm=pmax(pmin(raw_value/cap,1),-1))

pal_behav <- c("#D73027","#F46D43","#FEE090","#FFFFFF","#ABD9E9","#74ADD1","#4575B4")

p3a <- ggplot(behav_df2, aes(indicator, group_lbl, fill=value_norm)) +
  geom_tile(color="white", linewidth=0.5) +
  scale_fill_gradientn(colors=pal_behav, values=scales::rescale(c(-0.7,-0.35,-0.1,0,0.1,0.35,0.7)),
                       limits=c(-1,1), name=NULL,
                       breaks=c(-1,0,1),
                       labels=c("Disengage (\u22121)","Neutral (0)","Engage (+1)")) +
  facet_grid(lifestyle_lbl ~ scenario_lbl, switch="x", labeller=scenario_labeller) +
  scale_x_discrete(position="top", limits=c("Refuse","Rethink")) +
  labs(title="a. Behavioural engagement",
       subtitle="Y2050 vs. reference run with no lifestyle heterogeneity and BAU infrastructures", x=NULL, y=NULL) +
  base_theme

compute_footprint <- function(df, h) {
  cf_pol <- df[[paste0("CF_", h, "_percapita")]]; cf_nm <- df[[paste0("CF_", h, "_percapita_nomod")]]
  wf_pol <- df[[paste0("WF_", h, "_percapita")]]; wf_nm <- df[[paste0("WF_", h, "_percapita_nomod")]]
  mf_pol <- df[[paste0("MF_", h, "_percapita")]]; mf_nm <- df[[paste0("MF_", h, "_percapita_nomod")]]
  tibble(scenario=df$scenario, lifestyle=df$lifestyle, foresight=df$foresight, grp=h,
         Carbon_val=-(cf_pol-cf_nm)/cf_nm,
         Waste_val=-(wf_pol-wf_nm)/wf_nm,
         Material_val=-(mf_pol-mf_nm)/mf_nm)
}

fp_df2 <- map_dfr(groups, ~ compute_footprint(basket_2050_joined, .x)) %>%
  mutate(group_lbl=relabel_groups(grp),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         scenario=factor(scenario, levels=scenario_order_with_base)) %>%
  pivot_longer(c(Carbon_val,Waste_val,Material_val), names_to="indicator", values_to="raw_value") %>%
  mutate(indicator=recode(indicator, Carbon_val="Carbon", Waste_val="Waste", Material_val="Material"),
         indicator=factor(indicator, levels=c("Carbon","Waste","Material"))) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(scenario_lbl=factor(scenario, levels=scenario_order_behav),
         cap=quantile(abs(raw_value),0.95,na.rm=TRUE),
         value_norm=pmax(pmin(raw_value/cap,1),-1))

pal_env <- c("#762A83","#9970AB","#C2A5CF","#FFFFFF","#A6DBA0","#5AAE61","#1B7837")

p3b <- ggplot(fp_df2, aes(indicator, group_lbl, fill=value_norm)) +
  geom_tile(color="white", linewidth=0.5) +
  scale_fill_gradientn(colors=pal_env, values=scales::rescale(c(-0.7,-0.35,-0.1,0,0.1,0.35,0.7)),
                       limits=c(-1,1), name=NULL,
                       breaks=c(-1,0,1),
                       labels=c("Burden (\u22121)","Neutral (0)","Benefit (+1)")) +
  facet_grid(lifestyle_lbl ~ scenario_lbl, switch="x", labeller=scenario_labeller) +
  scale_x_discrete(position="top", limits=c("Carbon","Waste","Material")) +
  labs(title="a. Environmental footprint (per household)",
       subtitle="Y2050 vs. reference run with no lifestyle heterogeneity and BAU infrastructures; colours show direction and rank, not magnitude (see b, c)",
       x=NULL, y=NULL) +
  base_theme

good_labels <- c(nondurable="Non-durable", otherdurable="Other durable",
                 energydurable="Energy-using durable", sharing="PSS energy services",
                 repair="Repair services", energy_direct="Direct energy use")
good_colors <- c("Non-durable"="#E69F00","Other durable"="#F0E442",
                 "Energy-using durable"="#CC79A7","PSS energy services"="#56B4E9",
                 "Repair services"="#D55E00","Direct energy use"="#009E73")

cf_goods  <- c("nondurable","otherdurable","energydurable","sharing","repair")
cf_stages <- c("prod","eol","IW")
CF_TO_T   <- 1e6

compute_cf_change <- function(df, h) {
  by_good <- map_dfr(cf_goods, function(g) {
    stages <- if (g == "repair") c("prod","IW") else cf_stages
    pol <- Reduce(`+`, lapply(stages, function(s) as.numeric(df[[paste0("CF_", s, "_", g, "_", h)]])))
    nm  <- Reduce(`+`, lapply(stages, function(s) as.numeric(df[[paste0("CF_", s, "_", g, "_", h, "_nomod")]])))
    tibble(scenario=df$scenario, lifestyle=df$lifestyle, foresight=df$foresight,
           grp=h, good=g, cf_pol=pol, cf_nm=nm,
           cf_ref_tot=as.numeric(df[[paste0("CF_", h, "_nomod")]]))
  })
  sum14 <- by_good %>%
    group_by(scenario, lifestyle, foresight) %>%
    summarise(sum14_pol=sum(cf_pol), sum14_nm=sum(cf_nm), .groups="drop")
  direct_energy <- tibble(scenario=df$scenario, lifestyle=df$lifestyle, foresight=df$foresight,
                          cf_h_pol=as.numeric(df[[paste0("CF_", h)]]),
                          cf_h_nm =as.numeric(df[[paste0("CF_", h, "_nomod")]])) %>%
    left_join(sum14, by=c("scenario","lifestyle","foresight")) %>%
    transmute(scenario, lifestyle, foresight, grp=h, good="energy_direct",
              cf_pol=cf_h_pol-sum14_pol, cf_nm=cf_h_nm-sum14_nm, cf_ref_tot=cf_h_nm)
  bind_rows(by_good, direct_energy)
}

cf_grp <- map_dfr(groups, ~ compute_cf_change(basket_2050_joined, .x)) %>%
  left_join(pop_lookup, by=c("scenario","lifestyle","foresight")) %>%
  mutate(N=case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious, grp=="lowcarbon"~N_lowcarbon)) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(d_cf=((cf_pol-cf_nm)/N)*CF_TO_T,
         d_cf_pct=(cf_pol-cf_nm)/cf_ref_tot,
         good=factor(good_labels[good], levels=good_labels),
         inc=factor(case_when(grp=="constrained"~"L", grp=="cautious"~"M", grp=="lowcarbon"~"H"),
                    levels=c("L","M","H","E")),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         Ecosystem=factor(scenario, levels=scenario_order_behav, labels=c("BAU","Regressive","Progressive"))) %>%
  filter(lifestyle_lbl %in% c("Ecoactive - All","Affordability - All"))

cf_ref_econ <- map_dfr(groups, ~ compute_cf_change(basket_2050_joined, .x)) %>%
  distinct(scenario, lifestyle, foresight, grp, cf_ref_tot) %>%
  group_by(scenario, lifestyle, foresight) %>%
  summarise(cf_ref_econ=sum(cf_ref_tot), .groups="drop")

cf_agg <- map_dfr(groups, ~ compute_cf_change(basket_2050_joined, .x)) %>%
  left_join(pop_lookup, by=c("scenario","lifestyle","foresight")) %>%
  mutate(N_grp=case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious, grp=="lowcarbon"~N_lowcarbon)) %>%
  group_by(scenario, lifestyle, foresight, good, N_total) %>%
  summarise(cf_pol_tot=sum(cf_pol), cf_nm_tot=sum(cf_nm), .groups="drop") %>%
  left_join(cf_ref_econ, by=c("scenario","lifestyle","foresight")) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(d_cf=(-(cf_pol_tot-cf_nm_tot)/N_total)*CF_TO_T,
         d_cf_pct=-(cf_pol_tot-cf_nm_tot)/cf_ref_econ,
         grp="economy",
         good=factor(good_labels[good], levels=good_labels),
         inc=factor("E", levels=c("L","M","H","E")),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         Ecosystem=factor(scenario, levels=scenario_order_behav, labels=c("BAU","Regressive","Progressive"))) %>%
  filter(lifestyle_lbl %in% c("Ecoactive - All","Affordability - All"))

cf_change_df <- bind_rows(cf_grp, cf_agg)

cf_net_df <- cf_change_df %>%
  group_by(lifestyle_lbl, Ecosystem, inc, grp) %>%
  summarise(net=sum(d_cf), net_pct=sum(d_cf_pct), .groups="drop") %>%
  mutate(group_lbl=factor(case_when(
    grp=="constrained"~"Lower income", grp=="cautious"~"Medium income",
    grp=="lowcarbon"~"Higher income",  grp=="economy"~"Economy-wide"),
    levels=c("Higher income","Medium income","Lower income","Economy-wide")))

p3c <- ggplot(cf_change_df, aes(x=inc, y=d_cf_pct)) +
  geom_col(aes(fill=good), width=0.8, position="stack") +
  geom_hline(yintercept=0, colour="grey40", linewidth=0.3) +
  geom_point(data=cf_net_df, aes(x=inc, y=net_pct, shape=group_lbl),
             inherit.aes=FALSE, size=1.8, colour="grey20") +
  facet_nested(~ lifestyle_lbl + Ecosystem,
               strip=strip_nested(background_x=elem_list_rect(fill=c("grey90","grey96")), by_layer_x=TRUE)) +
  scale_fill_manual("Consumption good", values=good_colors) +
  scale_shape_manual("Income group", values=shapes_sc,
                     labels=c("Higher income"="Higher income (H)", "Medium income"="Medium income (M)",
                              "Lower income"="Lower income (L)",   "Economy-wide"="Economy-wide (E)")) +
  scale_y_continuous(labels=scales::percent_format(accuracy=0.1),
                     breaks=scales::pretty_breaks(4)) +
  labs(title="b. Carbon footprint change by consumption good vs. reference run", x=NULL,
       y="\u0394 Carbon footprint (% of reference)") +
  theme_minimal(base_size=9) +
  theme(panel.grid.major.x=element_blank(), panel.grid.minor=element_blank(),
        panel.background=element_rect(fill="grey95", colour=NA),
        panel.grid.major.y=element_line(colour="white"),
        strip.text=element_text(face="bold", size=7, lineheight=0.9),
        panel.spacing.x=unit(0.08,"lines"), panel.spacing.y=unit(0.5,"lines"),
        plot.title=element_text(face="bold", size=10),
        axis.text.x=element_text(size=8), axis.text.y=element_text(size=8),
        axis.title.y=element_text(size=8, margin=margin(r=8)),
        legend.title=element_text(size=8), legend.text=element_text(size=7),
        legend.key=element_rect(colour="grey95", linewidth=0.2),
        legend.key.size=unit(0.5,"cm"), legend.position="right",
        legend.justification=c(0.5,0.5))

cf_to_g <- 1e12; wf_to_g <- 1
compute_levels <- function(df, h) {
  N <- as.numeric(df[[paste0("CF_",h)]]) / as.numeric(df[[paste0("CF_",h,"_percapita")]])
  C <- as.numeric(df[[paste0("C_",h)]])
  cf_tot <- as.numeric(df[[paste0("CF_",h)]])
  wf_tot <- as.numeric(df[[paste0("WF_",h,"_percapita")]]) * N
  mf_tot <- as.numeric(df[[paste0("MF_",h,"_percapita")]]) * N
  tibble(scenario=df$scenario, lifestyle=df$lifestyle, foresight=df$foresight, grp=h, N=N,
         CF_int=(cf_tot*cf_to_g)/C, WF_int=(wf_tot*wf_to_g)/C, MF_int=(mf_tot*wf_to_g)/C)
}
scatter_df <- map_dfr(groups, ~ compute_levels(basket_2050_joined, .x)) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(group_lbl=relabel_groups(grp),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         Ecosystem=factor(scenario, levels=scenario_order_behav, labels=c("BAU","Regressive","Progressive")))

p3c_intensity_SI <- ggplot(scatter_df, aes(x=MF_int, y=CF_int, fill=group_lbl, shape=Ecosystem)) +
  geom_point(size=3.2, colour="grey30", stroke=0.5, alpha=0.85) +
  scale_fill_manual("Income group",
                    values=c("Lower income"="#FEE090","Medium income"="#FC8D59","Higher income"="#B2182B")) +
  scale_shape_manual("Infrastructures", values=c(BAU=21, Regressive=24, Progressive=23)) +
  scale_x_continuous("Material intensity (g/consumption unit/year)", breaks=scales::pretty_breaks(4)) +
  scale_y_continuous(expression("Carbon intensity (gCO"[2]*"eq/consumption unit/year)"), breaks=scales::pretty_breaks(4)) +
  coord_cartesian(xlim=c(1.61,1.69), ylim=c(1.27,1.35)) +
  labs(title="Intensity is stable across infrastructures but rises for lower-income groups") +
  guides(fill=guide_legend(override.aes=list(shape=21)),
         shape=guide_legend(override.aes=list(fill="grey70"))) +
  theme_minimal(base_size=9) +
  theme(panel.background=element_rect(fill="grey95", colour=NA),
        panel.grid.major=element_line(colour="white"), panel.grid.minor=element_line(colour="white"),
        plot.title=element_text(face="bold", size=10))

wf_to_t  <- 1e-6
wf_goods <- c("nondurable","otherdurable","energydurable","sharing","repair")

compute_wf_change <- function(df, h) {
  map_dfr(wf_goods, function(g) {
    pol <- as.numeric(df[[paste0("WF_",g,"_",h,"_percapita")]])
    nm  <- as.numeric(df[[paste0("WF_",g,"_",h,"_percapita_nomod")]])
    tibble(scenario=df$scenario, lifestyle=df$lifestyle, foresight=df$foresight,
           grp=h, good=g, wf_pol_pc=pol, wf_nm_pc=nm, d_wf=(pol-nm)*wf_to_t,
           wf_ref_pc=as.numeric(df[[paste0("WF_", h, "_percapita_nomod")]]))
  })
}

wf_grp <- map_dfr(groups, ~ compute_wf_change(basket_2050_joined, .x)) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(d_wf_pct=(wf_pol_pc-wf_nm_pc)/wf_ref_pc,
         good=factor(good_labels[good], levels=good_labels),
         inc=factor(case_when(grp=="constrained"~"L", grp=="cautious"~"M", grp=="lowcarbon"~"H"),
                    levels=c("L","M","H","E")),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         Ecosystem=factor(scenario, levels=scenario_order_behav, labels=c("BAU","Regressive","Progressive"))) %>%
  filter(lifestyle_lbl %in% c("Ecoactive - All","Affordability - All"))

wf_ref_econ <- map_dfr(groups, ~ compute_wf_change(basket_2050_joined, .x)) %>%
  distinct(scenario, lifestyle, foresight, grp, wf_ref_pc) %>%
  left_join(pop_lookup, by=c("scenario","lifestyle","foresight")) %>%
  mutate(N_grp=case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious,
                         grp=="lowcarbon"~N_lowcarbon)) %>%
  group_by(scenario, lifestyle, foresight) %>%
  summarise(wf_ref_econ=sum(wf_ref_pc*N_grp), .groups="drop")

wf_agg <- map_dfr(groups, ~ compute_wf_change(basket_2050_joined, .x)) %>%
  left_join(pop_lookup, by=c("scenario","lifestyle","foresight")) %>%
  mutate(N_grp=case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious, grp=="lowcarbon"~N_lowcarbon),
         wf_pol_tot=wf_pol_pc*N_grp, wf_nm_tot=wf_nm_pc*N_grp) %>%
  group_by(scenario, lifestyle, foresight, good, N_total) %>%
  summarise(wf_pol_tot=sum(wf_pol_tot), wf_nm_tot=sum(wf_nm_tot), .groups="drop") %>%
  left_join(wf_ref_econ, by=c("scenario","lifestyle","foresight")) %>%
  filter(foresight=="AE", scenario %in% scenario_order_behav) %>%
  mutate(d_wf=((wf_pol_tot-wf_nm_tot)/N_total)*wf_to_t,
         d_wf_pct=(wf_pol_tot-wf_nm_tot)/wf_ref_econ,
         grp="economy",
         good=factor(good_labels[good], levels=good_labels),
         inc=factor("E", levels=c("L","M","H","E")),
         lifestyle_lbl=factor(lifestyle_labels[lifestyle], levels=lifestyle_labels),
         Ecosystem=factor(scenario, levels=scenario_order_behav, labels=c("BAU","Regressive","Progressive"))) %>%
  filter(lifestyle_lbl %in% c("Ecoactive - All","Affordability - All"))

wf_change_df <- bind_rows(wf_grp, wf_agg)

wf_net_df <- wf_change_df %>%
  group_by(lifestyle_lbl, Ecosystem, inc, grp) %>%
  summarise(net=sum(d_wf), net_pct=sum(d_wf_pct), .groups="drop") %>%
  mutate(group_lbl=factor(case_when(
    grp=="constrained"~"Lower income", grp=="cautious"~"Medium income",
    grp=="lowcarbon"~"Higher income",  grp=="economy"~"Economy-wide"),
    levels=c("Higher income","Medium income","Lower income","Economy-wide")))

p3e <- ggplot(wf_change_df, aes(x=inc, y=d_wf_pct)) +
  geom_col(aes(fill=good), width=0.8, position="stack") +
  geom_hline(yintercept=0, colour="grey40", linewidth=0.3) +
  geom_point(data=wf_net_df, aes(x=inc, y=net_pct, shape=group_lbl),
             inherit.aes=FALSE, size=1.8, colour="grey20") +
  facet_nested(~ lifestyle_lbl + Ecosystem,
               strip=strip_nested(background_x=elem_list_rect(fill=c("grey90","grey96")), by_layer_x=TRUE)) +
  scale_fill_manual("Consumption good", values=good_colors) +
  scale_shape_manual("Income group", values=shapes_sc,
                     labels=c("Higher income"="Higher income (H)", "Medium income"="Medium income (M)",
                              "Lower income"="Lower income (L)",   "Economy-wide"="Economy-wide (E)")) +
  scale_y_continuous(labels=scales::percent_format(accuracy=0.1),
                     breaks=scales::pretty_breaks(4)) +
  labs(title="c. Waste footprint change by consumption good vs. reference run", x=NULL,
       y="\u0394 Waste footprint (% of reference)") +
  theme_minimal(base_size=9) +
  theme(panel.grid.major.x=element_blank(), panel.grid.minor=element_blank(),
        panel.background=element_rect(fill="grey95", colour=NA),
        panel.grid.major.y=element_line(colour="white"),
        strip.text=element_text(face="bold", size=7, lineheight=0.9),
        panel.spacing.x=unit(0.08,"lines"), panel.spacing.y=unit(0.5,"lines"),
        plot.title=element_text(face="bold", size=10),
        axis.text.x=element_text(size=8), axis.text.y=element_text(size=8),
        axis.title.y=element_text(size=8, margin=margin(r=8)),
        legend.title=element_text(size=8), legend.text=element_text(size=7),
        legend.key=element_rect(colour="grey95", linewidth=0.2),
        legend.key.size=unit(0.5,"cm"), legend.position="right",
        legend.justification=c(0.5,0.5))

stack_extent <- function(d, val) {
  d %>% group_by(lifestyle_lbl, Ecosystem, inc) %>%
    summarise(pos=sum(pmax(.data[[val]], 0)), neg=sum(pmin(.data[[val]], 0)), .groups="drop") %>%
    summarise(lo=min(neg, na.rm=TRUE), hi=max(pos, na.rm=TRUE))
}
fp_extent <- bind_rows(stack_extent(cf_change_df, "d_cf_pct"),
                       stack_extent(wf_change_df, "d_wf_pct"))
fp_pct_lim <- c(min(fp_extent$lo), max(fp_extent$hi)) * 1.08

p3c <- p3c + coord_cartesian(ylim=fp_pct_lim)
p3e <- p3e + coord_cartesian(ylim=fp_pct_lim)

top    <- (plot_spacer() | p3b | plot_spacer()) + plot_layout(widths=c(0.5,1,0.5))
bottom <- (p3c | p3e)

fig <- (wrap_elements(top) / wrap_elements(bottom)) + plot_layout(heights=c(1.3,1.0))

ggsave(file.path(out_dir,"fig_environmental_outcomes.pdf"), fig, width=15, height=13, device="pdf")
ggsave(file.path(out_dir,"fig_environmental_outcomes.png"), fig, width=15, height=13, dpi=300)
message("Saved: fig_environmental_outcomes in ", out_dir)
print(fig)

ggsave(file.path(out_dir,"fig2_supplementary_intensity_scatter.pdf"), p3c_intensity_SI, width=8, height=5, device="pdf")
ggsave(file.path(out_dir,"fig2_supplementary_intensity_scatter.png"), p3c_intensity_SI, width=8, height=5, dpi=300)
message("Saved: fig2_supplementary_intensity_scatter in ", out_dir)