// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() {
    $('#hospital_search').keydown(function () {
        searchTerm = $('#hospital_search').val();
        searchUrl = $('#hospital_search').data('search-url');
        $.get(searchUrl, {term: searchTerm, limit: 5, format: 'json'})
            .done(function (data) {
                $('#hospitalSearchResults').html(data);
                $('.nav-tabs a[href="#hospitalSearchResults"]').tab('show');
            });
    });
});
