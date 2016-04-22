// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() {
    $('#hospital_search').keydown(function () {
        searchTerm = $('#hospital_search').val();
        searchUrl = $('#hospital_search').data('search-url');
        $.get(searchUrl, {term: searchTerm, limit: 5, format: 'json'})
            .done(function (data) {
                $('#hospitalSearchResults').html(data[0]['text']);
                $('.nav-tabs a[href="#hospitalSearchResults"]').tab('show');
            });
    });

    $('#number_search').keydown(function () {
        searchTerm = $('#number_search').val();
        searchUrl = $('#number_search').data('search-url');
        $.get(searchUrl, {term: searchTerm, limit: 5, format: 'json', level: 'drg'})
            .done(function (data) {
                $('#drgSearchResults').html(data[0]['text']);
                $('.nav-tabs a[href="#drgSearchResults"]').tab('show');
            });
        $.get(searchUrl, {term: searchTerm, limit: 5, format: 'json', level: 'mdc'})
            .done(function (data) {
                $('#mdcSearchResults').html(data[0]['text']);
            });
        $.get(searchUrl, {term: searchTerm, limit: 5, format: 'json', level: 'adrg'})
            .done(function (data) {
                $('#adrgSearchResults').html(data[0]['text']);
            });
    });
});
