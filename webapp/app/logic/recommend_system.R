box::use(
  quanteda[corpus, docnames, dfm, convert, dfm_tfidf],
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
  
  #corp_dfm_dt <- corp_dfm |> convert(to = "data.frame")
  
  corp_tfidf <- corp_dfm |> dfm_tfidf()
  
  write.csv2(corp_dfm_dt, file = "data/corpus_dfm.csv")
  
}