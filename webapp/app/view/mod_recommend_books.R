box::use(
  shiny[moduleServer, NS, div, actionButton, reactiveVal, observeEvent, textOutput, renderText]
)

box::use(
  app/logic/recommend_system[...]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    class = "flex-center",
    actionButton(ns("get_recommend_btn"), "Get Recommendations"),
    textOutput(ns("recommends"))
  )
}

#' @export
server <- function(id, corp_dfm, query_book_titles, data_tab) {
  moduleServer(id, function(input, output, session) {
    book_recommends_titles <- reactiveVal()
  
    observeEvent(input$get_recommend_btn, {
      book_recommends_titles(get_recommendations(corp_dfm, query_book_titles()))
    })
    
    
    output$recommends <- renderText({
      print(book_recommends_titles())
    })
  })
}
