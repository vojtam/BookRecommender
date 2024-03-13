box::use(
  quanteda[corpus, docnames, dfm, convert, dfm_tfidf, dfm_subset],
  quanteda.textstats[textstat_simil],
  utils[head],
  spacyr[spacy_parse],
  dplyr[mutate, filter],
)



create_ref_corpus <- function(data_tab) {
  corp <- corpus(data_tab, text_field = "description")
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
  
  saveRDS(corp_dfm, "./data/ref_corp_dfm.rds")
  
  
  corp_tfidf <- corp_dfm |> dfm_tfidf()
  
  saveRDS(corp_tfidf, "./data/ref_corp_tfidf.rds")
}


get_recommendations <- function(corp_dfm, query_book_titles, simil_method = "ejaccard") {
  query_dfm <- dfm_subset(corp_dfm, docname_ %in% query_book_titles)
  
  tstat <- textstat_simil(
    query_dfm, corp_dfm,
    margin = "documents",
    method = simil_method
  )
  
  stat_list <- as.list(tstat)
  ordered <- sort(unlist(stat_list), decreasing = TRUE)
  top_ten <- head(ordered, n = 10)
  names(top_ten) <- names(top_ten) |> gsub(pattern = "\\..*$", replacement = "")
  return(names(top_ten))
}

# hp3 <- dfm_subset(corp_dfm, docname_ %in% "A Game of Thrones (A Song of Ice and Fire, #1)")
# tstat <- textstat_simil(hp3, corp_dfm,
#                         margin = "documents", method = "ejaccard")
# stat_list <- as.list(tstat)
# ordered <- sort(unlist(stat_list), decreasing = TRUE)
# top_ten <- head(ordered, n = 10)
# names(top_ten) <- names(top_ten) |> gsub(pattern = "\\..*$", replacement = "")
# top_ten
