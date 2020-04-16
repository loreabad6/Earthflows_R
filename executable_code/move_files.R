library(fs)

sa1files = list.files('terrain/derivatives/', pattern = 'sa1', full.names = T)
sa2files = list.files('terrain/derivatives/', pattern = 'sa2', full.names = T)

file_move(sa1files, 'terrain/derivatives/study_area_1')
file_move(sa2files, 'terrain/derivatives/study_area_2')
