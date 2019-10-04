library(tesseract)
library(dplyr)
library(stringr)
library(pdftools)
library(readr)
library(magick)
library(purrr)
library(openxlsx)

#for one page-----------------------------------------

file <- pdftools::pdf_convert("./test-data/001_0145.pdf", page = 1,
                              filenames = "./test-data/page1.png", dpi = 250)

# original size
image <- image_read("./test-data/page1.png")

magick::image_attributes(image)

image %>%
  image_crop(geometry_area(width = 2200, height = 1600, y_off = 500, x_off = 650)) 

text <- 
  image %>%
  image_crop(geometry_area(width = 2200, height = 1600, y_off = 500, x_off = 650)) %>%  
  image_resize("2000x") %>%
  image_background("white", flatten = TRUE) %>% 
  image_noise(noisetype = "Uniform") %>%          # Reduce noise in image using a noise peak elimination filter
  image_enhance() %>%                             # Enhance image (minimize noise)
  image_normalize() %>% 
  image_convert(type = 'Grayscale') %>%
  image_trim(fuzz = 40) %>%
  image_contrast(sharpen = 1) %>%
  #image_deskew(threshold = 40) %>% 
  image_write(format = 'png', density = '300x300') %>%
  tesseract::ocr(tesseract(options = list(preserve_interword_spaces = 1)))

(text <- stringr::str_split(text, pattern = "\\s{5,}"))

#need to set name before 
names(text) <- "Text"

t <- map_df(text, ~.x)

readr::write_file(text, "./test-data/pg1_test1.txt")

print_xlsx <- function(df){
  
  wb <- createWorkbook()
  addWorksheet(wb, "Page 1", gridLines = FALSE)
  writeData(wb, sheet = 1, t, rowNames = FALSE)
  saveWorkbook(wb, "test_ocr_conversion.xlsx", overwrite = TRUE)
  
  
}


#for single doc with multiple pages---------------------------------------------------
file_name <- tools::list_files_with_exts(dir = "./test-data", exts = "pdf")
page_count <- pdf_info(file_name)$pages  

multi_files <- list(pdftools::pdf_convert(file_name, page = 1:page_count,
                                          filenames = paste0("./test-data/", "page", 1:page_count, ".png"),
                                          dpi = 250))

#once done the first time can just read in the files

multi_files <- list(tools::list_files_with_exts(dir = "./test-data", exts = "png"))


#for multiple pdfs:
#  map(filelist, FUN = function(file) {
#    pdf_convert(files, format = "png")
#    })

multi_images <- map(multi_files, image_read)

multi_images1 <- image_join(multi_images)

multi_text_clean <- function(images){
  
  Map(function(x) {
    x %>% 
      image_crop(geometry_area(width = 2200, height = 1600, y_off = 500, x_off = 650)) %>%  
      image_resize("2000x") %>%
      image_background("white", flatten = TRUE) %>% 
      image_noise(noisetype = "Uniform") %>%          # Reduce noise in image using a noise peak elimination filter
      image_enhance() %>%                             # Enhance image (minimize noise)
      image_normalize() %>% 
      image_convert(type = 'Grayscale') %>%
      image_trim(fuzz = 40) %>%
      image_contrast(sharpen = 1) %>%
      #image_deskew(threshold = 40) %>% 
      image_write(format = 'png', density = '300x300') %>%
      tesseract::ocr(tesseract(options = list(preserve_interword_spaces = 1)))
  }, images)

}



text_list <-  multi_text_clean(multi_images1)


text_list <-  multi_text_clean(multi_images)


(text_multi <- stringr::str_split(text_list, pattern = "\\s{5,}"))

#need to set name before 
names(text_multi) <- "Text"

t <- map_df(text_multi, ~.x)

View(t)

readr::write_file(text, "./test-data/pg1_test1.txt")

print_xlsx <- function(df){
  
  wb <- createWorkbook()
  addWorksheet(wb, "Page 1", gridLines = FALSE)
  writeData(wb, sheet = 1, t, rowNames = FALSE)
  saveWorkbook(wb, "test_ocr_conversion.xlsx", overwrite = TRUE)
  
  
}