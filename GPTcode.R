### Install Required Packages
library(httr)
library(tidyverse)
library(jsonlite)
#########################
##### GPT prompting #####
#########################

# put your API key in the quotes below: 
my_API <- "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"

#The "hey_chatGPT function will help you access the API and prompt GPT 
hey_chatGPT <- function(answer_my_question) {

  chat_GPT_answer <- POST(
    url = "https://api-inference.huggingface.co/models/openai-community/openai-gpt", 
    add_headers(Authorization = paste("Bearer", my_API)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5",
      temperature = 1,
      messages = list(list(
        role = "user", 
        content = prompt
      ))
    )
  )}


# Read in your dataset
data <- read_csv("./text_emotion.csv")

# Create a "gpt" column
data$gpt <- NA

# Run a loop over your dataset and prompt ChatGPT - an example prompt for sentiment is given
for (i in 1:nrow(data)) {
  print(i)
  question <- "Is the sentiment of this text positive, neutral, or negative? Answer only with a number: 1 if positive, 2 if neutral, and 3 if negative. Here is the text:"
  text <- data[i,4]       
  concat <- paste(question, text)
  result <- hey_chatGPT(concat)
  print(concat)
  res = content(result)
  print(res)
  data$gpt[i] <- res
  i = i+10
}

#Take only the first string from gpt and convert to a numeric 
data$gpt <- substr(data$gpt, 1, 1)  
data$gpt <- as.numeric(data$gpt)
