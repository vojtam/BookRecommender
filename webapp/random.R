library(ggplot2)
library(data.table)
library(purrr)
library(stringi)


desc_length <-  data.table(desc_len = stri_count_words(data$description))

hist <- ggplot(desc_length, aes(x = desc_len)) +
  geom_histogram(fill = "#FFC5BA", color = "black") +
  xlim(c(0, 750)) +
  labs(x = "Number of words in description.") +
  theme_minimal()

hist


log <- fread("system_recommendations_log.csv")
log <- unique(log)

ggplot(log, aes(fill = model, x = model)) + 
  geom_bar() +
  theme_minimal()
