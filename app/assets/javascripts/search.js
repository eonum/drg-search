// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() {
    var deleteItem = function(code, element){
        code = String(code);
        var codes = $(element).val().split(',');
        var index = codes.indexOf(code);
        if (index > -1) {
            codes.splice(index, 1);
        }
        $(element).val(codes.join(','));
        updateComparison();
    }

    var addRemoveFunction = function(){
        $('.removeCode').click(function(){
            deleteItem($(this).data('code'), '#codes');
        });

        $('.removeHospital').click(function(){
            deleteItem($(this).data('hospital-id'), '#hospitals');
        });
    }

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

    var updateComparison = function(){
        var hospitals = $('#hospitals').val();
        var codes = $('#codes').val();
        var url = $('#compareUrl').val();
        $.get(url, {codes: codes, hospitals: hospitals})
            .done(function (data) {
                $('#comparison-resultsbox').html(data);
                addRemoveFunction();
            });
        setURL();
    }

    var assembleArray = function(item, list){
        var temp = [];
        for (var i = 0; i < list.length; i++){
            var h = list[i]
            if(h != '' && temp.indexOf(h) == -1)
                temp.push(h);
        }
        if(temp.indexOf(item) == -1)
            temp.push(item);
        return temp.join(',')
    }

    var hospitalSelection = function() {
        var hospital_id = String($(this).data('hospital-id'));
        var hospitals = $('#hospitals').val().split(',');
        $('#hospitals').val(assembleArray(hospital_id, hospitals));
        updateComparison();
        $(this).hide();
    }

    var codeSelection = function() {
        var code = String($(this).data('code'));
        var codes = $('#codes').val().split(',');
        $('#codes').val(assembleArray(code, codes));
        updateComparison();
        $(this).hide();
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

    addRemoveFunction();
});
