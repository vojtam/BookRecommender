box::use(
  dplyr[select, filter]
)

#' @export
split_number <- function(number, n){
  # Calculate the base value for each part (integer division)
  base_part = number %/% n
  
  # Initialize the result list
  result = rep(base_part, n)
  
  # Distribute the remainder among the first n-1 elements
  remainder = number %% n
  i <- 1
  for(one in rep(1, remainder)) {
    result[[i]] <- result[[i]] + one
    i <- i + 1
  }
  
  return(result)
}


#' @export
get_random_titles <- function(books_tab, how_many) {
  rows <- sample(1:nrow(books_tab), how_many)
  selected <- books_tab[rows,]
  selected <- selected |>  select(
    title, average_rating, description, url, image_url, genres, author_name
  )
  selected$model <- "random"
  return(selected)
}

#' @export
parse_recommendations <- function(rec_book_ids, data_tab, model) {
  subset_books <- data_tab |> 
    filter(
      book_id %in% rec_book_ids 
    ) |>
    select(
      title, average_rating, description, url, image_url, genres, author_name
    )
  subset_books$model <- model
  return(subset_books)
}