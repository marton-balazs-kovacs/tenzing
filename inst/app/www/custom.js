$(document).ready(function() {
  // Prevent click behavior on disabled buttons
  $(document).on('click', 'button[disabled]', function(e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  });

  // Specifically target download buttons
  $(document).on('click', 'a[disabled]', function(e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  });
});
