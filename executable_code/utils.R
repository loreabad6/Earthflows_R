## Rename files

from = list.files('terrain', pattern = '3x3', full.names = T, recursive = T)
library(stringr)
to = str_replace(from, '3x3', '7x7')
file.rename(from, to)
