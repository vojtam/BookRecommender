load_authors <- function(path) {
    con <- gzfile(file.path(path), "rt")
    lines <- readLines(con)
    close(con)
    tab <- jsonlite::stream_in(textConnection(lines), verbose = FALSE) |> as.data.table()
}

library(data.table)
library(dplyr)
library(ggplot2)

tab <- load_authors("/home/vojtam/Downloads/goodreads_book_authors.json.gz")
authors <- tab[, .(author_id, name)]
setnames(authors, old = c("name"), new = c("author_name"))

data <- data.table::fread("data/dataset_goodreads_filtered_string_genre.csv")
authors_data <- data[authors, nomatch = 0, on = "author_id"]
authors_data[, ratings_count := as.numeric(ratings_count)]
authors_data_by_ratings_count <- authors_data[order(-ratings_count)]




data <- fread("data/dataset_goodreads_filtered.csv")
sim_books <- purrr::map(.x = data$similar_books, .f = \(book) strsplit(gsub("[c,(,)]", "",gsub("\"", "", book)), " "))
sim_books_ids <- purrr::map(.x = sim_books, .f = \(ids_list) as.numeric(ids_list[[1]]))

data.table(book_id = data$book_id, sim_book_id = sim_books_ids)

long_ids <- purrr::map2(.x = data$book_id, .y = sim_books_ids, .f = \(book_id, sim_books) rep(book_id, length(sim_books))) |>
  unlist() |>
  as.numeric()

table <- data.table(book_id = long_ids, sim_book_id = unlist(sim_books_ids))
table_filtered <- table[sim_book_id %in% data$book_id]
counts <-  table_filtered[, .N, by = book_id]

ggplot(data = counts, aes(x = N)) +
  geom_histogram(bins = max(unique(counts$N)))


fwrite(table_filtered, "../data/similar_book_tab.csv")
