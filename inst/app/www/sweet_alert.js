$( document ).ready(function() {
  function success_alert() {
    Swal.fire({
      icon: 'success',
      title: '<font style="color:#b2dcce;"> The infosheet is valid! </font> ',      
      timer: 2000,
      timerProgressBar: true,
      showCancelButton: false,
      showConfirmButton: false
    });
  }
  
  Shiny.addCustomMessageHandler('error_alert', function(message) {
    Swal.fire({
      icon: 'error',
      html: '<p style="color:#D45F68;font-size:15px">' + message.error + '</p>' +
            '<p style="color:#FFDD4F;font-size:15px">' + message.warning + '</p>',
      width: 400,
      showCancelButton: false,
      showConfirmButton: false,
      showCloseButton: true
    });
  });
  
  Shiny.addCustomMessageHandler('warning_alert', function(message) {
    Swal.fire({
      icon: 'info',
      html: '<p style="color:#FFDD4F;font-size:15px">' + message + '</p>',
      width: 600,
      showCancelButton: false,
      showConfirmButton: false,
      showCloseButton: true
    });
  });
});
