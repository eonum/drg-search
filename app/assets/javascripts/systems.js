// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$( function() {
    var change_system = function() {
        var system_url = $('#version-select').find(":selected").val();
        window.location.href = system_url;
    }

    $(document).on('change', '#version-select', change_system);

});