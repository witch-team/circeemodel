library(tidyverse)
library(patchwork)

ZEN  <- path.expand("~/Desktop/Paper_Rethink_Results/data_zenodo")
MAIN <- file.path(ZEN, "data_figures_maintext_&_si")
SENS <- file.path(ZEN, "data_figures_sensitivity")
OUT  <- path.expand("~/Desktop/Paper_Rethink_Results/figures")

dir.create(
  OUT,
  showWarnings = FALSE,
  recursive = TRUE
)

drivers <- c(
  "ecoactive_ecoactive",
  "affordability_affordability"
)

driver_lbl <- c(
  ecoactive_ecoactive         = "Ecoactive - All",
  affordability_affordability = "Affordability - All"
)

pal_ls <- c(
  "Ecoactive - All"       = "#1B7837",
  "Affordability - All"  = "#762A83"
)

settings <- tribble(
  ~tag,        ~setting,
  NA,          "Calibrated",
  "HABIT045",  "Habit 0.45",
  "HABIT065",  "Habit 0.65",
  "SIGMAC130", "Elasticity 1.3",
  "SIGMAC160", "Elasticity 1.6"
)

set_levels <- c(
  "Habit 0.45",
  "Calibrated",
  "Habit 0.65",
  "Elasticity 1.3",
  "Elasticity 1.6"
)

pick <- function(...) {
  
  p <- file.path(...)
  
  f <- sub(
    "\\.csv$",
    "_CFfix.csv",
    p
  )
  
  if (file.exists(f)) {
    f
  } else {
    p
  }
}

scen_path <- function(ls, tag) {
  
  if (is.na(tag)) {
    
    file.path(
      MAIN,
      "Outputs/CIRCEE_output_levels",
      paste0(
        ls,
        "_AE_Baseline.csv"
      )
    )
    
  } else {
    
    pick(
      SENS,
      "Outputs/CIRCEE_output_levels",
      paste0(
        ls,
        "_AE_Baseline_",
        tag,
        ".csv"
      )
    )
  }
}

ref_path <- function(tag) {
  
  if (is.na(tag)) {
    
    file.path(
      MAIN,
      "Outputs/CIRCEE_output_levels",
      "NoModifiers_AE.csv"
    )
    
  } else {
    
    pick(
      SENS,
      "Outputs/NoModifiers_levels",
      paste0(
        "NoModifiers_",
        tag,
        ".csv"
      )
    )
  }
}

wel_path <- function(ls, tag) {
  
  if (is.na(tag)) {
    
    file.path(
      MAIN,
      "Welfare",
      paste0(
        ls,
        "_AE"
      ),
      "welfare_CEV_lifetime.csv"
    )
    
  } else {
    
    file.path(
      SENS,
      "Welfare",
      paste0(
        ls,
        "_AE_Baseline_",
        tag
      ),
      "welfare_CEV_lifetime.csv"
    )
  }
}

