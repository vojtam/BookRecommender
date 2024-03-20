box::use(
  shiny[moduleServer, fluidRow, NS, uiOutput, div, renderImage, renderUI],
  bslib[layout_column_wrap, value_box, card, card_header, card_body, layout_columns],
  bsicons[bs_icon],
  purrr[map],
  grDevices[replayPlot]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    layout_column_wrap(
      value_box(
        title = "Number of books",
        value = "15591",
        showcase = bs_icon("book-half"),
        theme = "purple"
      ),
      value_box(
        title = "Average book rating",
        value = "4.03",
        showcase = bs_icon("star-fill"),
        theme = "purple"
      ),
      value_box(
        title = "Number of genres",
        value = "8",
        showcase = bs_icon("tags-fill"),
        theme = "purple"
      )
    ),
    uiOutput(ns("wordcloud_plots"))
    
  )

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    images <- list.files("data/plots", full.names = TRUE)
    output$wordcloud_plots <- renderUI({
      div(
        class = "img-gallery",
        map(.x = images, .f = create_plot_card)
      )
    })
  })
}

create_plot_card <- function(plot_img_path) {

  name <- strsplit(plot_img_path, "/")[[1]][3] |> gsub(pattern = ".png*", replacement = "")
  card(
    class = "img-card",
    card_header(name),
    card_body(
      renderImage({
        list(src = plot_img_path, height = "400px")
      })
    )
  )
}
