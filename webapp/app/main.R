box::use(
  utils[head, read.csv2],
  shiny[div, moduleServer, sliderInput, tagList, req, reactiveVal, actionButton, fileInput, observeEvent, h1, h3, p, NS, selectizeInput,  HTML, tags],
  bslib[page_fillable, page_sidebar, nav_panel, page_navbar, layout_columns, card, card_header, card_body, layout_column_wrap, value_box, input_dark_mode, nav_item],
  shinyWidgets[pickerInput],
  waiter[useWaiter, autoWaiter, waiter_show, spin_fading_circles, waiter_hide, waiterShowOnLoad, waiter_on_busy],
  spacyr[spacy_install],
)

box::use(
  view/mod_search_books,
  view/mod_recommend_books,
  view/mod_data_analysis
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  page_navbar(
    
    title = "Book Recommender",
    sidebar = my_sidebar(ns),
    fillable = FALSE, 
    nav_panel(
      useWaiter(),
      waiter_on_busy(html = tagList(div(class = "main-waiter", h3("Give me a second to read all those books..."), spin_fading_circles()))),
      #waiterShowOnLoad(html = tagList(div(class = "main-waiter", h3("Give me a second to read all those books..."), spin_fading_circles()))),
      title = "Recommendations",
      tags$main(
        class = "main-container",
        tags$section(
          h1("Discover books you will love!", class = "align-text-center"),
          div(class = "text-main align-text-center", p(" Enter books you like and the site will analyse the contents of the books to provide book recommendations and suggestions for what to read next.")),
          mod_search_books$ui(ns("search_books")),
          mod_recommend_books$ui(ns("recommend_books"))
        )
      )
    ),
    nav_panel(
      "Data analysis",
      mod_data_analysis$ui(ns("data_analysis"))
    ),
    # nav_item(
    #   fileInput(ns("upload_goodreads"), NULL, buttonLabel = "Upload goodreads", multiple = FALSE)
    # ),
    nav_item(
      input_dark_mode(id = "dark_mode", mode = "light")
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    gargoyle::init("start_recommend_event")
    
    data <- load_data("data/dataset_goodreads_filtered.csv")
    user_ratings_tab <- readRDS("ratings_filtered.rds")
    corp_dfm <- readRDS("data/ref_corp_tfidf.rds")
    SVD_model <- readRDS("../svdf.rds")
    #spacy_install()
    selected_books_titles <- mod_search_books$server("search_books", data$title, data$image_url)
    mod_data_analysis$server("data_analysis")
    
    observeEvent(input$how_many_recommends_slider, {
      mod_recommend_books$server("recommend_books",
        user_ratings_tab,
        SVD_model,
        corp_dfm,
        selected_books_titles,
        data,
        input$how_many_recommends_slider,
        input$simil_metrics,
        input$method
      )
      gargoyle::trigger("start_recommend_event")
      
    })
    
    # observeEvent(input$simil_metrics, {
    #   mod_recommend_books$server("recommend_books", corp_dfm, selected_books_titles, data, input$how_many_recommends_slider, input$simil_metrics)
    #   gargoyle::trigger("start_recommend_event")
    #   
    # })
    

    
    # observeEvent(input$upload_goodreads, {
    #   req(input$upload_goodreads)
    #   user_data <- read.csv2(input$upload_goodreads$datapath, sep = ",")
    #   user_data <- dplyr::filter(user_data,
    #                              Book.Id %in% data$book_id,
    #                              max(user_data$My.Rating) == user_data$My.Rating)
    #   books <- reactiveVal(data[book_id %in% user_data$Book.Id]$title)
    #   mod_recommend_books$server("recommend_books", corp_dfm, books, data, input$how_many_recommends_slider, input$simil_metrics)
    #   gargoyle::trigger("start_recommend_event")
    # })
    
  })
}


load_data <- function(path) {
  data <- data.table::fread(path)
  data[, genres := strsplit(genre, split = ",")]
  data[, average_rating := as.numeric(average_rating)]
  data$genre <- NULL
  data$similar_books <- NULL
  return(data)
}


my_sidebar <- function(ns) {
  tagList(
    sliderInput(ns("how_many_recommends_slider"), "Number of books to recommend", 1, 100, 10, step = 1),
    pickerInput(
      inputId = ns("method"),
      label = "recommendation method",
      selected = "ALL", 
      choices = c("SVD", "TFIDF", "item-item", "ALL")
    )
    # pickerInput(
    #   inputId = ns("simil_metrics"),
    #   label = "Content similarity metric",
    #   selected = "cosine", 
    #   choices = c("correlation", "cosine", "jaccard", "ejaccard", "dice", "edice", "hamann",
    #               "simple matching")
    # )
  )
}
