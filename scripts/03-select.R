# load pkgs
pacman::p_load( "dplyr", "tidyr", "vroom", "vroom", "ggplot2", "ggrepel" )

# load args# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "tmp.tsv"
# args[2] <- "21_5231730_C_G"
# args[3] <- "22_50773552_A_G"

# put a name to args
tsv_file <- args[1]
snp1 <- args[2]
snp2 <- args[3]

# load data
ld.df <- vroom( file = tsv_file, col_names = c( "snpA", "snpB", "r2" ) ) %>% 
  as_tibble( )

# function to vis all r2...
plot_ld.f <- function( the_snp ){ 
  
  snp.dfA <- ld.df %>% 
    filter( snpA == the_snp )
  
  snp.dfB <- ld.df %>% 
    filter( snpB == the_snp ) %>% 
    mutate( snpA.t = snpB,
            snpB = snpA,
            snpA = snpA.t ) %>% 
    select( -snpA.t )
  
  snp.df_all <- bind_rows( snp.dfA, snp.dfB ) %>% 
    select( -snpA ) %>% 
    separate( col = snpB,
              into = c( "chr", "pos", "ref", "alt" ) ) %>% 
    mutate( chr = as.numeric( chr ),
            pos = as.numeric( pos ) )
  
  # prepare main data
  # Split the strings by the underscore
  the_snp.df <- data.frame( base = the_snp ) %>% 
    separate( col = base,
              into = c( "chr", "pos", "ref", "alt" ) ) %>% 
    mutate( chr = as.numeric( chr ),
            pos = as.numeric( pos ),
            r2 = 1 )
  
  ld.p <- ggplot( data = snp.df_all,
                  mapping = aes( x = pos,
                                 y = r2,
                                 color = as.factor( chr ) ) ) +
    geom_point( size = 1, shape = 1 ) +
    geom_label_repel( data = the_snp.df,
                      mapping = aes( label = the_snp ),
                      color = "black", nudge_y = 0.1 ) +
    geom_point( data = the_snp.df, color = "black", shape = 18 ) +
    labs( title = paste( "Long Range LD for:", the_snp ) ) +
    facet_wrap( ~chr ) +
    theme_linedraw( base_size = 15 ) +
    theme( legend.position = "none" )
  
  return( ld.p )
  
}

snp1.p <- plot_ld.f( the_snp = snp1 )
snp2.p <- plot_ld.f( the_snp = snp2 )

# plot both
# find the r2
both.df <- ld.df %>% 
  filter( ( snpA == snp1 & snpB == snp2 ) | ( snpA == snp2 & snpB == snp1 ) ) %>% 
  pivot_longer( cols = snpA:snpB,
                names_to = "column",
                values_to = "coords" ) %>% 
  select( -column ) %>% 
  separate( col = coords,
            into = c( "chr", "pos", "ref", "alt" ) ) %>% 
  mutate( chr = as.numeric( chr ),
          pos = as.numeric( pos ) )

both.p <- ggplot( data = both.df,
                  mapping = aes( x = pos,
                                 y = r2 ) ) +
  geom_segment( aes( xend = pos, yend = 0 ), color = "darkblue" ) +
  geom_label_repel( mapping = aes( label = paste( chr, pos, ref, alt ) ),
                    color = "black", nudge_y = 0.1 ) +
  geom_point( color = "darkblue" ) +
  scale_y_continuous( limits = c( 0, 1 ) ) +
  labs( title = "LD between 2 SNPs",
        subtitle = paste( "snp1:", snp1, "\tsnp2:", snp2 ),
        caption = paste( "r2:", both.df$r2 %>%  unique( ) ) ) +
  facet_wrap( ~chr ) +
  theme_linedraw( base_size = 15 )

# prepare a base filename
basename <- paste0( snp1, "x", snp2, "." )

# save the plots
ggsave( plot = snp1.p, file = paste0( basename, "snp1.png"),
        width = 10, height = 10 )

ggsave( plot = snp2.p, file = paste0( basename, "snp2.png"),
        width = 10, height = 10 )

ggsave( plot = both.p, file = paste0( basename, "both.png"),
        width = 10, height = 10 )
