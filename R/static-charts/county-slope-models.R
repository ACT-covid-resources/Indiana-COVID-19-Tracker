# Counties

# Fits and visualizes log-linear models to positive cases for  Indiana counties.

# Notes
# 1. Modelling cumulative cases because daily cases means I have to add 1 to the zeros in order to do a log transformation. Then the interpretation is increase in log(cases + 1) and I don't want to deal with that.
# 2. Scaling by population produces the same results
# 3. Per NYT data dictionary. Cases = cumulative positive cases




# Set-up

pacman::p_load(extrafont, dplyr, tsibble, fable, ggplot2, ggtext, glue)

palette <- pals::brewer.oranges(10)


# remove scientific notations
options(scipen=999)
nyt_dat <- readr::read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")



# Process data

# basic cleaning
counties_dat <- nyt_dat %>%
   filter(state == "Indiana",
             county != "Unknown") %>%
   rename(positives = cases) %>% 
   select(-state, -fips, -deaths) %>% 
   # can't log transform zeros
   mutate(positives = ifelse(positives == 0,
                             1e-10,
                             positives)) %>% 
   tidyr::drop_na() %>% 
   as_tsibble(index = "date", key = "county")
   
   

# current date of the data
data_date <- counties_dat %>% 
   as_tibble() %>%
   summarize(date = max(date)) %>% 
   pull(date)


# log-linear models for each county using last 14 days
county_pos_models <- counties_dat %>%
   filter(date >= lubridate::today()-14) %>% 
   model(log_mod = TSLM(log(positives) ~ trend())) %>% 
   mutate(coef_info = purrr::map(log_mod, broom::tidy)) %>% 
   tidyr::unnest(coef_info) %>% 
   filter(term == "trend()") %>% 
   mutate(estimate = exp(estimate))


# Labels
# slope estimates
pos_lbl_dat <- county_pos_models %>% 
   select(county, estimate) %>% 
   mutate(pos_estimate = round((estimate - 1)*100, 1),
          pos_est_text = as.character(pos_estimate) %>% 
             paste0(., "%")) %>% 
   select(-estimate)

# filter latest data, add labels, filter top 20
pos_bar_dat <- counties_dat %>% 
   filter(date == max(date)) %>% 
   left_join(pos_lbl_dat, by = "county") %>% 
   ungroup() %>% 
   mutate(county = as.factor(county)) %>% 
   top_n(20, wt = pos_estimate) %>% 
   arrange(desc(pos_estimate)) %>% 
   slice(1:20)


# bar chart
# reorder county by slope estimate
county_pos_bar <- ggplot(pos_bar_dat, aes(y = reorder(county, pos_estimate), x = pos_estimate)) +
   geom_col(aes(fill = pos_estimate)) +
   expand_limits(x = max(pos_bar_dat$pos_estimate)*1.05) +
   # slopes
   geom_text(aes(label = pos_est_text), hjust = -0.3,  size = 4, color = "white", fontface = "bold") +
   # counts
   geom_text(aes(label = positives), hjust = 1.3,  size = 4, color = "black", fontface = "bold") +
   # na.value is color of data values above 20%
   scale_fill_gradientn(colors = palette, limits = c(0.01,20),
                        guide = 'none', na.value = "#7F2704") +
   labs(x = NULL, y = NULL,
        title = "Estimated change in <b style='color:#B28330'>cumulative positive tests</b> per day",
        subtitle = glue("Calculated over the previous 14 days\nTotal number of positive tests in black"),
        caption = glue("Last updated: {data_date}\nSource: The New York Times, based on reports from state and local health agencies")) +
   theme(plot.title = element_textbox_simple(size = 16,
                                             color = "white",
                                             family = "Roboto"),
         plot.subtitle = element_text(size = 12,
                                      color = "white"),
         plot.caption = element_text(color = "white",
                                     size = 12),
         text = element_text(family = "Roboto"),
         axis.ticks = element_blank(),
         axis.text.x = element_blank(),
         axis.text.y = element_text(color = "white",
                                    size = 11,
                                    face = "bold"),
         panel.background = element_rect(fill = "black",
                                         color = NA),
         plot.background = element_rect(fill = "black",
                                        color = NA),
         panel.border = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank())


plot_path <- glue("{rprojroot::find_rstudio_root_file()}/plots/county-pos-bar-{data_date}.png")

ggsave(plot_path, plot = county_pos_bar,
       dpi = "screen", width = 33, height = 20,
       units = "cm", device = ragg::agg_png())


