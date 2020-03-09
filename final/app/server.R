#Libraries
library(shiny)
library(ggplot2)
library(stringr)
library(dplyr)
library(data.table)

model.unigrams <- fread('./data/model.unigrams.csv')
model.ngrams <- fread('./data/model.ngrams.csv')

cleanup = function(text) {
  text = tolower(text)
  text = str_replace_all(text, "[0-9]+", "")
  text = str_replace_all(text, "[^a-z0-9 ]+", "")
  text = str_replace_all(text, " +", " ")
  text = str_replace_all(text, "^ +", "")
  text = str_replace_all(text, " +$", "")
  
  return (text)
}

predict = function(text) {
  # First we normalize the input to match the texts in our prediction model. Then we check 
  # what our context is and use as long an n-gram (history) as possible, using back-off.

  tokens <- strsplit(cleanup(text), " ")[[1]]

  # Back-off algorithm n-gram model
  for(history in 3:1) {
    tokens_base <- paste(tail(tokens, history), collapse = '_')
    matches = model.ngrams[ngramsize == history + 1 & base == tokens_base][order(-frequency)]
    if (nrow(matches) >= 1) {
      return(matches[1]$prediction)
    }
  }
  
  # Fallback to unigram model
  return(model.unigrams[order(-frequency)][1]$unigram)
}

function(input, output) {
  
  # Generate data
  predictions <- reactive({
    predict(input$text)
  })

  # Generate output for display
  output$predictions <- renderUI({
    HTML(paste("<p><b>Suggested word:</b>", paste(predictions(), collapse = ' ')), "</p>")
  })
}
