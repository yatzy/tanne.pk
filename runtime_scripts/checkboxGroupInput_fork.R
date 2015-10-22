checkboxGroupInput_fork <- function(inputId, label, choices, selected = NULL, inline = FALSE, width = NULL){
  temp.choices <- names(choices)
  n <- length(choices)
  names(temp.choices) <- paste0("ABCZYXWVU",1:n)
  temp.names = names(temp.choices)
  html <- as.character(
    checkboxGroupInput(inputId, label, temp.choices, selected=names(temp.choices[temp.choices==selected]), inline , width))
  
  for(i in 1:n){
    html <- sub(temp.names[i], as.character(choices[[i]]), html)
  }
  
  attr(html,"html") <- TRUE
  html
}