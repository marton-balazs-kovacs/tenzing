# Function to validate url
valid_url <- function(url_input){
  if(url_input == ""){
    "Please provide a URL"
  } else if(!RCurl::url.exists(url_input)){
    "The URL is not accessible"
  } else{
    NULL
  }
}