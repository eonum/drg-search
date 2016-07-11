// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$( function() {
    var change_level = function() {
        var level_url = $('#level-select').find(":selected").val();
        window.location.href = level_url;
    }

    $(document).on('change', '#level-select', change_level);

});