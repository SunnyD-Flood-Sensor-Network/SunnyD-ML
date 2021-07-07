library(plumber)
library(tensorflow)
library(keras)
library(magick)
library(dplyr)

parser_jpeg <- function(...) {
  parser_read_file(function(tmpfile) {
    magick::image_read(tmpfile, ...)
  })
}


rescale <- function(dat, mn, mx){
  m = min(dat)
  M = max(dat)
  
  z <- ((mx-mn)*(dat-m))/((M-m)+mn)
  return(z)
}

standardize <- function(img) {
  s = sd(img)
  m = mean(img)
  img = (img - m) / s
  
  img =rescale(img, 0, 1)
  
  rm(s, m)
  
  return(img)
}

predict_flooding <- function(camera_ID){
  tmpfile <- tempfile(fileext = ".jpg")
  
  magick::image_read(paste0("https://photos-sunnydayflood.apps.cloudapps.unc.edu/public/",camera_ID,".jpg"))%>%
      magick::image_write(tmpfile)
  
  # Reshape to correct dimensions (1, 224, 224, 3)
  img_array <- keras::image_load(tmpfile,
                                 target_size = c(224,224)) %>% 
    keras::image_to_array() %>% 
    standardize() %>%
    keras::array_reshape(., c(1, dim(.)))
  
  # Model prediction. I think it outputs it as a list, so could convert with a simple "as.numeric()" or "c()"
  prediction <- model %>% 
    predict(x = img_array) %>% 
    t()
  
  colnames(prediction) <- "prob"
  
  prediction <- prediction %>% 
    as_tibble() %>% 
    transmute(prob = round(prob, 2),
              label = c("Bad Image","No Flooding", "Not Sure", "Flooding")) %>% 
    filter(prob == max(prob, na.rm=T)) %>% 
    slice(1)
  
  prediction
}

register_parser("jpeg", parser_jpeg, fixed = c("image/jpeg", "image/jpg"))

model <- keras::load_model_tf("ml/Rmodel_6_23_2021")

pr("plumber.R") %>% pr_run(host='0.0.0.0', port = 8001)
