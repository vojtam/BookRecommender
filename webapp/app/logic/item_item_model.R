box::use(
  dplyr[filter]
)

box::use(
  app/logic/utils[split_number, parse_recommendations]
)

#' @export
get_item_item_recommendations <- function(item_item_df, data_tab, ids, how_many) {
  rows <- item_item_df |> filter(
    book_id %in% ids
  )
  
  distribution <- split_number(how_many, length(ids))
  
  result <- list()
  for (i in 1:length(distribution)) {
    result <- append(result, rows[i,which(colnames(item_item_df) == "X1"):distribution[i]] |> as.vector())
  }
  
  result <- result |> unlist()
  return(parse_recommendations(result, data_tab, "ITEM-ITEM"))
}


