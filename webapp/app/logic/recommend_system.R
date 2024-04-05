box::use(
  quanteda[corpus, docvars, docnames, dfm, convert, dfm_tfidf, dfm_subset],
  quanteda.textstats[textstat_simil],
  utils[head],
  spacyr[spacy_parse],
  dplyr[mutate, filter, select],
  data.table[setorderv],
)



create_ref_corpus <- function(data_tab, field) {
  corp <- corpus(data_tab, text_field = field)
  docnames(corp) <- data_tab$title
  return(corp)
}


spacy_pipeline <- function(corp) {
  res <- corp |> spacy_parse() 
  res_tokens <- res |> 
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
  docvars(corp_dfm) <- docvars(corp)
  
  saveRDS(corp_dfm, "./data/ref_corp_dfm.rds")
  
  
  corp_tfidf <- corp_dfm |> dfm_tfidf()
  
  saveRDS(corp_tfidf, "./data/ref_corp_tfidf.rds")
}

#' export
get_recommendations <- function(corp_dfm, query_book_titles, genres, simil_method = "cosine", how_many) {
  query_dfm <- dfm_subset(corp_dfm, docname_ %in% query_book_titles)
  rest_dfm <- corp_dfm[grep(genres, paste(docvars(corp_dfm)$genres)),]
  rest_dfm <- dfm_subset(rest_dfm, !docname_ %in% query_book_titles)
  

  tstat <- textstat_simil(
    query_dfm, rest_dfm,
    margin = "documents",
    method = simil_method
  ) |>
  as.data.frame()
  setorderv(tstat, cols = c(simil_method), order = -1)
  return(tstat[1:how_many,]$document2)
}

#' export
parse_recommendations <- function(rec_book_names, data_tab) {
  subset_books <- data_tab |> 
    filter(
      title %in% rec_book_names  
    ) |>
    select(
      title, average_rating, description, url, image_url, genres, author_name
    )
  return(subset_books)
}

# hp3 <- dfm_subset(corp_dfm, docname_ %in% "A Game of Thrones (A Song of Ice and Fire, #1)")
# tstat <- textstat_simil(hp3, corp_dfm,
#                         margin = "documents", method = "ejaccard")
# stat_list <- as.list(tstat)
# ordered <- sort(unlist(stat_list), decreasing = TRUE)
# top_ten <- head(ordered, n = 10)
# names(top_ten) <- names(top_ten) |> gsub(pattern = "\\..*$", replacement = "")
# top_ten
