library(ggplot2)

# Set file paths
male_file <- "D:/Thesis_data/sex_specific_kmer/M_unique_kmer_10.txt"
female_file <- "D:/Thesis_data/sex_specific_kmer/F_unique_kmer_10.txt"
common_file <- "D:/Thesis_data/sex_specific_kmer/Common_kmer_10.txt"

# Read data
male_kmers <- read.table(male_file, header = FALSE, col.names = c("kmer", "count"), stringsAsFactors = FALSE)
female_kmers <- read.table(female_file, header = FALSE, col.names = c("kmer", "count"), stringsAsFactors = FALSE)
common_kmers <- read.table(common_file, header = FALSE, col.names = c("kmer", "count_male", "count_female"), stringsAsFactors = FALSE)

# 
male_kmers$count <- as.numeric(male_kmers$count)
female_kmers$count <- as.numeric(female_kmers$count)
common_kmers$count_male <- as.numeric(common_kmers$count_male)
common_kmers$count_female <- as.numeric(common_kmers$count_female)
common_kmers<-common_kmers[-c(1),]
# Add category labels
male_kmers$category <- "Male-Specific"
female_kmers$category <- "Female-Specific"
common_kmers$category <- "Common"

# Create structured columns for plotting
male_kmers$Count_Male <- male_kmers$count
male_kmers$Count_Female <- 0

female_kmers$Count_Male <- 0
female_kmers$Count_Female <- female_kmers$count

common_kmers$Count_Male <- common_kmers$count_male
common_kmers$Count_Female <- common_kmers$count_female

# Filter k-mers: Keep only those with counts between 10 and 100,000
filtered_common_kmers <- subset(common_kmers, 
                                (Count_Male >= 10 | Count_Female >= 10) & 
                                  (Count_Male <= 100000 & Count_Female <= 100000))
filtered_common_kmers<-filtered_common_kmers[,-c(2:3)]

# Combine all data
plot_data <- rbind(
  male_kmers[, c("Count_Male", "Count_Female", "category")],
  female_kmers[, c("Count_Male", "Count_Female", "category")],
  filtered_common_kmers[, c("Count_Male", "Count_Female", "category")]
)

# Ensure numeric conversion again
plot_data$Count_Male <- as.numeric(plot_data$Count_Male)
plot_data$Count_Female <- as.numeric(plot_data$Count_Female)

####################
# Scatter plot
p <- ggplot(plot_data, aes(x = Count_Male, y = Count_Female, color = category)) +
  geom_point(alpha = 0.4, size = 0.3) +
  scale_color_manual(values = c("Male-Specific" = "blue", "Female-Specific" = "red", "Common" = "gray")) +
  labs(x = "Count in Male DNA",
       y = "Count in Female DNA",
       title = "K-mer Frequency Distribution") +
  theme_bw() +
  theme(
    aspect.ratio = 1,
    axis.text.x = element_text(size = 10, angle = 45),
    axis.text.y = element_text(size = 10),
    axis.ticks.x = element_line(color = "black"), 
    axis.ticks.y = element_line(color = "black"),
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.position = "none",
    panel.grid = element_blank()
  ) +
  scale_x_continuous(limits = c(0, 100000), breaks = seq(0, 100000, by = 10000)) +  
  scale_y_continuous(limits = c(0, 100000), breaks = seq(0, 100000, by = 10000))   

# Ensure output directory exists
output_dir <- "D:/Thesis_data/sex_specific_kmer/"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Save plot
ggsave("D:/Thesis_data/sex_specific_kmer/kmer_scatter_plot.png", p, width = 6, height = 6, dpi = 600)
