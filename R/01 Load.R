library(tesseract)
library(dplyr)
library(stringr)
library(pdftools)
library(readr)
library(magick)
library(purrr)
library(openxlsx)


file <- pdftools::pdf_convert("./test-data/001_0145.pdf", page = 1,
                              filenames = "page1.png", dpi = 300)

# original size
image <- image_read("./test-data/page1.png")

text <- 
  image %>%
  image_crop(geometry_area(width = 1300, height = 950, y_off = 285, x_off = 380)) %>%  
  image_resize("3000x") %>%
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

#date <- 
  image %>% 
  image_crop(geometry_area(width = 120, height = 950, y_off = 285, x_off = 200)) %>% 
    #image_resize("3000x") %>%
    image_background("white", flatten = TRUE) %>% 
    #image_noise(noisetype = "Uniform") %>%          # Reduce noise in image using a noise peak elimination filter
    image_enhance() %>%                             # Enhance image (minimize noise)
    image_normalize() %>% 
    image_convert(type = 'Grayscale') %>%
    image_trim(fuzz = 40) %>%
    image_contrast(sharpen = 1) %>%
    #image_deskew(threshold = 40) %>% 
    image_write(format = 'png', density = '300x300') %>%
    tesseract::ocr(tesseract(options = list(preserve_interword_spaces = 1,
                                            textord_tabfind_find_tables = 1,
                                            textord_tablefind_recognize_tables = 1)))


text <- stringr::str_split(text, pattern = "\\s{5,}")

names(text) <- "Text"

#need to set name before 

t <- map_df(text, ~.x)

openxlsx::

readr::write_file(text, "./test-data/pg1_test1.txt")

wb <- createWorkbook()

addWorksheet(wb, "Page 1", gridLines = FALSE)

writeData(wb, sheet = 1, t, rowNames = FALSE)

saveWorkbook(wb, "test_ocr_conversion.xlsx", overwrite = TRUE)

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
