# libraries
library(tidyverse)
library(dplyr)
library(tidyr)
library(purrr)
library(data.table)


# datasets
DATA_BOOKS <- read.csv("data/dataset_goodreads_filtered.csv")

DATA_REVS <- read.csv("data/user_ratings_all.csv", stringsAsFactors = TRUE)
users_multiple_revs <- DATA_REVS |> 
  group_by(user_id) |>
  dplyr::summarise(n_reviews = n(), .groups = "drop") |>
  filter(n_reviews >= 30)
DATA_REVS <- DATA_REVS |>
  filter(user_id %in% users_multiple_revs$user_id) 


RATING_MATRIX <- dcast(as.data.table(DATA_REVS), user_id ~ book_id, value.var = "rating") |> as_tibble()

user_average_rating_vector <- rowMeans(RATING_MATRIX[,-1], na.rm=TRUE)
NORMALIZED_RATING_MATRIX <- sweep(RATING_MATRIX[,-1], 1, user_average_rating_vector)

BOOK_IDS <- colnames(RATING_MATRIX)[2:ncol(RATING_MATRIX)]


# adjusted cosine similarity
cosine_similarity <- function(x, y) {
  similarity <- x %*% y / sqrt(x %*% x * y %*% y)
  return(similarity[1,1])
}

books_cosine_similarity <- function(book_id1, book_id2) {
  x <- pull(NORMALIZED_RATING_MATRIX, book_id1)
  y <- pull(NORMALIZED_RATING_MATRIX, book_id2)
  df <- data.frame(x, y) |> drop_na()
  x <- as.vector(df$x)
  if (length(x) < 10) {
    return(NA)
  }
  y <- as.vector(df$y)
  return(cosine_similarity(x, y))
}

# find similar books
get_similar_books <- function(book_id, n) {
  books <- BOOK_IDS
  df <- data.frame(books)
  df$similarity <- map(df$books, \(df_book_id) books_cosine_similarity(df_book_id, book_id))
  df <- df[which(!is.na(df$similarity)),]
  df <- as.data.frame(lapply(df, unlist))
  ordered <- df[order(df$similarity, decreasing = TRUE),]
  return(ordered$books[2:(n + 1)])
}

list_similar_books <- function(target_book_id, n) {
  similar_book_ids <- strtoi(get_similar_books(target_book_id, n))
  titles <- c(DATA_BOOKS |> filter(book_id == strtoi(target_book_id)) |> select(title))
  for (similar_book_id in similar_book_ids) {
    titles <- append(titles, DATA_BOOKS |> filter(book_id == strtoi(similar_book_id)) |> select(title))
  }
  print(titles)
}


# compute for all
create_similarity_matrix <- function() {
  similarity_matrix <- matrix(nrow = length(BOOK_IDS), ncol = length(BOOK_IDS), dimnames = list(BOOK_IDS, BOOK_IDS))
  
  # TODO: create all pairs, map over the list and apply the function to each pair
  pairs <- combn(BOOK_IDS, 2, simplify = F)
  
  for (row in BOOK_IDS) {
    for (col in BOOK_IDS) {
      if (is.na(similarity_matrix[row, col])) {
        similarity <- books_cosine_similarity(row, col)
        similarity_matrix[row, col] <- similarity
        similarity_matrix[col, row] <- similarity
      }
    }
  }
  return(similarity_matrix)
}


main <- function() {
  similarity_matrix <- create_similarity_matrix()
  write.csv("similarity_matrix.csv")
}


#list_similar_books("186074", 15)


#main()
