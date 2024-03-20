box::use(
  utils[head],
  shiny[div, moduleServer, sliderInput, tagList, actionButton, observeEvent, h1, h3, p, NS, selectizeInput,  HTML, tags],
  bslib[page_fillable, page_sidebar, nav_panel, page_navbar, layout_columns, card, card_header, card_body],
  waiter[useWaiter, autoWaiter, waiter_show, spin_fading_circles, waiter_hide, waiterShowOnLoad, waiter_on_busy],
  spacyr[spacy_install],
)

box::use(
  view/mod_search_books,
  view/mod_recommend_books,
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  page_sidebar(

    useWaiter(),
    waiter_on_busy(html = tagList(div(class = "main-waiter", h3("Give me a second to read all those books..."), spin_fading_circles()))),
    waiterShowOnLoad(html = tagList(div(class = "main-waiter", h3("Give me a second to read all those books..."), spin_fading_circles()))),
    title = "Book Recommender",
    sidebar = my_sidebar(ns),
    fillable = FALSE,
    tags$main(
      class = "main-container",
      tags$section(
        h1("Discover books you will love!", class = "align-text-center"),
        div(class = "text-main align-text-center", p(" Enter books you like and the site will analyse the contents of the books to provide book recommendations and suggestions for what to read next.")),
        mod_search_books$ui(ns("search_books")),
        mod_recommend_books$ui(ns("recommend_books"))
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- load_data("data/dataset_goodreads_filtered.csv")
    corp_dfm <- readRDS("data/ref_corp_dfm.rds")
    #spacy_install()
    selected_books_titles <- mod_search_books$server("search_books", data$title, data$image_url)
    
    mod_recommend_books$server("recommend_books", corp_dfm, selected_books_titles, data, input$how_many_recommends_slider)
    
  })
}


load_data <- function(path) {
  data <- data.table::fread(path)
  data[, genres := strsplit(genre, split = ",")]
  data$genre <- NULL
  return(data)
}


my_sidebar <- function(ns) {
  tagList(
    sliderInput(ns("how_many_recommends_slider"), "Number of books to recommend", 1, 100, 10, step = 1)
  )
}
