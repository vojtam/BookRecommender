box::use(
  utils[head],
  shiny[div, moduleServer, actionButton, observeEvent, h1, p, NS, selectizeInput,  HTML, tags],
  bslib[page_fillable, nav_panel, page_navbar, page_sidebar, layout_columns, card, card_header, card_body],

)

box::use(
  view/mod_search_books
)




#' @export
ui <- function(id) {
  ns <- NS(id)
  page_fillable(
    title = "Book Recommender",
    tags$main(
      class = "main-container",
      h1("Discover books you will adore!", class = "align-text-center"),
      div(class = "text-main align-text-center", p(" Enter books you like and the site will analyse the contents of the books to provide book recommendations and suggestions for what to read next.")),
      mod_search_books$ui(ns("search_books")),
      actionButton("get_recommend_btn", "Get Recommendations")
    )

  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- data.table::fread("data/dataset_goodreads_filtered.csv")
    
    selected_books_titles <- mod_search_books$server("search_books", data$title, data$image_url)
    
    
  })
}


