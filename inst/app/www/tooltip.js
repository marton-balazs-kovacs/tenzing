$(document).ready(function() {
  Shiny.addCustomMessageHandler('add_tooltip', function(arg) {
    console.log('Adding tooltip:', arg); // Debugging
    $(arg.where).attr('title', arg.message).tooltip({ trigger: 'hover' });
  });

  Shiny.addCustomMessageHandler('remove_tooltip', function(where) {
    console.log('Removing tooltip from:', where); // Debugging
    $(where).tooltip('dispose').removeAttr('title');
  });
});