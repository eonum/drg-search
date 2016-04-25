// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() {
    var hospitalSelection = function() {
        hospital_id = $(this).data('hospital-id');
        $('#hospitals').val($('#hospitals').val() + ',' + hospital_id);
        hospitals = $('#hospitals').val();
        codes = $('#codes').val();
        url = $('#compareUrl').val();
        $(this).hide();
        $.get(url, {codes: codes, hospitals: hospitals})
            .done(function (data) {
                $('#comparison-resultsbox').html(data);
            });
    }

    $('#hospital_search').keydown(function () {
        searchTerm = $('#hospital_search').val();
        searchUrl = $('#hospital_search').data('search-url') + '.html';
        $.get(searchUrl, {term: searchTerm, limit: 6})
            .done(function (data) {
                $('#hospitalSearchResults').html(data);
                $('.nav-tabs a[href="#hospitalSearchResults"]').tab('show');

                $('.hospitalselection').click(hospitalSelection);
            });
    });

    $('#number_search').keydown(function () {
        searchTerm = $('#number_search').val();
        searchUrl = $('#number_search').data('search-url') + '.html';
        $.get(searchUrl, {term: searchTerm, limit: 5, level: 'drg'})
            .done(function (data) {
                $('#drgSearchResults').html(data);
                $('.nav-tabs a[href="#drgSearchResults"]').tab('show');
            });
        $.get(searchUrl, {term: searchTerm, limit: 5, level: 'mdc'})
            .done(function (data) {
                $('#mdcSearchResults').html(data);
            });
        $.get(searchUrl, {term: searchTerm, limit: 5, level: 'adrg'})
            .done(function (data) {
                $('#adrgSearchResults').html(data);
            });
    });
});
