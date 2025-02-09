# Excess deaths and excess causes of death




# Notes
# 1. Data for pneumonia is sporadic with some weeks missing.
# 2. Started data at the beginning of January since the first US recorded case is in that month
# 3. There are few different combinations in the types of data included in the excess dataset. I chose to use the weighted, excluding covid deaths data with the excess deaths calculation that uses the point estimate, because that combination had the lowest MAE between the model estimate and the observed number of deaths
# 4. The inset box becomes distorted as more bars are added over time. The coordinates have to be data values. So bar width gets squished as more bars accumulate since the plot size remains the same. Only way I could figure out to remedy me having to continually figure out the correct coordinates was to record and save the constant, then add to it when the data date changes.


# Sections
# 1. Set-up
# 2. Causes of deaths
# 3. Excess Deaths




#@@@@@@@@@@@@@@@
# Set-up ----
#@@@@@@@@@@@@@@@


pacman::p_load(extrafont, swatches, dplyr, lubridate, ggplot2, glue, patchwork, ggtext)


deep_rooted <- swatches::read_palette(glue("{rprojroot::find_rstudio_root_file()}/palettes/Deep Rooted.ase"))

deep_light <- prismatic::clr_lighten(deep_rooted[[7]], shift = .3)
deep_light2 <- prismatic::clr_lighten(deep_rooted[[7]], shift = .2)
purp_light <- prismatic::clr_lighten("#be458c", shift = .15)

natstat_excess_raw <- readr::read_csv("https://data.cdc.gov/api/views/xkkf-xrst/rows.csv?accessType=DOWNLOAD&bom=true&format=true%20target=") %>% 
   janitor::clean_names()

state_wk_cause_raw <- readr::read_csv("https://data.cdc.gov/api/views/u6jv-9ijr/rows.csv?accessType=DOWNLOAD&bom=true&format=true%20target=")

# inset box length constant
xmin_const <- readr::read_rds(glue("{rprojroot::find_rstudio_root_file()}/data/excess-death-xmin.rds"))


#@@@@@@@@@@@@@@@@@@@@@@@@
# Causes of deaths ----
#@@@@@@@@@@@@@@@@@@@@@@@@


ind_cause_raw <- state_wk_cause_raw %>%
   janitor::clean_names() %>%
   filter(jurisdiction == "Indiana")


# get the last week for this year where all diseases have data 
if (max(ind_cause_raw$year) == 2020) {
   data_week <- ind_cause_raw %>%
      # get only this year's weekly counts
      filter(year == 2020) %>% 
      group_by(cause_subgroup) %>%
      # last week for each cause (value repeated for each row)
      mutate(final_week = max(week)) %>% 
      # gets rid of those redundant rows
      distinct(final_week, cause_subgroup) %>%
      ungroup() %>% 
      # get whichever final week is the earliest
      filter(final_week == min(final_week)) %>% 
      pull(final_week)
} else {
   data_week <- ind_cause_raw %>%
      # get only this year's weekly counts
      filter(year == year(today())) %>% 
      group_by(cause_subgroup) %>%
      # last week for each cause (value repeated for each row)
      mutate(final_week = max(week)) %>% 
      # gets rid of those redundant rows
      distinct(final_week, cause_subgroup) %>%
      ungroup() %>% 
      # get whichever final week is the earliest
      filter(final_week == min(final_week)) %>% 
      pull(final_week)
}

# not sure how CDC is going to handle 2021 on excess deaths; Using 5 for this value (below) for now
# the number of years in this data that are prior to this year
# data_prev_years <- ind_cause_raw %>% 
#    distinct(year) %>% 
#    summarize(prev_years = n()-1) %>% 
#    pull(prev_years)


# calculate percent difference from the totals this year to the avg of years 2015 to 2019 during the same portion of the year
# Individual diseases


