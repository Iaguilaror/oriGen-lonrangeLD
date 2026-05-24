# load packages
pacman::p_load( "vroom", "dplyr", "tidyr", "archive", "tibble", "stringr" )

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "idchunk_000000.temp_raw.vcor" ## ld file

## Passing args to named objects
chunkfile <- args[1]

all_ld.df <- vroom(chunkfile) %>% 
  dplyr::rename(
    SNP_ID  = 1,
    B  = 2,
    r2 = 3
  ) %>% 
  as_tibble() %>% 
  mutate( r2 = round( r2, digits = 2 ) )

str( all_ld.df )

# Crear matriz
ld_matrix <- all_ld.df %>%
  # Asegurar que todas las combinaciones existan si es necesario, 
  # o rellenar las ausentes con 0 o NA
  pivot_wider(
    names_from = B, 
    values_from = r2, 
    values_fill = NA # Rellena con A donde no haya datos de LD
  )

# save rd object
saveRDS( ld_matrix,
         file = str_replace( string = chunkfile, pattern = ".temp_raw.vcor", replacement = ".rds" ) )

rm( list = ls( ) )
gc( )