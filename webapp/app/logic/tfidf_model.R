box::use(
  quanteda[corpus, docvars, docnames, dfm, convert, dfm_tfidf, dfm_subset],
  quanteda.textstats[textstat_simil],
  utils[head],
  spacyr[spacy_parse],
  dplyr[mutate, filter, select],
  data.table[setorderv],
)

box::use(
  app/logic/utils[parse_recommendations]
)


create_ref_corpus <- function(data_tab, field) {
  corp <- corpus(data_tab, text_field = field)
  docnames(corp) <- data_tab$book_id
  return(corp)
}


spacy_pipeline <- function(corp) {
  browser()
  res <- corp |> spacy_parse(nounphrase = TRUE) 
  res_tokens <- res |> 
    filter(
      ! pos %in% c("PUNCT", "PART", "NUM", "SYM"),
      ! entity %in% c("PERSON_B", "PERSON_I") 
    ) |>
    mutate(
      lemma = tolower(lemma)
    )
  
  all <- res_tokens |>
    group_by(sentence_id, nounphrase) |>
    mutate(nounphrase_id = cumsum(nounphrase %in% c("beg_root", ""))) |>
    group_by(sentence_id, nounphrase_id) |>
    mutate(has_entity = ifelse(entity!= "", 1, 0)) |>
    as.data.table()
  
  
  phrases <- all |>
    filter(nounphrase_id == 0, has_entity == 1) 
  
  non_phrases <- fsetdiff(all, phrases)
  
  phrases <- phrases |>
    mutate(nounphrase_id = cumsum(nounphrase == "beg"), seq_id = -1)
  
  phrases[1, ]$seq_id <- 0
  
  phrases$seq_id <- cumsum(c(TRUE, phrases$sentence_id[-1]!= phrases$sentence_id[-nrow(phrases)] | 
                               phrases$token_id[-1]!= phrases$token_id[-nrow(phrases)] + 1))
  
  phrases_concat <- phrases[,c("token", "lemma", "pos", "entity") := 
                              .(paste(token, collapse = " "), 
                                paste(lemma, collapse = " "), 
                                paste(pos, collapse = " "), 
                                paste(entity, collapse = " ")), 
                            by =.(nounphrase_id, sentence_id, seq_id)]
  
  phrases_concat <- unique(phrases_concat, by = c("sentence_id", "nounphrase_id", "token", "seq_id"))
  non_phrases[, c("nounphrase_id", "has_entity") := NULL]
  phrases_concat[, c("nounphrase_id", "has_entity", "seq_id") := NULL]
  
  joined <- rbindlist(list(non_phrases, phrases_concat))
  setorder(joined, doc_id, sentence_id, token_id)
  
  class(joined) <- c("spacyr_parsed", class(joined))
  res_tokens <- joined |> as.tokens(
    use_lemma = TRUE
  )
  
  corp_dfm <- res_tokens |> dfm()
  docvars(corp_dfm) <- docvars(corp)
  
  saveRDS(corp_dfm, "./data/ref_corp_dfm_new.rds")
  
  
  corp_tfidf <- corp_dfm |> dfm_tfidf()
  
  saveRDS(corp_tfidf, "./data/ref_corp_tfidf_new.rds")
}

#' export
get_recommendations <- function(corp_dfm, data_tab, query_book_ids, genres, simil_method = "cosine", how_many) {
  query_dfm <- dfm_subset(corp_dfm, docname_ %in% query_book_ids)
  if (!is.null(genres)) {
    genre_ids <- docvars(corp_dfm)[grepl(genres, paste(docvars(corp_dfm)$genres)),]$book_id
    corp_dfm <- dfm_subset(corp_dfm, docname_ %in% genre_ids)
  }
  rest_dfm <- dfm_subset(corp_dfm, !docname_ %in% query_book_ids)
  

  tstat <- textstat_simil(
    query_dfm, rest_dfm,
    margin = "documents",
    method = simil_method
  ) |>
  as.data.frame()
  setorderv(tstat, cols = c(simil_method), order = -1)
  recommendations <- parse_recommendations(tstat[1:how_many,]$document2, data_tab, "TFIDF")
  # recommendations <- data_tab |> 
  #   filter(
  #     title %in% docvars(dfm_subset(rest_dfm, docname_ %in% tstat[1:how_many,]$document2))$title
  #   ) |>
  #   select(
  #     title, average_rating, description, url, image_url, genres, author_name
  #   )
  # recommendations$model <- "TFIDF"
  return(recommendations)
}




