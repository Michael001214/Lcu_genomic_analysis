# Load libraries
library(tidyverse)

# Set working directory
setwd("D:/Thesis_data/vcf_analysis(new)")

# Define chromosomes and their lengths (bp)
chromosomes <- list(
  'CM022944.1' = 161201790,
  'CM022945.1' = 156741500,
  'CM022946.1' = 152877416,
  'CM022947.1' = 144049803,
  'CM022948.1' = 113311659,
  'CM022949.1' = 93777777,
  'CM022950.1' = 83800533,
  'CM022951.1' = 82381005,
  'CM022952.1' = 76706323,
  'CM022953.1' = 67094936,
  'CM022954.1' = 64384616,
  'CM022955.1' = 55346439
)

# Parameters
window_size <- 1000000   # 1 Mbp
step_size <- 100000      # 100 kb
gap <- 40                # Mbp gap between chromosomes for plotting

# Load variants position data
snp_data_m <- read.table("f00_pos.txt", col.names = c('Chromosome', 'Position')) %>%
  mutate(Variant = "M variants")  # male associate variants(雌性樣本與ref相同的位點(f00))

snp_data_f <- read.table("m00_pos.txt", col.names = c('Chromosome', 'Position')) %>%
  mutate(Variant = "F variants")  # female associate variants(雄性樣本與ref相同的位點(m00))


# Function to compute sliding window SNP counts
compute_sliding_density <- function(snp_data, chromosomes, window_size, step_size, label) {
  result <- tibble()
  
  for (chrom in names(chromosomes)) {
    chr_len <- chromosomes[[chrom]]
    snps_chr <- snp_data %>% filter(Chromosome == chrom)
    
    window_starts <- seq(1, chr_len - window_size, by = step_size)
    
    counts <- sapply(window_starts, function(start) {
      end <- start + window_size - 1
      sum(snps_chr$Position >= start & snps_chr$Position <= end)
    })
    
    result <- bind_rows(result, tibble(
      Chromosome = chrom,
      Start = window_starts,
      End = window_starts + window_size - 1,
      Midpoint = window_starts + window_size / 2,
      Count = counts,
      Variant = label
    ))
  }
  return(result)
}

# Compute sliding window data
density_f <- compute_sliding_density(snp_data_f, chromosomes, window_size, step_size, "F variants")
density_m <- compute_sliding_density(snp_data_m, chromosomes, window_size, step_size, "M variants")

# Combine and assign chromosome offset positions
plot_data <- bind_rows(density_f, density_m)

x_offset <- 0
chrom_offsets <- list()

plot_data <- plot_data %>%
  group_by(Chromosome) %>%
  group_modify(~{
    offset <- x_offset
    chrom <- .y$Chromosome  # <- 這裡是重點，取得當前群組的染色體名稱
    .x <- .x %>% mutate(x = Midpoint / 1e6 + offset)
    chrom_offsets[[chrom]] <<- offset
    x_offset <<- max(.x$x) + gap
    .x
  }) %>% ungroup()


# Get midpoint x-values for chromosome labels
chrom_labels <- names(chromosomes)
chrom_midpoints <- sapply(chrom_labels, function(chrom) {
  chr_data <- plot_data %>% filter(Chromosome == chrom)
  if (nrow(chr_data) > 0) {
    mean(range(chr_data$x))
  } else {
    NA
  }
})

# Build tick positions and chromosome label positions
tick_positions <- c()
tick_labels <- c()
chrom_labels <- names(chromosomes)
chrom_label_positions <- c()

for (chrom in chrom_labels) {
  offset <- chrom_offsets[[chrom]]
  chr_length_mbp <- chromosomes[[chrom]] / 1e6
  
  ticks <- seq(0, floor(chr_length_mbp), by = 20)
  if (tail(ticks, 1) < chr_length_mbp - 5) {
    ticks <- c(ticks, round(chr_length_mbp, 1))  # ← 加上結尾刻度
  }
  
  tick_positions <- c(tick_positions, offset + ticks)
  tick_labels <- c(tick_labels, as.character(ticks))
  
  # 染色體中間位置 for chromosome label
  chrom_data <- plot_data %>% filter(Chromosome == chrom)
  if (nrow(chrom_data) > 0) {
    chrom_mid <- mean(range(chrom_data$x))
    chrom_label_positions <- c(chrom_label_positions, chrom_mid)
  } else {
    chrom_label_positions <- c(chrom_label_positions, offset + chr_length_mbp / 2)
  }
}

# PLOT
p <- ggplot(plot_data, aes(x = x, y = Count, color = Variant, group = interaction(Chromosome, Variant))) +
  geom_line(alpha = 0.7) +
  scale_color_manual(values = c("F variants" = "red", "M variants" = "blue")) +
  scale_x_continuous(breaks = tick_positions, labels = tick_labels) +
  labs(
    title = "F vs M variant Density",
    x = "Position (Mbp)",
    y = "Number of variants"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, size = 8, hjust = 0, vjust = 0.2),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.title = element_blank()
  )

# Add chromosome names as annotations
for (i in seq_along(chrom_labels)) {
  p <- p + annotate("text", x = chrom_label_positions[i], 
                    y = -max(plot_data$Count) * 0.05, 
                    label = chrom_labels[i], size = 3, fontface = "bold")
}

# Save the plot
ggsave("F_vs_M_sliding_window_density_fixed.png", plot = p, width = 17, height = 5, dpi = 500)

