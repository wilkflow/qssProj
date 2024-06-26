text_emotion <- read.csv("./text_emotion_with_gemini.csv")
head(text_emotion) #optional: check the beginning of the dataset

#remove all NA's to only analyze Gemini's performance
text_emotion_only_gemini <- na.omit(text_emotion)
head(text_emotion_only_gemini) #optional: verify that the dataset was cleaned


# Define a function to map numeric values to sentiment words
map_sentiment <- function(value) {
  sentiment_map <- c("anger", "boredom", "empty", "enthusiasm", "fun", 
                     "happiness", "hate", "love", "neutral", "relief", 
                     "sadness", "surprise", "worry")
  return(sentiment_map[value])
}


# Convert the numeric values in the gemini column to sentiment words
text_emotion_only_gemini$gemini <- sapply(text_emotion_only_gemini$gemini, map_sentiment)

print(text_emotion_only_gemini) #Optional:View the updated dataset
# Load required library for plotting
# Convert the sentiment_distribution data into a long format
library(tidyr)
library(ggplot2)

# Convert the rownames of sentiment_distribution to a new column
sentiment_distribution <- table(text_emotion_only_gemini$sentiment, text_emotion_only_gemini$gemini)
sentiment_distribution <- as.data.frame.matrix(sentiment_distribution)
sentiment_distribution$sentiment <- rownames(sentiment_distribution)

# Define custom colors for the bar plot
# Define breaks and labels for y-axis
breaks <- seq(0, 600, by = 100)
labels <- seq(0, 600, by = 100)
custom_colors <- c("red", "orange", "yellow", "green", "blue", "cyan", "purple", "magenta", "pink", "brown", "tan3", "gray", "gray26")
sentiment_long <- tidyr::pivot_longer(sentiment_distribution, cols = -sentiment, names_to = "gemini", values_to = "count")

# Create a stacked bar chart of sentiment distribution with custom colors
ggplot(sentiment_long, aes(x = sentiment, y = count, fill = gemini)) +
  geom_bar(stat = "identity",) +
  labs(title = "Stacked Sentiment Distribution (Crowdworkers vs Gemini)",
       x = "Sentiment",
       y = "Frequency") +
  scale_fill_manual(values = custom_colors) +  # Apply custom colors
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, size = 10), plot.title = element_text(size = 12, hjust = 0)) +
  scale_y_continuous(breaks = breaks, labels = labels) # Text adjustment for the x and y axis respectively
