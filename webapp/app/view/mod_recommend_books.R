box::use(
  shiny[
    moduleServer,
    textOutput,
    renderText,
    NS,
    h3,
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
  data.table[data.table, fwrite],
  waiter[Waiter, spin_fading_circles]

)

box::use(
  app/logic/tfidf_model[get_recommendations],
  app/logic/SVD_model[SVD_predict],
  app/logic/item_item_model[get_item_item_recommendations],
  app/logic/utils[split_number, get_random_titles],
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
server <- function(id, ratings_tab, SVD_model, corp_dfm, item_item_df, query_book_ids, data_tab, how_many, simil_metrics, method = "SVD") {
  moduleServer(id, function(input, output, session) {
    book_recommends_tab <- reactiveVal()
    
    observeEvent(input$get_recommend_btn, {
      gargoyle::trigger("start_recommend_event")
    })
    
    observeEvent(gargoyle::watch("start_recommend_event"), {
      req(query_book_ids())
      waiter <- Waiter$new(html = tagList(div(class = "main-waiter", h3("Give me a second to read all those books..."), spin_fading_circles())))
      waiter$show()
      if (method == "SVD") {
        recommendations <- SVD_predict(data_tab, query_book_ids(), ratings_tab, SVD_model, select_user_mat, how_many = how_many)
        book_recommends_tab(recommendations)
      }
      else if (method == "TFIDF") {
        recommendations <- get_recommendations(corp_dfm, data_tab, query_book_ids(), input$genre_selector, "cosine", how_many)
        book_recommends_tab(recommendations)
      }
      else if (method == "item-item") {
        recommendations <- get_item_item_recommendations(item_item_df, data_tab, query_book_ids(), how_many)
        book_recommends_tab(recommendations)
      }
      else {
        parts <- split_number(how_many, 3)
        
        SVD_recommends <- SVD_predict(data_tab, query_book_ids(), ratings_tab, SVD_model, select_user_mat, how_many = parts[1])
        tfidf_recommends <- get_recommendations(corp_dfm, data_tab, query_book_ids(), input$genre_selector, "cosine", parts[2])
        item_item_recommendations <- get_item_item_recommendations(item_item_df, data_tab, query_book_ids(), how_many)
        #random <- get_random_titles(data_tab, parts[3])
        
        all_recs <- rbind(SVD_recommends, tfidf_recommends, item_item_recommendations)
        all_recs <- all_recs[sample(1:nrow(all_recs)), ] 
        book_recommends_tab(all_recs)
        
      }
      waiter$hide()
    })

    observeEvent(input$myval, {
      req(input$myval)
      record <- input$myval
      record_row <- data.table(
        query_book_id = query_book_ids(),
        recommended_title = record$title,
        model = record$model,
        datetime = date()
      )
      fwrite(record_row, "system_recommendations_log.csv", append = TRUE)
      
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
