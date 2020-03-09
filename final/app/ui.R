
library(shiny)

shinyUI(fluidPage(
    titlePanel("Capstone project: predicting words"),
    mainPanel(
        h3("About"),
        p("This demo shows how an n-gram model can be used to suggest the next word to type."),
        p("The algorithm uses n-grams and a back-off smoothing technique for unseen combinations of words."),
        h3("Try it out!"),
        textInput(inputId = "text", label = NULL, width = "40%", placeholder = "Try it out"),
        htmlOutput('predictions')
    )
))