# ind_cause_20 <- ind_cause_raw %>%
#    # only use weeks that have data
#    filter(year != 2021) %>%
#    select(-jurisdiction, -state_abbreviation, -suppress, -note, -type) %>%
#    # creates 2 groups: current year and years prior to this year
#    mutate(period = ifelse(year <= 2019, "prev_years", "this_year")) %>%
#    group_by(period, cause_subgroup) %>%
#    # calc up-to-date totals for each group and each disease
#    summarize(yr_to_date_totals = sum(number_of_deaths)) %>%
#    # calcs average for the yearly, up-to-date, prev_years group and leaves this_year's counts alone
#    mutate(yr_to_date_avgs = ifelse(period == "prev_years",
#                                       #yr_to_date_totals / data_prev_years,
#                                       yr_to_date_totals / 5,
#                                       yr_to_date_totals),
#           # clean and shorten some names
#           cause_subgroup = recode(cause_subgroup, "Alzheimer disease and dementia" = "Alzheimer's disease and dementia",
#                                "Hypertensive dieases" = "Hypertensive diseases",
#                                "Other diseases of the circulatory system" = "Other circulatory diseases",
#                                "Other diseases of the respiratory system" = "Other respiratory diseases")) %>%
#    select(-yr_to_date_totals,) %>%
#    # splitting the two groups' avgs into two cols
#    tidyr::pivot_wider(id_cols = "cause_subgroup",
#                       names_from = "period",
#                       values_from = "yr_to_date_avgs") %>%
#    # calc percent difference between this years deaths and avg deaths from years prior
#    mutate(pct_diff = round(((this_year - prev_years) / prev_years)*100, 1),
#           labels = scales::percent(pct_diff/100, accuracy = 0.1),
#           cause_subgroup = factor(cause_subgroup) %>%
#              forcats::fct_reorder(pct_diff)) %>% 
#    top_n(pct_diff, n = 6)


ind_cause_21 <- ind_cause_raw %>%
   # only use weeks that have data
   filter(week <= data_week,
          year != 2020) %>%
   select(-jurisdiction, -state_abbreviation, -suppress, -note, -type) %>%
   # creates 2 groups: current year and years prior to this year
   mutate(period = ifelse(year <= 2019, "prev_years", "this_year")) %>%
   group_by(period, cause_subgroup) %>%
   # calc up-to-date totals for each group and each disease
   summarize(yr_to_date_totals = sum(number_of_deaths)) %>%
   # calcs average for the yearly, up-to-date, prev_years group and leaves this_year's counts alone
   mutate(yr_to_date_avgs = ifelse(period == "prev_years",
                                      #yr_to_date_totals / data_prev_years,
                                      yr_to_date_totals / 5,
                                      yr_to_date_totals),
          # clean and shorten some names
          cause_subgroup = recode(cause_subgroup, "Alzheimer disease and dementia" = "Alzheimer's disease and dementia",
                               "Hypertensive dieases" = "Hypertensive diseases",
                               "Other diseases of the circulatory system" = "Other circulatory diseases",
                               "Other diseases of the respiratory system" = "Other respiratory diseases")) %>%
   select(-yr_to_date_totals,) %>%
   # splitting the two groups' avgs into two cols
   tidyr::pivot_wider(id_cols = "cause_subgroup",
                      names_from = "period",
                      values_from = "yr_to_date_avgs") %>%
   # calc percent difference between this years deaths and avg deaths from years prior
   mutate(pct_diff = round(((this_year - prev_years) / prev_years)*100, 1),
          labels = scales::percent(pct_diff/100, accuracy = 0.1),
          cause_subgroup = factor(cause_subgroup) %>%
             forcats::fct_reorder(pct_diff)) %>% 
   top_n(pct_diff, n = 6) %>% 
   mutate(nudge_x = ifelse(pct_diff < 0, -5.5, 6.8))



