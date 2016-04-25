// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() {
    /**
     * set the URL with the correct codes and hospital parameters.
     * Hence we can enable a reload of the page.
     */
    var setURL = function(){
        var path = purl().data.attr.path;
        var hospitals = $('#hospitals').val();
        var codes = $('#codes').val();
        if("replaceState" in window.history)
            window.history.replaceState({}, 'DRG comparison', path + '?codes=' + codes + '&hospitals=' + hospitals);
    }

    var updateComparison = function(button){
        var hospitals = $('#hospitals').val();
        var codes = $('#codes').val();
        var url = $('#compareUrl').val();
        button.hide();
        $.get(url, {codes: codes, hospitals: hospitals})
            .done(function (data) {
                $('#comparison-resultsbox').html(data);
            });
        setURL();
    }

    var hospitalSelection = function() {
        var hospital_id = $(this).data('hospital-id');
        $('#hospitals').val($('#hospitals').val() + ',' + hospital_id);
        updateComparison($(this));
    }

    var codeSelection = function() {
        var code = $(this).data('code');
        $('#codes').val($('#codes').val() + ',' + code);
        updateComparison($(this));
    }

    $('#hospital_search').keydown(function () {
        var searchTerm = $('#hospital_search').val();
        var searchUrl = $('#hospital_search').data('search-url') + '.html';
        $.get(searchUrl, {term: searchTerm, limit: 6})
            .done(function (data) {
                $('#hospitalSearchResults').html(data);
                $('.nav-tabs a[href="#hospitalSearchResults"]').tab('show');
                $('.hospitalselection').click(hospitalSelection);
            });
    });

    $('#number_search').keydown(function () {
        var searchTerm = $('#number_search').val();
        var searchUrl = $('#number_search').data('search-url') + '.html';
        $.get(searchUrl, {term: searchTerm, limit: 5, level: 'drg'})
            .done(function (data) {
                $('#drgSearchResults').html(data);
                $('.nav-tabs a[href="#drgSearchResults"]').tab('show');
                $('.codeSelection').click(codeSelection);
            });
        $.get(searchUrl, {term: searchTerm, limit: 5, level: 'mdc'})
            .done(function (data) {
                $('#mdcSearchResults').html(data);
                $('.codeSelection').click(codeSelection);
            });
        $.get(searchUrl, {term: searchTerm, limit: 5, level: 'adrg'})
            .done(function (data) {
                $('#adrgSearchResults').html(data);
                $('.codeSelection').click(codeSelection);
            });
    });
});
