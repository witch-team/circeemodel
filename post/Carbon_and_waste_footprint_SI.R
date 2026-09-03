
stopifnot(exists("basket_2050_joined"), exists("compute_cf_change"),
          exists("compute_wf_change"), exists("pop_lookup"))

group_levels_all <- c("Higher income", "Medium income", "Lower income", "Economy-wide")
relabel_all <- function(grp) factor(case_when(
  grp == "constrained" ~ "Lower income",  grp == "cautious" ~ "Medium income",
  grp == "lowcarbon"   ~ "Higher income", grp == "economy"  ~ "Economy-wide"),
  levels = group_levels_all)

cf_grp_all <- map_dfr(groups, ~ compute_cf_change(basket_2050_joined, .x)) %>%
  left_join(pop_lookup, by = c("scenario","lifestyle","foresight")) %>%
  mutate(N = case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious,
                       grp=="lowcarbon"~N_lowcarbon)) %>%
  filter(foresight == "AE", scenario %in% scenario_order_behav) %>%
  mutate(d_cf     = ((cf_pol - cf_nm) / N) * CF_TO_T,
         d_cf_pct = (cf_pol - cf_nm) / cf_ref_tot,
         good = factor(good_labels[good], levels = good_labels),
         inc  = factor(case_when(grp=="constrained"~"L", grp=="cautious"~"M",
                                 grp=="lowcarbon"~"H"), levels = c("L","M","H","E")),
         lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         Ecosystem = factor(scenario, levels = scenario_order_behav,
                            labels = c("BAU","Regressive","Progressive")))

cf_ref_econ_all <- map_dfr(groups, ~ compute_cf_change(basket_2050_joined, .x)) %>%
  distinct(scenario, lifestyle, foresight, grp, cf_ref_tot) %>%
  group_by(scenario, lifestyle, foresight) %>%
  summarise(cf_ref_econ = sum(cf_ref_tot), .groups = "drop")

cf_agg_all <- map_dfr(groups, ~ compute_cf_change(basket_2050_joined, .x)) %>%
  left_join(pop_lookup, by = c("scenario","lifestyle","foresight")) %>%
  group_by(scenario, lifestyle, foresight, good, N_total) %>%
  summarise(cf_pol_tot = sum(cf_pol), cf_nm_tot = sum(cf_nm), .groups = "drop") %>%
  left_join(cf_ref_econ_all, by = c("scenario","lifestyle","foresight")) %>%
  filter(foresight == "AE", scenario %in% scenario_order_behav) %>%
  mutate(d_cf     = (-(cf_pol_tot - cf_nm_tot) / N_total) * CF_TO_T,
         d_cf_pct = -(cf_pol_tot - cf_nm_tot) / cf_ref_econ,
         grp = "economy",
         good = factor(good_labels[good], levels = good_labels),
         inc  = factor("E", levels = c("L","M","H","E")),
         lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         Ecosystem = factor(scenario, levels = scenario_order_behav,
                            labels = c("BAU","Regressive","Progressive")))

cf_change_df_all <- bind_rows(cf_grp_all, cf_agg_all)

cf_net_df_all <- cf_change_df_all %>%
  group_by(lifestyle_lbl, Ecosystem, inc, grp) %>%
  summarise(net = sum(d_cf), net_pct = sum(d_cf_pct), .groups = "drop") %>%
  mutate(group_lbl = relabel_all(grp))

wf_grp_all <- map_dfr(groups, ~ compute_wf_change(basket_2050_joined, .x)) %>%
  filter(foresight == "AE", scenario %in% scenario_order_behav) %>%
  mutate(d_wf_pct = (wf_pol_pc - wf_nm_pc) / wf_ref_pc,
         good = factor(good_labels[good], levels = good_labels),
         inc  = factor(case_when(grp=="constrained"~"L", grp=="cautious"~"M",
                                 grp=="lowcarbon"~"H"), levels = c("L","M","H","E")),
         lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         Ecosystem = factor(scenario, levels = scenario_order_behav,
                            labels = c("BAU","Regressive","Progressive")))

wf_ref_econ_all <- map_dfr(groups, ~ compute_wf_change(basket_2050_joined, .x)) %>%
  distinct(scenario, lifestyle, foresight, grp, wf_ref_pc) %>%
  left_join(pop_lookup, by = c("scenario","lifestyle","foresight")) %>%
  mutate(N_grp = case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious,
                           grp=="lowcarbon"~N_lowcarbon)) %>%
  group_by(scenario, lifestyle, foresight) %>%
  summarise(wf_ref_econ = sum(wf_ref_pc * N_grp), .groups = "drop")

wf_agg_all <- map_dfr(groups, ~ compute_wf_change(basket_2050_joined, .x)) %>%
  left_join(pop_lookup, by = c("scenario","lifestyle","foresight")) %>%
  mutate(N_grp = case_when(grp=="constrained"~N_constrained, grp=="cautious"~N_cautious,
                           grp=="lowcarbon"~N_lowcarbon),
         wf_pol_tot = wf_pol_pc * N_grp, wf_nm_tot = wf_nm_pc * N_grp) %>%
  group_by(scenario, lifestyle, foresight, good, N_total) %>%
  summarise(wf_pol_tot = sum(wf_pol_tot), wf_nm_tot = sum(wf_nm_tot), .groups = "drop") %>%
  left_join(wf_ref_econ_all, by = c("scenario","lifestyle","foresight")) %>%
  filter(foresight == "AE", scenario %in% scenario_order_behav) %>%
  mutate(d_wf     = ((wf_pol_tot - wf_nm_tot) / N_total) * wf_to_t,
         d_wf_pct = (wf_pol_tot - wf_nm_tot) / wf_ref_econ,
         grp = "economy",
         good = factor(good_labels[good], levels = good_labels),
         inc  = factor("E", levels = c("L","M","H","E")),
         lifestyle_lbl = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         Ecosystem = factor(scenario, levels = scenario_order_behav,
                            labels = c("BAU","Regressive","Progressive")))

