#* @apiTitle SunnyD ML photo flooding classification

#------------------------- Upload .jpegs or .jpgs -----------------------
#* @post /detect_flooding_latest
#* @param key API key
#* @param camera_ID ID of camera to get latest image and predict (optional)
#* Predict flooding from latest picture from a SunnyD Flood Cam
function(camera_ID) {

      camera_ID <- gsub("\\W", "", camera_ID)
      tmpfile <- tempfile(fileext = ".jpg")

      magick::image_read(paste0("https://photos-sunnydayflood.cloudapps.unc.edu/public/",camera_ID,".jpg"))%>%
        magick::image_scale(geometry = geometry_size_pixels(width=224,height=224,preserve_aspect = F)) %>% 
        magick::image_write(tmpfile)

      img_array <- keras::image_load(tmpfile) %>% 
        keras::image_to_array() %>% 
        keras::array_reshape(., c(1, dim(.)))

      prediction <- model %>% 
        predict(x = img_array)
      
      unlink(tmpfile)
      rm(img_array)
      
      return(c(prediction))
  }


# #* @post /detect_flooding
# #* @parser multi
# #* @parser jpeg
# #* @param key API key
# #* @param file:file A file (optional)
# #* Upload a jpeg to get a flooding prediction from MobileNet V2 model
# function(enc) {
#   if (key %in% api_keys) {
    
#     tmpfile <- tempfile(fileext = ".jpg")
    
#     file[[1]] %>%
#       magick::image_scale(geometry = geometry_size_pixels(width=224,height=224,preserve_aspect = F)) %>% 
#       magick::image_write(tmpfile)
    
#     img_array <- keras::image_load(tmpfile) %>% 
#       keras::image_to_array() %>% 
#       keras::array_reshape(., c(1, dim(.)))
    
#     prediction <- model %>% 
#       predict(x = img_array)
    
#     unlink(tmpfile)
#     rm(img_array)
#     rm(file)
    
#     return(c(prediction))
#   }
  
#   else(stop("Missing API Keys"))
# }
