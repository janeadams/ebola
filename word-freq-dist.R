require(tidyverse)
require(readxl)

lm_stats <- function(df) {
    m <- lm(y ~ x, df)
    eq <- substitute('slope' == b*', '~~italic(r)^2~"="~r2,
                     list(b = format(unname(coef(m)[2]), digits = 2),
                          r2 = format(summary(m)$r.squared, digits = 3)))
    as.character(as.expression(eq))
}

dat_trig <- read_excel('data/all_paper_data.xlsx', sheet='Trigger Other', na="NA")
question <- 't_q6'

freq_df <- dat_trig %>%
    drop_na(question) %>%
    pull(question) %>%
    str_extract_all('\\w+') %>%
    unlist %>%
    str_to_lower %>%
    table %>%
    as.data.frame %>%
    as_tibble %>%
    arrange(desc(Freq))

count_df <- freq_df %>%
    count(Freq)

plot_dat <- count_df %>%
    transmute(x=log(Freq), y=log(n))

ggplot(plot_dat, aes(x=x, y=y)) +
    geom_point() +
    geom_smooth(method='lm', col='red', se=FALSE, data=filter(plot_dat, x <= 4)) +
    geom_label(x=5, y=3, label=lm_stats(filter(plot_dat, x <= 4)), parse=TRUE) +
    xlim(-.1, 8.1) +
    ylim(0, 7.7)
