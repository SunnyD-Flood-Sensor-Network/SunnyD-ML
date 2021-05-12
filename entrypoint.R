library(plumber)
library(tensorflow)
library(keras)
library(magick)

parser_jpeg <- function(...) {
  parser_read_file(function(tmpfile) {
    magick::image_read(tmpfile, ...)
  })
}

register_parser("jpeg", parser_jpeg, fixed = c("image/jpeg", "image/jpg"))

model <- keras::load_model_tf("ml/MN2_model_TB")

pr("plumber.R") %>% pr_run(host='0.0.0.0', port = 8001)