lev <- function(p) {
  
  d <- read.csv(
    p,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  
  d[
    !duplicated(d$Row),
    ,
    drop = FALSE
  ]
}

gv <- function(
    d,
    row,
    yr = 2050
) {
  
  col <- paste0(
    "Y",
    yr
  )
  
  x <- d[
    d$Row == row,
    col
  ]
  
  if (!length(x)) {
    return(NA_real_)
  }
  
  as.numeric(x)
}

shocks_csv <- "~/Desktop/circeemodel/data/JPN/raw/shocks.csv"

omega_raw <- read.csv(
  shocks_csv,
  sep = ";",
  header = FALSE,
  stringsAsFactors = FALSE,
  col.names = c(
    "Variable",
    "Region",
    "Year",
    "Value"
  )
)

omega_tab <- omega_raw %>%
  filter(
    Variable %in% c(
      "omegga_lowcarbon",
      "omegga_cautious"
    )
  ) %>%
  transmute(
    Variable,
    year = as.integer(Year),
    Value = as.numeric(Value)
  ) %>%
  pivot_wider(
    names_from = Variable,
    values_from = Value
  ) %>%
  transmute(
    year,
    omega_lowcarbon =
      omegga_lowcarbon,
    omega_cautious =
      omegga_cautious,
    omega_constrained =
      1 -
      omegga_lowcarbon -
      omegga_cautious
  )

omega_2050 <- omega_tab %>%
  filter(
    year == 2050
  )

if (nrow(omega_2050) != 1) {
  stop(
    "Could not find a unique 2050 omega row in shocks.csv."
  )
}

nhh <- function(
    d,
    g,
    yr = 2050
) {
  
  gv(
    d,
    paste0(
      "CF_",
      g
    ),
    yr
  ) /
    gv(
      d,
      paste0(
        "CF_",
        g,
        "_percapita"
      ),
      yr
    )
}

refuse <- function(
    d,
    ref,
    g,
    yr = 2050
) {
  
  inv_pol <-
    gv(
      d,
      paste0(
        "Inv_ed_new_",
        g
      ),
      yr
    ) +
    gv(
      d,
      paste0(
        "Inv_ed_new_tild_",
        g
      ),
      yr
    ) +
    gv(
      d,
      paste0(
        "Inv_ed_repair_",
        g
      ),
      yr
    )
  
  inv_ref <-
    gv(
      ref,
      paste0(
        "Inv_ed_new_",
        g
      ),
      yr
    ) +
    gv(
      ref,
      paste0(
        "Inv_ed_new_tild_",
        g
      ),
      yr
    ) +
    gv(
      ref,
      paste0(
        "Inv_ed_repair_",
        g
      ),
      yr
    )
  
  100 *
    (
      inv_ref -
        inv_pol
    ) /
    inv_ref
}

rethink <- function(
    d,
    ref,
    g,
    yr = 2050
) {
  
  ratio_pol <-
    gv(
      d,
      paste0(
        "ES_sharing_",
        g
      ),
      yr
    ) /
    gv(
      d,
      paste0(
        "ES_home_",
        g
      ),
      yr
    )
  
  ratio_ref <-
    gv(
      ref,
      paste0(
        "ES_sharing_",
        g
      ),
      yr
    ) /
    gv(
      ref,
      paste0(
        "ES_home_",
        g
      ),
      yr
    )
  
  100 *
    (
      ratio_pol -
        ratio_ref
    ) /
    ratio_ref
}

pcap <- function(
    d,
    ref,
    pre,
    g,
    yr = 2050
) {
  
  scenario_percap <-
    gv(
      d,
      paste0(
        pre,
        "_",
        g,
        "_percapita"
      ),
      yr
    )
  
  reference_percap <-
    gv(
      ref,
      paste0(
        pre,
        "_",
        g,
        "_percapita"
      ),
      yr
    )
  
  100 *
    (
      1 -
        scenario_percap /
        reference_percap
    )
}

access_ratio <- function(
    d,
    yr = 2050
) {
  
  omega_low <- omega_2050$omega_constrained
  omega_med <- omega_2050$omega_cautious
  omega_high <- omega_2050$omega_lowcarbon
  
  es_low <-
    gv(
      d,
      "ES_constrained",
      yr
    ) /
    omega_low
  
  es_med <-
    gv(
      d,
      "ES_cautious",
      yr
    ) /
    omega_med
  
  es_high <-
    gv(
      d,
      "ES_lowcarbon",
      yr
    ) /
    omega_high
  
  es_low /
    es_high
}

cum_co2 <- function(
    d,
    start_year = 2018,
    end_year = 2050
) {
  
  years <- start_year:end_year
  
  vals <- sapply(
    years,
    function(y) {
      
      gv(
        d,
        "CO2_economy",
        y
      ) +
        gv(
          d,
          "CO2_incineration",
          y
        )
    }
  )
  
  sum(
    vals,
    na.rm = TRUE
  )
}

dmc_total <- function(
    d,
    yr = 2050
) {
  
  gv(
    d,
    "DMC",
    yr
  )
}

waste_total <- function(
    d,
    yr = 2050
) {
  
  sum(
    gv(
      d,
      "MW_energydurables",
      yr
    ),
    gv(
      d,
      "MW_otherdurables",
      yr
    ),
    gv(
      d,
      "MW_nondurables",
      yr
    ),
    gv(
      d,
      "IW",
      yr
    ),
    na.rm = TRUE
  )
}

rows <- list()

for (ls in drivers) {
  
  for (i in seq_len(nrow(settings))) {
    
    tag <- settings$tag[i]
    set <- settings$setting[i]
    
    ps <- scen_path(
      ls,
      tag
    )
    
    pr <- ref_path(
      tag
    )
    
    if (
      !file.exists(ps) ||
      !file.exists(pr)
    ) {
      
      message(
        "Missing scenario/reference file: ",
        ps
      )
      
      next
    }
    
    s <- lev(ps)
    r <- lev(pr)
    
    refuse_lower <-
      refuse(
        s,
        r,
        "constrained"
      )
    
    refuse_medium <-
      refuse(
        s,
        r,
        "cautious"
      )
    
    refuse_higher <-
      refuse(
        s,
        r,
        "lowcarbon"
      )
    
    rethink_lower <-
      rethink(
        s,
        r,
        "constrained"
      )
    
    rethink_medium <-
      rethink(
        s,
        r,
        "cautious"
      )
    
    rethink_higher <-
      rethink(
        s,
        r,
        "lowcarbon"
      )
    
    carbon_lower <-
      pcap(
        s,
        r,
        "CF",
        "constrained"
      )
    
    carbon_medium <-
      pcap(
        s,
        r,
        "CF",
        "cautious"
      )
    
    carbon_higher <-
      pcap(
        s,
        r,
        "CF",
        "lowcarbon"
      )
    
    waste_lower <-
      pcap(
        s,
        r,
        "WF",
        "constrained"
      )
    
    waste_medium <-
      pcap(
        s,
        r,
        "WF",
        "cautious"
      )
    
    waste_higher <-
      pcap(
        s,
        r,
        "WF",
        "lowcarbon"
      )
    
    material_lower <-
      pcap(
        s,
        r,
        "MF",
        "constrained"
      )
    
    material_medium <-
      pcap(
        s,
        r,
        "MF",
        "cautious"
      )
    
    material_higher <-
      pcap(
        s,
        r,
        "MF",
        "lowcarbon"
      )
    
    co2_s <-
      cum_co2(
        s
      )
    
    co2_r <-
      cum_co2(
        r
      )
    
    cumulative_co2_pct <-
      100 *
      (
        co2_s /
          co2_r -
          1
      )
    
    dmc_s <-
      dmc_total(
        s
      )
    
    dmc_r <-
      dmc_total(
        r
      )
    
    dmc_pct <-
      100 *
      (
        dmc_s /
          dmc_r -
          1
      )
    
    waste_s <-
      waste_total(
        s
      )
    
    waste_r <-
      waste_total(
        r
      )
    
    waste_pct <-
      100 *
      (
        waste_s /
          waste_r -
          1
      )
    
    access <-
      access_ratio(
        s
      )
    
    cev_lower  <- NA_real_
    cev_medium <- NA_real_
    cev_higher <- NA_real_
    
    wp <-
      wel_path(
        ls,
        tag
      )
    
    if (
      file.exists(wp)
    ) {
      
      w <-
        read.csv(
          wp,
          check.names = FALSE,
          stringsAsFactors = FALSE
        )
      
      w <-
        w[
          trimws(w[[1]]) == "Baseline",
          ,
          drop = FALSE
        ]
      
      if (
        nrow(w) > 0
      ) {
        
        cev_lower <-
          as.numeric(
            w$CEV_lifetime_constrained[1]
          )
        
        cev_medium <-
          as.numeric(
            w$CEV_lifetime_cautious[1]
          )
        
        cev_higher <-
          as.numeric(
            w$CEV_lifetime_lowcarbon[1]
          )
      }
    }
    
    welfare_spread <-
      max(
        c(
          cev_lower,
          cev_medium,
          cev_higher
        ),
        na.rm = TRUE
      ) -
      min(
        c(
          cev_lower,
          cev_medium,
          cev_higher
        ),
        na.rm = TRUE
      )
    
    welfare_gap <-
      cev_higher -
      cev_lower
    
    rows[[length(rows) + 1]] <- tibble(
      
      driver =
        driver_lbl[ls],
      
      setting =
        set,
      
      `Refuse - Lower income` =
        refuse_lower,
      
      `Refuse - Medium income` =
        refuse_medium,
      
      `Refuse - Higher income` =
        refuse_higher,
      
      `Rethink - Lower income` =
        rethink_lower,
      
      `Rethink - Medium income` =
        rethink_medium,
      
      `Rethink - Higher income` =
        rethink_higher,
      
      `Carbon footprint - Lower income` =
        carbon_lower,
      
      `Carbon footprint - Medium income` =
        carbon_medium,
      
      `Carbon footprint - Higher income` =
        carbon_higher,
      
      `Waste footprint - Lower income` =
        waste_lower,
      
      `Waste footprint - Medium income` =
        waste_medium,
      
      `Waste footprint - Higher income` =
        waste_higher,
      
      `Material footprint - Lower income` =
        material_lower,
      
      `Material footprint - Medium income` =
        material_medium,
      
      `Material footprint - Higher income` =
        material_higher,
      
      `Cumulative CO2 emissions` =
        cumulative_co2_pct,
      
      `Domestic material consumption` =
        dmc_pct,
      
      `Waste` =
        waste_pct,
      
      `Access ratio (low/high)` =
        access,
      
      `Welfare CEV spread` =
        welfare_spread,
      
      `Welfare CEV gap (higher-lower)` =
        welfare_gap
    )
  }
}

D <- bind_rows(rows) %>%
  mutate(
    
    driver =
      factor(
        driver,
        levels = driver_lbl
      ),
    
    setting =
      factor(
        setting,
        levels = set_levels
      ),
    
    calib =
      setting == "Calibrated"
  )

print(D)

write.csv(
  D,
  file.path(
    OUT,
    "table_sensitivity_indicators.csv"
  ),
  row.names = FALSE
)

x_labels <- c(
  
  "Habit 0.45" =
    "Habit\n0.45",
  
  "Calibrated" =
    "Calibrated",
  
  "Habit 0.65" =
    "Habit\n0.65",
  
  "Elasticity 1.3" =
    "Elasticity\n1.3",
  
  "Elasticity 1.6" =
    "Elasticity\n1.6"
)

mk <- function(
    vars,
    ttl,
    sub,
    ylab,
    file,
    ncol = 2,
    hline = 0
) {
  
  d <-
    D %>%
    select(
      driver,
      setting,
      calib,
      all_of(vars)
    ) %>%
    pivot_longer(
      all_of(vars),
      names_to = "indicator",
      values_to = "value"
    ) %>%
    mutate(
      indicator =
        factor(
          indicator,
          levels = vars
        )
    )
  
  p <-
    ggplot(
      d,
      aes(
        x = setting,
        y = value,
        colour = driver,
        group = driver
      )
    )
  
  if (!is.na(hline)) {
    
    p <-
      p +
      geom_hline(
        yintercept = hline,
        colour = "grey75",
        linewidth = 0.3
      )
  }
  
  p <-
    p +
    
    geom_line(
      linewidth = 0.4,
      alpha = 0.6
    ) +
    
    geom_point(
      aes(
        shape = calib,
        size = calib
      ),
      fill = "white",
      stroke = 0.7
    ) +
    
    facet_wrap(
      ~ indicator,
      ncol = ncol,
      scales = "free_y"
    ) +
    
    scale_colour_manual(
      "Lifestyle driver",
      values = pal_ls
    ) +
    
    scale_shape_manual(
      values = c(
        `FALSE` = 21,
        `TRUE`  = 23
      ),
      guide = "none"
    ) +
    
    scale_size_manual(
      values = c(
        `FALSE` = 1.8,
        `TRUE` = 2.8
      ),
      guide = "none"
    ) +
    
    scale_x_discrete(
      labels = x_labels
    ) +
    
    labs(
      title = ttl,
      subtitle = sub,
      x = NULL,
      y = ylab,
      
      caption =
        paste(
          "Diamonds: calibrated run (habit persistence 0.55,",
          "elasticity of substitution between energy services",
          "and other consumption 0.98).",
          "Each sensitivity run is compared with its Reference."
        )
    ) +
    
    theme_minimal(
      base_size = 9
    ) +
    
    theme(
      
      panel.grid.minor =
        element_blank(),
      
      strip.text =
        element_text(
          face = "bold",
          size = 8
        ),
      
      axis.text.x =
        element_text(
          size = 7,
          lineheight = 0.9
        ),
      
      legend.position =
        "bottom",
      
      plot.caption =
        element_text(
          hjust = 0,
          size = 7,
          colour = "grey30"
        )
    )
  
  height <-
    2 +
    2.2 *
    ceiling(
      length(vars) /
        ncol
    )
  
  ggsave(
    file.path(
      OUT,
      paste0(
        file,
        ".pdf"
      )
    ),
    p,
    width = 7.5,
    height = height,
    device = "pdf"
  )
  
  ggsave(
    file.path(
      OUT,
      paste0(
        file,
        ".png"
      )
    ),
    p,
    width = 7.5,
    height = height,
    dpi = 600
  )
  
  return(p)
}

p_practices <- mk(
  
  vars = c(
    
    "Refuse - Lower income",
    "Refuse - Medium income",
    "Refuse - Higher income",
    
    "Rethink - Lower income",
    "Rethink - Medium income",
    "Rethink - Higher income"
  ),
  
  ttl =
    "Sensitivity of circular-practice indicators",
  
  sub =
    "Change relative to Reference",
  
  ylab =
    "Change (%)",
  
  file =
    "Sensitivity_Circular_Practices",
  
  ncol = 3,
  
  hline = 0
)

p_footprints <- mk(
  
  vars = c(
    
    "Carbon footprint - Lower income",
    "Carbon footprint - Medium income",
    "Carbon footprint - Higher income",
    
    "Waste footprint - Lower income",
    "Waste footprint - Medium income",
    "Waste footprint - Higher income",
    
    "Material footprint - Lower income",
    "Material footprint - Medium income",
    "Material footprint - Higher income"
  ),
  
  ttl =
    "Sensitivity of environmental footprints",
  
  sub =
    "Change relative to Reference; positive values indicate footprint reductions",
  
  ylab =
    "Change in footprint (% of Reference)",
  
  file =
    "Sensitivity_Environmental_Footprints",
  
  ncol = 3,
  
  hline = 0
)

p_macro <- mk(
  
  vars = c(
    
    "Cumulative CO2 emissions",
    
    "Domestic material consumption",
    
    "Waste"
  ),
  
  ttl =
    "Sensitivity of macro-level environmental outcomes",
  
  sub =
    "Change relative to Reference",
  
  ylab =
    "Change (%)",
  
  file =
    "Sensitivity_Macro",
  
  ncol = 3,
  
  hline = 0
)

p_distribution <- mk(
  
  vars = c(
    
    "Access ratio (low/high)",
    
    "Welfare CEV spread",
    
    "Welfare CEV gap (higher-lower)"
  ),
  
  ttl =
    "Sensitivity of distributional outcomes",
  
  sub =
    "Access equity and lifetime welfare equity relative to Reference",
  
  ylab =
    "Ratio / percentage points",
  
  file =
    "Sensitivity_Distributional",
  
  ncol = 3,
  
  hline = NA_real_
)

print(p_practices)
print(p_footprints)
print(p_macro)
print(p_distribution)

combined_sensitivity <-
  (
    p_practices /
      p_footprints /
      p_macro /
      p_distribution
  ) +
  plot_layout(
    heights = c(
      1,
      1.5,
      0.65,
      0.65
    )
  )

ggsave(
  file.path(
    OUT,
    "Sensitivity_All_Indicators.pdf"
  ),
  combined_sensitivity,
  width = 7.5,
  height = 15,
  device = "pdf"
)

ggsave(
  file.path(
    OUT,
    "Sensitivity_All_Indicators.png"
  ),
  combined_sensitivity,
  width = 7.5,
  height = 15,
  dpi = 600
)