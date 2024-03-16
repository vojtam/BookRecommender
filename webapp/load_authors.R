load_authors <- function(path) {
    con <- gzfile(file.path(path), "rt")
    lines <- readLines(con)
    close(con)
    tab <- jsonlite::stream_in(textConnection(lines), verbose = FALSE) |> as.data.table()
}

library(data.table)
library(dplyr)

tab <- load_authors("/home/vojtam/Downloads/goodreads_book_authors.json.gz")
authors <- tab[, .(author_id, name)]
setnames(authors, old = c("name"), new = c("author_name"))

data <- data.table::fread("data/dataset_goodreads_filtered_string_genre.csv")
authors_data <- data[authors, nomatch = 0, on = "author_id"]
authors_data[, ratings_count := as.numeric(ratings_count)]
authors_data_by_ratings_count <- authors_data[order(-ratings_count)]

fwrite(authors_data_by_ratings_count, "data/dataset_goodreads_filtered.csv")
