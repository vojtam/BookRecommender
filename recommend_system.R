
# install quanteda corpora & dicts ----------------------------------------
remotes::install_github("quanteda/quanteda.corpora")
remotes::install_github("kbenoit/quanteda.dictionaries")
remotes::install_github("quanteda/readtext") 
remotes::install_github("quanteda.textplots")
remotes::install_github("quanteda.textstats")



# load libraries ----------------------------------------------------------


library(tidyverse)
library(ggplot2)
library(spacyr)
library(quanteda)
library(readtext)
library("quanteda.textplots")
library("quanteda.textstats")


# 1) Create a corpus ------------------------------------------------------
dataset_path <- file.path("../data/dataset_goodreads_filtered_description.csv")

text <- readtext(dataset_path, text_field = "description")
corp <- text |> corpus()
docnames(corp) <- paste(text$book_id, text$title, sep = "-")



# 2) Tokenize corpus ------------------------------------------------------

# remove numbers and punctuation, convert to lower
process_corpus_to_dfm <- function(corpus) {
  res_tokens <- corpus |>
  spacy_parse() |> 
    filter(
      ! pos %in% c("PUNCT", "PART", "NUM", "SYM")
    ) |>
    mutate(
      lemma = tolower(lemma)
    ) |>
    as.tokens(
      use_lemma = TRUE
    ) |>
    tokens_remove(stopwords("en"))
  
  corp_dfm <- res_tokens |> dfm()
  return(corp_dfm)
}


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


plot_wordcloud <- function(dfm, name) {
  png(paste0("data/plots/", name, ".png"), res = 200, width = 800, height = 800)
  textplot_wordcloud(dfm, min_count = 6, random_order = FALSE,
                                        rotation = .25, max_size = 20, 
                                        color = RColorBrewer::brewer.pal(8, "Dark2"))
  dev.off()
}


# 7) word cloud -----------------------------------------------------------
set.seed(100)

dfm_fantasy <- corpus_subset(corp, genre %in% grep("*fantasy*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_fantasy, "fantasy")


dfm_romance <- corpus_subset(corp, genre %in% grep("*romance*", genre, value = TRUE)) |>
  process_corpus_to_dfm()
  
plot_wordcloud(dfm_romance, "romance")



dfm_children <- corpus_subset(corp, genre %in% grep("*children*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_children, "children")



dfm_crime <- corpus_subset(corp, genre %in% grep("*crime*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_crime, "crime")



dfm_YA <- corpus_subset(corp, genre %in% grep("*YA*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_YA, "YA")



dfm_hist <- corpus_subset(corp, genre %in% grep("*history_biography*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_hist, "history")


dfm_poetry <- corpus_subset(corp, genre %in% grep("*poetry*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_poetry, "poetry")



dfm_comics <- corpus_subset(corp, genre %in% grep("*graphic_comics*", genre, value = TRUE)) |>
  process_corpus_to_dfm()

plot_wordcloud(dfm_comics, "comics")

