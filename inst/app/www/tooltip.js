$( document ).ready(function() {
  Shiny.addCustomMessageHandler('add_tooltip', function(what) {
    $(what).attr('title', 'Please upload a valid infosheet');
  });
  
  Shiny.addCustomMessageHandler('remove_tooltip', function(where) {
    $(where).removeAttr('title');
  });
});
