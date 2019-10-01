library(tesseract)
library(dplyr)
library(stringr)
library(pdftools)
library(readr)
library(magick)

file <- pdftools::pdf_convert("./test-data/001_0145.pdf", page = 1,
                              filenames = "page1.png", dpi = 300)


#reprex size

image <- image_read("./test-data/page_1.png")

text <- image %>%
  image_crop(geometry_area(width = 1220, height = 900,
                           y_off = 260, x_off = 355)) %>% 
  image_resize("2000x") %>%
  image_convert(type = 'Grayscale') %>%
  image_trim(fuzz = 40) %>%
  image_write(format = 'png', density = '300x300') %>%
  tesseract::ocr() 

stringr::str_split(text, pattern = "\n")


# original size
image <- image_read("./test-data/page1.png")

text <- 
  image %>%
  image_crop(geometry_area(width = 1300, height = 950, y_off = 285, x_off = 380)) %>%  
  #image_resize("2000x") %>%
  image_convert(type = 'Grayscale') %>%
  image_trim(fuzz = 40) %>%
  image_write(format = 'png', density = '300x300') %>%
  tesseract::ocr(tesseract(options = list(preserve_interword_spaces = 1))) 


image_res

str_split(text, pattern = "\n\n")

readr::write_file(text, "./test-data/pg1_test1.txt")

