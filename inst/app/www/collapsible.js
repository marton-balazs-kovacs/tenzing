$(document).on("click", ".collapsible-header", function (e) {
  e.preventDefault();

  // Get the target div ID from the `data-target` attribute
  var target = $(this).data("target");
  var targetDiv = $("#" + target);

  // Check if the target div is visible or hidden
  if (targetDiv.css("visibility") === "hidden") {
    // Expand: Show the target div
    targetDiv.css({ visibility: "visible", height: "auto" });
    // Change the icon to up-arrow
    $(this).find("i").removeClass("fa-chevron-down").addClass("fa-chevron-up");
  } else {
    // Collapse: Hide the target div
    targetDiv.css({ visibility: "hidden", height: "0" });
    // Change the icon to down-arrow
    $(this).find("i").removeClass("fa-chevron-up").addClass("fa-chevron-down");
  }
});