# lollipop plot
# individual diseases
excess_lol <- ggplot(ind_cause_21, aes(x = pct_diff, y = cause_subgroup,
                      label = labels)) +
   expand_limits(x = c(min(ind_cause_21$pct_diff -11), max(ind_cause_21$pct_diff + 11))) +
   geom_segment(aes(x = 0, xend = pct_diff, y = cause_subgroup, yend = cause_subgroup),
                color = "white") +
   geom_point(color = "#61c8b7", size=4) +
   # percent difference text
   geom_text(nudge_x = ind_cause_21$nudge_x,
             col = "white", fontface = "bold",
             size = 4) +
   labs(x = NULL, y = NULL,
        title = "2021 Causes of Death: percent difference from historic averages",
        subtitle = "*Percent above average*") +
   theme(text = element_text(family = "Roboto"),
         plot.title = element_text(color = "white",
                              family = "Roboto",
                              face = "bold",
                              size = 10),
         plot.subtitle = element_textbox_simple(color = "white",
                              family = "Roboto",
                              face = "bold",
                              size = 9),
         legend.position = "none",
         axis.text.x = element_text(color = "white",
                                    size = 9),
         axis.text.y = element_text(color = "white",
                                    size = 11,
                                    face = "bold",
                                    family = "Roboto"),
         axis.ticks.y = element_blank(),
         panel.background = element_rect(fill = "black",
                                         color = NA),
         plot.background = element_rect(fill = "black",
                                        color = "white",
                                        size = 1.0),
         plot.margin = margin(12, 12, 12, 12, "pt"),
         panel.border = element_blank(),
         panel.grid.minor = element_blank(),
         panel.grid.major.y = element_blank(),
         panel.grid.major.x = element_line(color = deep_rooted[[7]]))


# Convert plot to grob
inset_plot <- ggplotGrob(excess_lol)

# left-align title, subtitle with y labels
inset_plot$layout[which(inset_plot$layout$name == "title"),]$l <- 2
inset_plot$layout[which(inset_plot$layout$name == "subtitle"),]$l <- 2

# change sharp corners of the border to rounded ones
bg <- inset_plot$grobs[[1]]
round_bg <- grid::roundrectGrob(x=bg$x, y=bg$y, width=bg$width, height=bg$height,
                          r=unit(0.1, "snpc"),
                          just=bg$just, name=bg$name, gp=bg$gp, vp=bg$vp)
inset_plot$grobs[[1]] <- round_bg




#@@@@@@@@@@@@@@@@@@@@@
# Excess deaths ----
#@@@@@@@@@@@@@@@@@@@@@


# filtering, selecting, and getting data into long format for ggplot
ind_excess <- natstat_excess_raw %>%
   # combines 2 descriptions of data to create a unique col
   tidyr::unite(col = "condition", type, outcome) %>%
   filter(state == "Indiana",
          week_ending_date > "2020-01-01",
          condition == "Predicted (weighted)_All causes, excluding COVID-19"
   ) %>% 
   select(week_ending_date, observed_number, average_expected_count, excess_higher_estimate) %>% 
   tidyr::pivot_longer(cols = c("average_expected_count", "excess_higher_estimate"), names_to = "type", values_to = "value") %>% 
   mutate(type = factor(type, levels = c("excess_higher_estimate", "average_expected_count")),
          # only want labels for excess deaths, otherwise blank
          label = ifelse(value == 0, "", value),
          label = ifelse(type == "average_expected_count", "", label))

# current data date
data_date <- ind_excess %>%
   summarize(week_ending_date = max(week_ending_date)) %>% 
   pull(week_ending_date)

# summary stats (totals)
excess_summary <- ind_excess %>%
   group_by(type) %>% 
   summarize(val_sum = sum(value),
             noncov_class_deaths = sum(observed_number)) %>%
   mutate(pct = scales::percent(round(val_sum/sum(val_sum), 2)),
          sum_text = scales::comma(val_sum),
          nccd_text = scales::comma(noncov_class_deaths))

