box::use(
  shiny[moduleServer, NS, tags, req, div, actionButton, reactiveVal, tagList, observeEvent, uiOutput, renderUI],
  purrr[pmap],

)

box::use(
  app/logic/recommend_system[parse_recommendations, get_recommendations],
  app/view/react[BookCard],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    class = "flex-center",
    actionButton(ns("get_recommend_btn"), "Get Recommendations"),
    uiOutput(ns("bookCardsOutput"))
    

  )
}

#' @export
server <- function(id, corp_dfm, query_book_titles, data_tab) {
  moduleServer(id, function(input, output, session) {
    book_recommends_tab <- reactiveVal()
  
    observeEvent(input$get_recommend_btn, {
      titles <- get_recommendations(corp_dfm, query_book_titles())
      recommends_tab <- parse_recommendations(titles, data_tab)
      book_recommends_tab(recommends_tab)
    })
    
    
    output$bookCardsOutput <- renderUI({
      req(book_recommends_tab())
      pmap(.l = book_recommends_tab(), .f = create_card)
    })
  })
}

create_card <- function(title, average_rating, description, author_id, url, image_url, genre) {
  BookCard(title = title,
           author = author_id,
           avg_rating = average_rating,
           genres = genre,
           description = description,
           imageUrl = image_url,
           url = url
  )
}
