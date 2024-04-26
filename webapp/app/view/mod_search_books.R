box::use(
  shiny[moduleServer, observeEvent, reactive, NS, div, uiOutput, renderUI],
  bslib[card, card_header, card_body],
  shinyWidgets[virtualSelectInput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("select_books_ui_output"))
}

#' @export
server <- function(id, book_titles, book_url_images, book_ids) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    
    output$select_books_ui_output <- renderUI({
      res <- div(
        class = "select_books_input_container",
        virtualSelectInput(
          ns("select_books_input"),
          "",
          choices = list(label=sprintf("<div class=\"booksearch\" >
                                        <img class=\"booksearch__img\" src=\"%s\"/>
                                        <span class=\"booksearch__title\">%s</span>
                                     </div>", book_url_images, book_titles),
                         value = book_ids) |> purrr::transpose(),
          multiple = TRUE,
          optionsCount = 6,
          search = TRUE,
          width = "70vw",
          showValueAsTags = TRUE,
          html = TRUE
        )
      )
      res
    }) 

    return(reactive({input$select_books_input}))
  })

}
