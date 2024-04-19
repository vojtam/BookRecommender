box::use(
  recommenderlab[predict],
  methods[as],
  dplyr[select]
)


SVD_predict <- function(books_tab, selected_titles, ratings_tab, SVD_model, select_user_mat, how_many) {
  ids <- books_tab[title %in% selected_titles,]$book_id
  ids <- ids[which(ids %in% colnames(ratings_tab))]
  
  ratings_line <- ratings_tab[1,]
  ratings_line[] <- NA
  ratings_line[ids] <- 5
  
  select_user_mat <- as.matrix(ratings_line)
  select_user_mat <- as(select_user_mat, 'realRatingMatrix')
  
  predict_SVDF <- predict(SVD_model, 
                          select_user_mat,
                          type = "topNList",
                          n = how_many
  )
  
  predict_SVDF
  
  predict_SVDF_list <- as(predict_SVDF, 'list')
  predict_SVDF_list <- lapply(predict_SVDF_list, as.numeric)
  predict_SVDF_df <- as.data.frame(predict_SVDF_list)
  names(predict_SVDF_df) <- "book_id"
  
  recommendations_SVDF <- merge(predict_SVDF_df, books_tab, by = "book_id")
  recommendations_tab <- recommendations_SVDF |> select(
    title, average_rating, description, url, image_url, genres, author_name
  )
  recommendations_tab$model <- "SVD"
  return(recommendations_tab)
  
}
