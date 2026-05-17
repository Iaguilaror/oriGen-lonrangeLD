# load pkgs
pacman::p_load( "tidyr", "dplyr", "ggplot2", "vroom", "stringr", "data.table" )

# load args# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "chr21and22_random10000_clean_matrix.ld.tsv.gz"

# put a name to args
tsv_file <- args[1]

# load data
ld.df <- vroom( file = tsv_file )

# count by ID in SNPA
# alln_bysnp.df <- ld.df %>% 
#   count( SNP_A )
# 
# # search a low n
# lown.df <- alln_bysnp.df %>% 
#   filter( n == 7 )
# 
# sample_one.df <- ld.df %>% 
#   filter( SNP_A == "22_50778303_C_T" | SNP_B == "22_50778303_C_T" )

# count the snp in any side
allregs.df <- ld.df %>% 
  select( -R2 ) %>% 
  pivot_longer( cols = 1:2,
                names_to = "side",
                values_to = "ID" ) %>% 
  select( -side ) %>% 
  count( ID )

n_histo.p <- ggplot( data = allregs.df,
                     mapping = aes( x = n ) ) +
  geom_histogram( fill = "white",
                  color = "black", bins = 100, width = 0.1 ) +
  labs( title = "number of calculated pairs by SNP",
        caption = "this should be a single value, so every snp was
        tested the same number of times" ) +
  theme_classic( base_size = 20 )

# lets plot the distribution of R2
r2.p <- ggplot( data = ld.df,
                mapping = aes( x = R2 ) ) +
  geom_histogram( binwidth = 0.01 ) +
  scale_x_continuous( breaks = seq( from = 0, to = 1, by = 0.05 ) ) +
  labs( title = "Distribution of R2",
        subtitle = paste( "total r2 pairs:", nrow( ld.df ) ),
        caption = "this helps us to decide a R2 cutoff to reduce file size imprint" ) +
  theme_classic( base_size = 20 ) +
  theme( axis.text.x = element_text( angle = 90, hjust = 0.5, vjust = 0.5 ) )

# save plots
ggsave( plot = n_histo.p, filename = "n_histo.png" ,
        width = 14, height = 14 )

ggsave( plot = r2.p, filename = "r2.png" ,
        width = 14, height = 14 )

# count interchrom links
cleaned_ld.df <- ld.df %>%
  select(-R2)

# 1. Convert to data.table
setDT(cleaned_ld.df)

# 2. Drop R2 and strip everything starting at the FIRST underscore
cleaned_ld.df[, SNP_A := sub("_.*", "", SNP_A)]
cleaned_ld.df[, SNP_B := sub("_.*", "", SNP_B)]

str( cleaned_ld.df )

# count intra chr hits
tagged.df <- cleaned_ld.df[, .N, by = .(same = SNP_A == SNP_B)] %>% 
  as_tibble( ) %>% 
  mutate( same = ifelse( test = same == T,
                         yes = "Same Chromosome",
                         no = "Different Chromosome" ) )

# plot
inter.p <- ggplot( data = tagged.df,
                   mapping = aes( x = same,
                                  y = N ) ) +
  geom_col( ) +
  labs( x = "",
        y = "Nunmber of Links",
        caption = "We should see some Diff. Chromosome links..." ) +
  theme_classic( base_size = 10 )

ggsave( plot = inter.p, filename = "inter.png" ,
        width = 7, height = 7 )