wf_change_df_all <- bind_rows(wf_grp_all, wf_agg_all)

wf_net_df_all <- wf_change_df_all %>%
  group_by(lifestyle_lbl, Ecosystem, inc, grp) %>%
  summarise(net = sum(d_wf), net_pct = sum(d_wf_pct), .groups = "drop") %>%
  mutate(group_lbl = relabel_all(grp))

stack_extent_all <- function(d, val) {
  d %>% group_by(lifestyle_lbl, Ecosystem, inc) %>%
    summarise(pos = sum(pmax(.data[[val]], 0)), neg = sum(pmin(.data[[val]], 0)),
              .groups = "drop") %>%
    summarise(lo = min(neg, na.rm = TRUE), hi = max(pos, na.rm = TRUE))
}
fp_extent_all <- bind_rows(stack_extent_all(cf_change_df_all, "d_cf_pct"),
                           stack_extent_all(wf_change_df_all, "d_wf_pct"))
fp_pct_lim_all <- c(min(fp_extent_all$lo), max(fp_extent_all$hi)) * 1.08

si_theme <- theme_minimal(base_size = 9) +
  theme(panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "grey95", colour = NA),
        panel.grid.major.y = element_line(colour = "white"),
        strip.text = element_text(face = "bold", size = 7, lineheight = 0.9),
        panel.spacing.x = unit(0.08, "lines"), panel.spacing.y = unit(0.5, "lines"),
        plot.title = element_text(face = "bold", size = 10),
        axis.text.x = element_text(size = 8), axis.text.y = element_text(size = 8),
        axis.title.y = element_text(size = 8, margin = margin(r = 8)),
        legend.title = element_text(size = 8), legend.text = element_text(size = 7),
        legend.key = element_rect(colour = "grey95", linewidth = 0.2),
        legend.key.size = unit(0.5, "cm"),
        legend.position = "right", legend.justification = c(0.5, 0.5))

p3c_all <- ggplot(cf_change_df_all, aes(x = inc, y = d_cf_pct)) +
  geom_col(aes(fill = good), width = 0.8, position = "stack") +
  geom_hline(yintercept = 0, colour = "grey40", linewidth = 0.3) +
  geom_point(data = cf_net_df_all, aes(x = inc, y = net_pct, shape = group_lbl),
             inherit.aes = FALSE, size = 1.8, colour = "grey20") +
  facet_nested(~ lifestyle_lbl + Ecosystem,
               strip = strip_nested(background_x = elem_list_rect(fill = c("grey90","grey96")),
                                    by_layer_x = TRUE)) +
  scale_fill_manual("Consumption good", values = good_colors) +
  scale_shape_manual("Income group", values = shapes_sc) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1),
                     breaks = scales::pretty_breaks(4)) +
  coord_cartesian(ylim = fp_pct_lim_all) +
  labs(title = "a. Carbon footprint change by consumption good vs. reference run",
       x = NULL, y = "\u0394 Carbon footprint (% of reference)") +
  si_theme

p3e_all <- ggplot(wf_change_df_all, aes(x = inc, y = d_wf_pct)) +
  geom_col(aes(fill = good), width = 0.8, position = "stack") +
  geom_hline(yintercept = 0, colour = "grey40", linewidth = 0.3) +
  geom_point(data = wf_net_df_all, aes(x = inc, y = net_pct, shape = group_lbl),
             inherit.aes = FALSE, size = 1.8, colour = "grey20") +
  facet_nested(~ lifestyle_lbl + Ecosystem,
               strip = strip_nested(background_x = elem_list_rect(fill = c("grey90","grey96")),
                                    by_layer_x = TRUE)) +
  scale_fill_manual("Consumption good", values = good_colors, guide = "none") +
  scale_shape_manual("Income group", values = shapes_sc) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1),
                     breaks = scales::pretty_breaks(4)) +
  coord_cartesian(ylim = fp_pct_lim_all) +
  labs(title = "b. Waste footprint change by consumption good vs. reference run",
       x = NULL, y = "\u0394 Waste footprint (% of reference)") +
  si_theme

fig_bc_all <- (p3c_all / p3e_all) + plot_layout(guides = "collect") &
  theme(legend.position = "right", legend.justification = "center")

ggsave(file.path(out_dir, "fig_carbon_waste_all_lifestyles.pdf"), fig_bc_all,
       width = 22, height = 12, device = "pdf")
ggsave(file.path(out_dir, "fig_carbon_waste_all_lifestyles.png"), fig_bc_all,
       width = 22, height = 12, dpi = 300)
message("Saved: fig_carbon_waste_all_lifestyles in ", out_dir)

print(fig_bc_all)