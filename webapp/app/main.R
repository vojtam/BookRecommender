box::use(
  utils[head],
  shiny[div, moduleServer, NS, selectizeInput, updateSelectizeInput, renderUI, HTML, tags, uiOutput],
  bslib[page_fillable, layout_columns, card, card_header, card_body],
  shinyWidgets[pickerInput, virtualSelectInput],
)


data <- data.table::fread("data/dataset_goodreads_filtered.csv")


#' @export
ui <- function(id) {
  ns <- NS(id)
  page_fillable(
    title = "Book Recommender",
    layout_columns(
      card(
        card_header(
          class = "bg-dark",
          "Select your favorite books"
        ),
        height = 200,
        card_body(
          virtualSelectInput(
            "test",
            "Select books",
            choices = list(label=sprintf("<div class=\"booksearch\" >
                                            <img class=\"booksearch__img\" src=\"%s\"/>
                                            <span class=\"booksearch__title\">%s</span>
                                         </div>", data$image_url, data$title),
                           value=data$title) |> purrr::transpose(),
            multiple = TRUE,
            noOfDisplayValues = 10,
            search = TRUE,
            width = "100vw",
            showValueAsTags = TRUE,
            html = TRUE
          )
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
   
  })
}


