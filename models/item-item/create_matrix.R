BOOK_IDS <- colnames(RATING_MATRIX)[2:ncol(RATING_MATRIX)]
files <- list.files("weighted_batches", full.names = T)
similarity_matrix <- matrix(nrow = length(BOOK_IDS), ncol = length(BOOK_IDS), dimnames = list(BOOK_IDS, BOOK_IDS))


for (file in files) {
  similarity_list <- readRDS(file)
  similarity_list <- similarity_list[!is.na(similarity_list)]
  for (item in similarity_list) {
    book_id1 = item[["book_id1"]]
    book_id2 = item[["book_id2"]]
    similarity = item[["sim"]]
    similarity_matrix[book_id1, book_id2] = similarity
    similarity_matrix[book_id2, book_id1] = similarity
  }
  print(file)
}

similarity_df <- data.frame(matrix(nrow = length(BOOK_IDS), ncol = 100))
rownames(similarity_df) <- BOOK_IDS

for (book_id in BOOK_IDS) {
  print(book_id)
  sorted <- sort(similarity_matrix[book_id, ], decreasing = T)
  if (length(sorted) > 0) {
    names <- sorted |> head(100) |> names()
    names <- c(names, rep(NA, 100 - length(names)))
    similarity_df[book_id, ] <- names
  }
}


write.csv(similarity_df, "data/item_to_item_similarity_dataframe.csv")

target_book_id <- "8127"
similar_book_ids <- strtoi(similarity_df[target_book_id, ])

titles <- c(DATA_BOOKS |> filter(book_id == strtoi(target_book_id)) |> select(title))
for (similar_book_id in similar_book_ids) {
  titles <- append(titles, DATA_BOOKS |> filter(book_id == strtoi(similar_book_id)) |> select(title))
}
print(titles[1:20])

