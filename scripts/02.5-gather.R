# load pkgs
pacman::p_load( "tidyverse", "purrr", "vroom" )

all_rds <- list.files( path = ".", pattern = ".*\\.rds" )

# 1. Read all RDS files into a single list of dataframes
df_list <- map( all_rds, readRDS )

# 2. Bind them all together instantly
final_combined_df <- bind_rows( df_list )

# save the plot
vroom_write(
  x = final_combined_df, 
  file = "r2mtx.tsv.gz", 
  delim = "\t"
)