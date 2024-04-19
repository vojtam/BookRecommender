box::use(
  shiny[
    moduleServer,
    textOutput,
    renderText,
    NS,
    tags,
    req,
    div,
    actionButton,
    reactiveVal,
    tagList,
    observeEvent,
    uiOutput,
    renderUI
  ],
  dplyr[select],
  methods[as],
  shinyWidgets[checkboxGroupButtons],
  purrr[pmap],

)

box::use(
  app/logic/recommend_system[parse_recommendations, get_recommendations],
  app/logic/kaja_model[SVD_predict],
  app/view/react[BookCard],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    class = "flex-center",
    checkboxGroupButtons(
      inputId = ns("genre_selector"),
      label = "Choose genres to be included:", 
      choices = c(`<div class=''>fantasy</div>` = "fantasy",
                  `<span class=''>children</span>` = "children",
                  `<span class=''>history & biography</span>` = "history_biography",
                  `<span class=''>comics</span>` = "comics",
                  `<span class=''>romance</span>` = "romance",
                  `<span class=''>poetry</span>` = "poetry",
                  `<span class=''>YA</span>` = "YA",
                  `<span class=''>crime</span>` = "crime"
                  ),
      justified = TRUE,
    ),
    textOutput(ns("mytext1")),
    
    
    actionButton(ns("get_recommend_btn"), "Get Recommendations"),
    uiOutput(ns("bookCardsOutput"))
    

  )
}

#' @export
server <- function(id, ratings_tab, SVD_model, corp_dfm, query_book_titles, data_tab, how_many, simil_metrics, method = "SVD") {
  moduleServer(id, function(input, output, session) {
    book_recommends_tab <- reactiveVal()
    
    observeEvent(input$get_recommend_btn, {
      gargoyle::trigger("start_recommend_event")
    })
    
    observeEvent(gargoyle::watch("start_recommend_event"), {
      req(query_book_titles())
      if (method == "SVD") {
        recommendations <- SVD_predict(data_tab, query_book_titles(), ratings_tab, SVD_model, select_user_mat, how_many = how_many)
        book_recommends_tab(recommendations)
      }
      else if (method == "TFIDF") {
        recommendations <- get_recommendations(corp_dfm, data_tab, query_book_titles(), input$genre_selector, "cosine", how_many)
        book_recommends_tab(recommendations)
      }
      else {
        parts <- split_number(how_many, 3)
        
        SVD_recommends <- SVD_predict(data_tab, query_book_titles(), ratings_tab, SVD_model, select_user_mat, how_many = parts[1])
        tfidf_recommends <- get_recommendations(corp_dfm, data_tab, query_book_titles(), input$genre_selector, "cosine", parts[2])
        random <- get_random_titles(data_tab, parts[3])
        
        all_recs <- rbind(SVD_recommends, tfidf_recommends, random)
        all_recs <- all_recs[sample(1:nrow(all_recs)), ] 
        book_recommends_tab(all_recs)
        
      }
    })

    output$mytext1 <- renderText({
      return(input$myval)
    })
    
    output$bookCardsOutput <- renderUI({
      req(book_recommends_tab())
      pmap(.l = book_recommends_tab(), .f = create_card)
    })
  })
}

create_card <- function(title, average_rating, description, url, image_url, genres, author_name, model) {
  BookCard(title = title,
           avg_rating = average_rating,
           genres = as.list(genres),
           description = description,
           author_name = author_name,
           imageUrl = image_url,
           url = url,
           model = model

  )
}

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


get_random_titles <- function(books_tab, how_many) {
  rows <- sample(1:nrow(books_tab), how_many)
  selected <- books_tab[rows,]
  selected <- selected |>  dplyr::select(
    title, average_rating, description, url, image_url, genres, author_name
  )
  selected$model <- "random"
  return(selected)
}
