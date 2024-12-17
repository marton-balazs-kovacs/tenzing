$( document ).ready(function() {
  // JavaScript function to update card styles dynamically
  Shiny.addCustomMessageHandler("update_card_styles", function(data) {
    // Target the card and header elements
    var card = document.getElementById(data.cardId);
    var headerText = document.getElementById(data.headerTextId);
    
    console.log(card)
    console.log(data.cardId)
    console.log(headerText)
    console.log(data.headerTextId)
    console.log("fuck")
    if (card && headerText) {
      console.log(data.borderColor)
      console.log(data.textColor)
      // Update the border color
      card.style.borderColor = data.borderColor;
  
      // Update the header text color
      headerText.style.color = data.textColor;
    }
  });
});
