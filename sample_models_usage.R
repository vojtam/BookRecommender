library(dplyr)
library(ggplot2)
library(tibble)
library(tidyr)
library(stringr)
library(reshape2)
library(Matrix)
library(recommenderlab)
library(data.table)
library(DT)

#Load data
books <- read.csv(file = "data/dataset_goodreads_filtered.csv", sep = ",", dec = ",")
ratings <- read.csv(file = "data/reviews_tab_filtered.csv", sep = ",", dec = ",")
#Create mapping from string user_id to numeric user_id
user_id_mapping <- ratings %>% distinct(user_id) %>% mutate(user_id_number = row_number()) %>%
  select(user_id, user_id_number)
ratings <- ratings %>% left_join(user_id_mapping, by = "user_id")

books_ratings <- left_join(ratings, books, by = "book_id") |> select(book_id, user_id, user_id_number, rating)
head(books_ratings)
str(books_ratings)

#Retain users and books with 10 and more ratings
book_counts <- table(books_ratings$book_id)
user_counts <- table(books_ratings$user_id)

books_to_keep <- names(book_counts[book_counts >= 10])
users_to_keep <- names(user_counts[user_counts >= 10])

books_ratings <- books_ratings[books_ratings$user_id %in% users_to_keep, ]
books_ratings <- books_ratings[books_ratings$book_id %in% books_to_keep, ]
books_ratings <- books_ratings[complete.cases(books_ratings$user_id, books_ratings$book_id), ]

#This is only for xrusnack :D
#n <- 1000
#first_n_users <- books_ratings$user_id %>% unique %>% head(n)
#books_ratings <- books_ratings[books_ratings$user_id %in% first_n_users, ]

#User-Book Format
books_ratings <- books_ratings |> reshape2::dcast(user_id_number ~ book_id, value.var = "rating")
rownames(books_ratings) <- books_ratings$user_id_number
books_ratings <- books_ratings[, -1]
#_________________________________________________________________________________________________________

#EXAMPLE
select_user_id_char <- "8842281e1d1347389f2ab93d60773d4d"

# get numerical value of the select_user_id_char using the mapping
select_user_id <- ratings |> filter(user_id == select_user_id_char) %>% select(user_id_number)
select_user_id <- select_user_id[1,1]

#select the right row in the dataframe
select_user <- books_ratings[select_user_id, ]

# Convert to Realmatrix for the model
select_user_mat <- as.matrix(select_user)
select_user_mat <- as(select_user_mat, 'realRatingMatrix')

#Load models
book_reco_SVDF <- readRDS("svdf.rds")
book_reco_UBCF <- readRDS("ubcf.rds")
book_reco_UBCF_centered <- readRDS("ubcf_normalized.rds")

#Make predictions
predict_SVDF <- predict(book_reco_SVDF, 
                        select_user_mat,
                        type = "topNList",
                        n = 10
)
predict_SVDF

predict_SVDF_list <- as(predict_SVDF, 'list')
predict_SVDF_list <- lapply(predict_SVDF_list, as.numeric)
predict_SVDF_df <- as.data.frame(predict_SVDF_list)
names(predict_SVDF_df) <- "book_id"

recommendations_SVDF <- merge(predict_SVDF_df, books, by = "book_id")
print(recommendations_SVDF$title)

#display it nicely as images
recommendations_SVDF %>%
  mutate(image = paste0('<img src="', image_url, '" style="max-width:100px; max-height:100px;"></img>')) %>%
  select(image, title) %>%
  datatable(class = "nowrap hover row-border", escape = FALSE, options = list(dom = 't', scrollX = TRUE, autoWidth = TRUE))


predict_ubcf <- predict(book_reco_UBCF, 
                        select_user_mat,
                        type = "topNList",
                        n = 10
)
predict_ubcf

predict_ubcf_list <- as(predict_ubcf, 'list')
predict_ubcf_list <- lapply(predict_ubcf_list, as.numeric)
predict_ubcf_df <- as.data.frame(predict_ubcf_list)
names(predict_ubcf_df) <- "book_id"

recommendations_ubcf <- merge(predict_ubcf_df, books, by = "book_id")
print(recommendations_ubcf$title)

recommendations_ubcf %>%
  mutate(image = paste0('<img src="', image_url, '" style="max-width:100px; max-height:100px;"></img>')) %>%
  select(image, title) %>%
  datatable(class = "nowrap hover row-border", escape = FALSE, options = list(dom = 't', scrollX = TRUE, autoWidth = TRUE))

predict_ubcf_centered <- predict(book_reco_UBCF_centered, 
                                 select_user_mat,
                                 type = "topNList",
                                 n = 10
)
predict_ubcf_centered

predict_ubcf_centered_list <- as(predict_ubcf_centered, 'list')
predict_ubcf_centered_list <- lapply(predict_ubcf_centered_list, as.numeric)
predict_ubcf_centered_df <- as.data.frame(predict_ubcf_centered_list)
names(predict_ubcf_centered_df) <- "book_id"

recommendations_ubcf_centered <- merge(predict_ubcf_centered_df, books, by = "book_id")
print(recommendations_ubcf_centered$title)

recommendations_ubcf_centered |>
  mutate(image = paste0('<img src="', image_url, '" style="max-width:100px; max-height:100px;"></img>')) %>%
  dplyr::select(image, title) |>
  datatable(class = "nowrap hover row-border", escape = FALSE, options = list(dom = 't',scrollX = TRUE, autoWidth = TRUE))

