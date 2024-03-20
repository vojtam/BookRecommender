library(jsonlite)
library(data.table)
library(purrr)
library(furrr)
library(tidyverse)

plan(multisession, workers = 8)

files_dir <- file.path("data/goodreads")


con <- gzfile(file.path(files_dir, "goodreads_books_poetry.json.gz"), "rt")
lines <- readLines(con)
close(con)
books_tab <- jsonlite::stream_in(textConnection(lines), verbose = FALSE) |> as.data.table()

rm(lines)


books_tab[, ratings_count := as.numeric(ratings_count)]
books_tab |> setorder(-ratings_count)

books_tab_filtered <- books_tab[, .(language_code, average_rating, book_id, similar_books, description, authors, isbn13, url, image_url, ratings_count, title)]
top3000_tab <- books_tab_filtered[1:3000]
top_tab_eng <- top3000_tab[(language_code %like% "^en")] 


load_genre_books <- function(path, genre) {
    print(path)
    con <- gzfile(file.path(path), "rt")
    lines <- readLines(con)
    close(con)
    books_tab <- jsonlite::stream_in(textConnection(lines), verbose = FALSE) |> as.data.table()
    print("loaded")
    
    books_tab[, ratings_count := as.numeric(ratings_count)]
    books_tab |> setorder(-ratings_count)
    books_tab_filtered <- books_tab[, .(language_code, average_rating, book_id, similar_books, description, authors, isbn13, url, image_url, ratings_count, title)]
    books_tab_filtered <- books_tab_filtered[!is.null(description) & (!is.null(image_url))]
    top3000_tab <- books_tab_filtered[1:3000]
    top_tab_eng <- top3000_tab[(language_code %like% "^en")] 
    top_tab_eng[, genre := genre]
    
    return(top_tab_eng)
}

get_genre_from_filename <- function(path) {
    genre <- strsplit(path, "_")[[1]] |> tail(n = 1) |> gsub(pattern = ".json.gz", replacement = "")
    return(genre)    
}


load_reviews <- function(path) {
    con <- gzfile(file.path(path), "rt")
    lines <- readLines(con)
    close(con)
    tab <- jsonlite::stream_in(textConnection(lines), verbose = FALSE) |> as.data.table()
}

datasets_paths <- list.files(files_dir, full.names = T)

tables <- future_map(.x = datasets_paths,
              .f = \(path) load_genre_books(path, get_genre_from_filename(path)))

dataset_tab <- rbindlist(tables)
dataset_tab$genre <- mapvalues(dataset_tab$genre, from = c("graphic", "paranormal", 'biography', "adult"), to = c("graphic_comics", "fantasy", "history_biography", "YA"))
dataset_tab[, genre := paste(genre, collapse=","), by = c("book_id")]
dataset_tab[, similar_books := paste(similar_books, ",")]

unnested_authors <- dataset_tab |> unnest(cols = "authors") |> as.data.table()
unnested_authors <- unnested_authors[, head(.SD, 1), by = c("book_id")]
unnested_authors$role <- NULL
unnested_authors$language_code <- NULL

final_tab <- unnested_authors[, head(.SD, 1), by = c("title")]
fwrite(final_tab, "dataset_goodreads_filtered.csv", sep = ",")

##########



reviews_raw <- load_reviews("../data/goodreads_reviews_spoiler_raw.json.gz")
reviews_filtered <- reviews_raw[book_id %in% data$book_id]

reviews_filtered[, review_len := nchar(review_text)]

reviews_filtered[reviews_filtered[, .I[which.max(review_text)], by = book_id]$V1]


reviews_longest <- reviews_filtered[reviews_filtered[, .I[review_len == max(review_len)], by = book_id]$V1]
reviews_longest <- reviews_longest[, .(book_id, review_text)]


data$similar_books <- NULL
res <- merge(data, reviews_longest, all.x = TRUE, by = "book_id")
setorder(res, -ratings_count)
