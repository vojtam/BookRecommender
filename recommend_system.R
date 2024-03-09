
# install quanteda corpora & dicts ----------------------------------------
remotes::install_github("quanteda/quanteda.corpora")
remotes::install_github("kbenoit/quanteda.dictionaries")
remotes::install_github("quanteda/readtext") 
install.packages("quanteda.textplots")
install.packages("quanteda.textstats")


# load libraries ----------------------------------------------------------


library(tidyverse)
library(ggplot2)
library(spacyr)
library(quanteda)
library(readtext)
library("quanteda.textplots")
library("quanteda.textstats")


# 1) Create a corpus ------------------------------------------------------
dataset_path <- file.path("data/dataset_goodreads_filtered.csv")

text <- readtext(dataset_path, text_field = "description")
corp <- text |> corpus()
docnames(corp) <- paste(text$book_id, text$title, sep = "-")



# 2) Tokenize corpus ------------------------------------------------------

# remove numbers and punctuation, convert to lower
corp_tokens <- tokens(corp, remove_numbers = TRUE, remove_punct = TRUE) |>
  tokens_tolower()



# 3) remove stopwords -----------------------------------------------------

corp_tokens <- corp_tokens |> tokens_remove(stopwords("en"))

# 5) search in the corpus -------------------------------------------------

# search with regex
kwic(corp_tokens, pattern = "Fear", valuetype = "regex") |>
  head()

# search with phrases
kwic(corp_tokens, pattern = phrase("Czech Republic")) |>
  head()



# 6) constructing document-feature matrix ---------------------------------
dfm_matrix <- dfm(corp_tokens)
topfeatures(dfm_matrix, 20)



# 7) word cloud -----------------------------------------------------------
set.seed(100)

textplot_wordcloud(dfm_matrix, min_count = 6, random_order = FALSE,
                   rotation = .25,
                   color = RColorBrewer::brewer.pal(8, "Dark2"))


dfm_fantasy <- corpus_subset(corp, genre == "fantasy") |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE) |>
  tokens_remove(stopwords("en")) |>
  dfm()


textplot_wordcloud(dfm_fantasy, min_count = 6, random_order = FALSE,
                   rotation = .25,
                   color = RColorBrewer::brewer.pal(8, "Dark2"))


unique(docvars(corp)$genre)

dfm_romance <- corpus_subset(corp, genre %in% grep("*romance*", genre, value = TRUE)) |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE) |>
  tokens_remove(stopwords("en")) |>
  dfm()


textplot_wordcloud(dfm_romance, min_count = 6, random_order = FALSE,
                   rotation = .25,
                   color = RColorBrewer::brewer.pal(8, "Dark2"))



dfm_children <- corpus_subset(corp, genre %in% grep("*children*", genre, value = TRUE)) |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE) |>
  tokens_remove(stopwords("en")) |>
  dfm()


textplot_wordcloud(dfm_children, min_count = 6, random_order = FALSE,
                   rotation = .25,
                   color = RColorBrewer::brewer.pal(8, "Dark2"))


dfm_crime <- corpus_subset(corp, genre %in% grep("*crime*", genre, value = TRUE)) |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE) |>
  tokens_remove(stopwords("en")) |>
  dfm()


textplot_wordcloud(dfm_crime, min_count = 6, random_order = FALSE,
                   rotation = .25,
                   color = RColorBrewer::brewer.pal(8, "Dark2"))



dfm_harry_potter <- corpus_subset(corp, title %in% grep("*Harry Potter*", title, value = TRUE)) |>
  tokens(remove_punct = TRUE) |>
  tokens_wordstem(language = "en") |>
  tokens_remove(stopwords("en")) |>
  dfm()

dfm_harry_potter3 <- corpus_subset(corp, title == "Harry Potter and the Prisoner of Azkaban (Harry Potter, #3)") |>
  tokens(remove_punct = TRUE) |>
  tokens_wordstem(language = "en") |>
  tokens_remove(stopwords("en")) |>
  dfm()

dfm_harry_potter5 <- corpus_subset(corp, title == "Harry Potter and the Order of the Phoenix (Harry Potter, #5)") |>
  tokens(remove_punct = TRUE) |>
  tokens_wordstem(language = "en") |>
  tokens_remove(stopwords("en")) |>
  dfm()



tstat <- textstat_simil(dfm_harry_potter3, dfm_harry_potter5,
                              margin = "documents", method = "cosine")
as.list(tstat)



