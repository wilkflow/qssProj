# Function to interact with Google's Gemini API
gemini <- function(prompts,
                   temperature = 0.0,
                   max_output_tokens = 1024,
                   api_key = Sys.getenv("GEMINI_API_KEY"),
                   model = "gemini-pro") {
  
  if (nchar(api_key) < 1) {
    api_key <- readline("Paste your API key here: ")
    Sys.setenv(GEMINI_API_KEY = api_key)
  }
  
  model_query <- paste0(model, ":generateContent")
  
  response <- POST(
    url = paste0("https://generativelanguage.googleapis.com/v1beta/models/", model_query),
    query = list(key = api_key),
    content_type_json(),
    encode = "json",
    body = list(
      contents = list(
        parts = lapply(prompts, function(prompt) list(text = prompt))
      ),
      generationConfig = list(
        temperature = temperature,
        maxOutputTokens = max_output_tokens
      )
    )
  )
  
  if (response$status_code > 200) {
    stop(paste("Error - ", content(response)$error$message))
  }
  
  candidates <- content(response)$candidates
  outputs <- lapply(candidates, function(candidate) unlist(lapply(candidate$content$parts, function(part) part$text)))
  
  return(outputs)
}

# Read in your dataset
text_emotion <- read.csv("C:/Users/mrepi/Downloads/text_emotion.csv")

# Create a "gemini" column
text_emotion$gemini <- NA

# Define batch size
batch_size <- 10

# Run the loop in batches
num_batches <- ceiling(nrow(text_emotion) / batch_size)

# Start timing
tic()

for (i in 1:num_batches) {
  start_idx <- (i - 1) * batch_size + 1
  end_idx <- min(i * batch_size, nrow(text_emotion))
  
  batch_prompts <- text_emotion[start_idx:end_idx, "content"]
  batch_results <- gemini(batch_prompts)
  
  for (j in seq_along(batch_results)) {
    question <- "Which sentiment best describes this text? Answer only with a number: 1 if anger, 2 if boredom, 3 if empty, 4 if enthusiasm, 5 if fun, 6 if happiness, 7 if hate, 8 if love, 9 if neutral, 10 if relief, 11 if sadness, 12 if surprise, 13 if worry. Here is the text:"
    text <- batch_prompts[j]
    concat <- paste(question, text)
    result <- gemini(concat)
    
    while (length(result) == 0) {
      result <- gemini(concat)
    }
    
    text_emotion$gemini[start_idx + j - 1] <- result
  }
  
  cat("Processed batch", i, "of", num_batches, "\n")
}

# End timing
toc()

# Assuming your dataset is named text_emotion_with_gemini
# Convert the lists to character vectors
text_emotion <- lapply(text_emotion, function(x) if(is.list(x)) sapply(x, toString) else x)

# Convert the modified list to a data frame
text_emotion_df <- as.data.frame(text_emotion)

# Save the data frame to a CSV file
write.csv(text_emotion_df, "text_emotion.csv", row.names = FALSE)

# Take only the first string from "gemini" and convert to a numeric 
text_emotion$gemini <- substr(text_emotion$gemini, 1, 1)  
text_emotion$gemini <- as.numeric(text_emotion$gemini)

# View the dataset with Gemini sentiment analysis results
print(text_emotion)
