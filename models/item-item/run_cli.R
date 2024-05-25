
library(dplyr)
library(tidyr)
library(purrr)
library(furrr)
library(progressr)
library(data.table)
library(tictoc)
library(carrier)

plan(multisession, workers = 16)
opts <- furrr_options(globals = TRUE, seed = 42, packages = "data.table", scheduling = 2L)
handlers( handler_txtprogressbar(char = cli::col_red(cli::symbol$heart)))
handlers("debug")

print("Loading stuff")
pairs <- readRDS("pairs.rds")
print("finished loading pairs")
# NORMALIZED_RATING_MATRIX <- readRDS("norm_rating_matrix.rds")
#df <- readRDS("norm_rating_matrix.rds") |> as.data.frame()
sparse_rat_mat <- readRDS("sparse_rating_mat.rds")
sparse_rat_mat_summ <- summary(sparse_rat_mat)
sparse_rat_mat_summary <- data.table(i = sparse_rat_mat_summ$i,
                                     j = sparse_rat_mat_summ$j,
                                     x = sparse_rat_mat_summ$x)
book_ids <- readRDS("book_ids_columnwise.rds")

# adjusted cosine similarity
cosine_similarity <- function(x, y) {
  similarity <- x %*% y / sqrt(x %*% x * y %*% y)
  return(similarity[1,1])
}


crated_books_cosine_similarity <- crate(
  mat_summary = sparse_rat_mat_summary,
  cos_sim = cosine_similarity,
  ids = book_ids,
  function(pair) {
    book_id1 <- pair[[1]]
    book_id2 <- pair[[2]]
    book_id1_col_i <- which(ids == book_id1)
    book_id2_col_i <- which(ids == book_id2)
    x_summ <- mat_summary[which(mat_summary$j == book_id1_col_i),]
    y_summ <- mat_summary[which(mat_summary$j == book_id2_col_i),]
    
    both_dt <- x_summ[y_summ, on = "i", nomatch = NULL]
    data.table::setnames(both_dt, old = c("x", "i.x"), new = c("book_1_rating", "book_2_rating"))
    x <- both_dt$book_1_rating
    y <- both_dt$book_2_rating
    
    if (nrow(both_dt) < 1) {
      return(NA)
    }
    return(list(book_id1 = book_id1, book_id2 = book_id2, sim = (cos_sim(x, y) * nrow(both_dt)) ))
  }
)


steps <- c(seq(1, length(pairs), 16000), length(pairs))
steps <- steps[2: length(steps)] |> as.list()

run_batch <- function(step, batch, func, p) {
  print(paste("batch", step, "starting..."))
  p()
  tic()
  result <- future_map(batch, .f = func, .options = opts)
  toc()
  print(paste0("batch ", step, " finished, saving..."))
  saveRDS(result, paste0("weighted_batches/result_", step, ".rds"))
}


with_progress({
  p <- progressr::progressor(steps = length(steps))
  map(steps, \(step) run_batch(step, pairs[(step - 16000):step], crated_books_cosine_similarity, p))
})


print("FINISHED COMPUTATION")
print("saving to RDS")

print("FINISHED SAVING")
