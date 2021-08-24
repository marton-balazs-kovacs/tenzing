$( document ).ready(function() {
  Shiny.addCustomMessageHandler('add_tooltip', function(arg) {
    $(arg.where).attr('title', arg.message);
  });
  
  Shiny.addCustomMessageHandler('remove_tooltip', function(where) {
    $(where).removeAttr('title');
  });
});