summary_text <- glue("
Totals<br>
<b style='color: #C8619DFF'>Excess Deaths</b>: {excess_summary$sum_text[[1]]} ({excess_summary$pct[[1]]})<br>
                     <b style='color: #7F7E84FF'>Expected Deaths</b>: {excess_summary$sum_text[[2]]} ({excess_summary$pct[[2]]})<br>
                     <b>Non-COVID Classified Deaths</b>: {excess_summary$nccd_text[[1]]}")


# beginning of my convoluted way to automate the determination the coordinates of the inset plot
# get date of old inset constant
old_xmin_date <- xmin_const %>% 
   slice_max(data_date) %>% 
   pull(data_date)
# get value of old inset constant
old_xmin_const <- xmin_const %>% 
   slice_max(data_date) %>% 
   pull(xmin_const)
# get value of old summary position
old_summary_pos <- xmin_const %>% 
   slice_max(data_date) %>% 
   pull(summary_pos)

# add new constant if data is new, else keep old constant
if (data_date > old_xmin_date) {
   new_xmin_const <- xmin_const %>% 
      add_row(data_date = data_date,
              xmin_const = old_xmin_const + 4,
              summary_pos = old_summary_pos + 2)
} else {
   new_xmin_const <- xmin_const
}

# pull the position constants for the summary box and inset plot
box_const <- new_xmin_const %>% 
   slice_max(data_date) %>% 
   pull(xmin_const)
summary_pos <- new_xmin_const %>% 
   slice_max(data_date) %>% 
   pull(summary_pos)


# need to programmatically figure out the inset plot coordinates
coord_constant <- ind_excess %>% 
   # estimation of plot length date range from original plot
   # increasing left number moves box left and vice versa
   slice((n()-25):(n()-2)) %>% 
   # 61 days was original plot length
   # %/% is integer arithmetic so I don't get a decimal
   summarize(date_len = as.numeric(last(week_ending_date) - first(week_ending_date)),
             # value gets added to both sides, so divide by 2
             # increasing this number increases length of box
             constant = (82 - date_len) %/% 2) %>% 
   pull(constant)

# coordinate dates of inset plot
coord_dates <- ind_excess %>% 
   # estimation of plot length range from original plot
   # numbers need to be same as above
   slice((n()-25):(n()-2)) %>% 
   # the left coordinate need some extra
   summarize(xmin = first(week_ending_date) - coord_constant - box_const,
             xmax = last(week_ending_date) + coord_constant)



excess_bar <- ggplot(ind_excess, aes(x = week_ending_date, y = value,
                       fill = type, label = label)) +
   expand_limits(y = 2600) +
   geom_col() +
   scale_y_continuous(labels = scales::label_comma(), n.breaks = 6) +
   scale_x_date(date_breaks = "2 month", date_labels = "%b") +
   scale_fill_manual(values = list(excess_higher_estimate = purp_light[[1]],
                                   average_expected_count = deep_light[[1]])) +
   # excess death values
   ggfittext::geom_bar_text(col = "white",
                            position = "stack",
                            outside = TRUE,
                            # font size in pt
                            min.size = 6.4,
                            padding.x = unit(0.75, "mm"),
                            padding.y = unit(0.75, "mm")) +
   # summary annotation
   geom_textbox(aes(summary_pos, 2075),
                 label = summary_text, halign = 0,
                 col = "white", fill = "black",
                width = 0.30, size = 5, hjust = 0.45) +
   labs(x = NULL, y = NULL,
        title = "Estimating potentially misclassified deaths by comparing this year's deaths with historic trends",
        subtitle = glue("Bars represent deaths in Indiana where COVID-19 is not recorded as the underlying or multiple cause of death\nLast updated: {data_date}"),
        caption = "Source: National Center for Health Statistics, & Centers for Disease Control and Prevention") +
   theme(text = element_text(family = "Roboto"),
         plot.title = element_text(family = "Roboto",
                              color = "white",
                              size = 15,
                              face = "bold"),
         plot.subtitle = element_text(family = "Roboto",
                                 color = "white",
                                 size = 14),
         plot.caption = element_text(family = "Roboto",
                                color = "white",
                                size = 12),
         legend.position = "none",
         axis.text.x = element_text(color = "white",
                                    size = 11,
                                    face = "bold"),
         axis.text.y = element_text(color = "white",
                                    size = 13,
                                    face = "bold"),
         panel.background = element_rect(fill = "black",
                                         color = NA),
         plot.background = element_rect(fill = "black",
                                        color = NA),
         
         panel.border = element_blank(),
         panel.grid.minor = element_blank(),
         panel.grid.major = element_line(color = deep_rooted[[7]]))



# insert lollipop plot into the bar chart
both_charts <- excess_bar +
   annotation_custom(grob = inset_plot,
                     xmin = coord_dates$xmin[[1]],
                     xmax = coord_dates$xmax[[1]],
                     ymin = 1780, ymax = 2700)

plot_path <- glue("{rprojroot::find_rstudio_root_file()}/plots/excess-death-col-{data_date}.png")

ggsave(plot_path, plot = both_charts,
       dpi = "screen", width = 33, height = 20,
       units = "cm", device = ragg::agg_png())

# save that damn stupid constant
readr::write_rds(new_xmin_const, glue("{rprojroot::find_rstudio_root_file()}/data/excess-death-xmin.rds"))

