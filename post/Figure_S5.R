library(tidyverse)
library(ggh4x)

levels_dir <- "~/Desktop/Paper_Rethink_Results/data_zenodo/data_figures_maintext_&_si/Outputs/CIRCEE_output_levels"
out_dir    <- "~/Desktop/Paper_Rethink_Results/figures"
foresight  <- "AE"

scen_levels <- c("Baseline", "Regressive", "Progressive")
scen_labels <- c("Current", "Concentrated", "Broad")

lifestyles <- c("ecoactive_ecoactive", "affordability_affordability",
                "ecoactive_affordability", "affordability_ecoactive")
lifestyle_labels <- c(
  ecoactive_ecoactive         = "Ecoactive - All",
  affordability_affordability = "Affordability - All",
  ecoactive_affordability     = "Ecoactive - Sharing\nAffordability - Sufficiency",
  affordability_ecoactive     = "Affordability - Sharing\nEcoactive - Sufficiency")

grp_levels <- c("Lower income", "Medium income", "Higher income")
pal_grp <- c("Lower income" = "#D55E00", "Medium income" = "#0072B2",
             "Higher income" = "#009E73")

read_share <- function(path) {
  d <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  d <- d[!duplicated(d$Row), ]
  yrs <- paste0("Y", seq(2020, 2050, by = 5))
  get <- function(row) as.numeric(d[d$Row == row, yrs])
  sh  <- function(h) {
    pss  <- get("p_sharing") * get(paste0("ES_sharing_", h))
    home <- get(paste0("p_home_", h)) * get(paste0("ES_home_", h))
    pss / (pss + home)
  }
  tibble(
    year = seq(2020, 2050, by = 5),
    `Lower income`  = sh("constrained"),
    `Medium income` = sh("cautious"),
    `Higher income` = sh("lowcarbon")
  ) %>%
    pivot_longer(-year, names_to = "group", values_to = "share")
}

shares <- map_dfr(lifestyles, function(ls) {
  map_dfr(scen_levels, function(sc) {
    p <- file.path(levels_dir, paste0(ls, "_", foresight, "_", sc, ".csv"))
    if (!file.exists(p)) { message("missing: ", p); return(NULL) }
    read_share(p) %>% mutate(lifestyle = ls, Scenario = sc)
  })
}) %>%
  mutate(lifestyle = factor(lifestyle_labels[lifestyle], levels = lifestyle_labels),
         Scenario  = factor(Scenario, levels = scen_levels, labels = scen_labels),
         group     = factor(group, levels = grp_levels))

ref <- read_share(file.path(levels_dir, paste0("NoModifiers_", foresight, ".csv"))) %>%
  mutate(group = factor(group, levels = grp_levels))

snap <- shares %>% filter(year == 2050)
ref50 <- ref %>% filter(year == 2050)

p_share <- ggplot(snap, aes(x = Scenario, y = share, fill = group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_hline(data = ref50, aes(yintercept = share, colour = group),
             linetype = "dashed", linewidth = 0.4, show.legend = FALSE) +
  facet_wrap(~ lifestyle, nrow = 1) +
  scale_fill_manual("Lifestyle group", values = pal_grp) +
  scale_colour_manual(values = pal_grp) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     expand = expansion(mult = c(0, 0.08))) +
  labs(x = NULL,
       y = "PSS share of energy-service spending, 2050",
       caption = paste("Dashed lines: Reference, the CIRCEE model without the LIFE coupling",
                       "(no behavioural modifiers, Current enablement).",
                       "\nShares are of each lifestyle group's spending on energy services.")) +
  theme_minimal(base_size = 9) +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor   = element_blank(),
        strip.text  = element_text(face = "bold", size = 7, lineheight = 0.9),
        axis.text.x = element_text(size = 7),
        legend.position = "bottom",
        plot.caption = element_text(hjust = 0, size = 7, colour = "grey30"))

ggsave(file.path(out_dir, "figS_market_share_levels.pdf"), p_share,
       width = 11, height = 4, device = "pdf")
ggsave(file.path(out_dir, "figS_market_share_levels.png"), p_share,
       width = 11, height = 4, dpi = 300)
print(p_share)

cat("\n2050 PSS share of energy-service spending (%)\n\n")
bind_rows(
  ref50 %>% mutate(lifestyle = "Reference", Scenario = "-"),
  snap %>% mutate(lifestyle = as.character(lifestyle), Scenario = as.character(Scenario))
) %>%
  mutate(share = round(100 * share, 2)) %>%
  pivot_wider(names_from = group, values_from = share) %>%
  select(lifestyle, Scenario, `Lower income`, `Medium income`, `Higher income`) %>%
  as.data.frame() %>% print(row.names = FALSE)

cat("\nrange across all configurations and groups: ",
    sprintf("%.2f%% to %.2f%%\n", 100*min(snap$share), 100*max(snap$share)))
