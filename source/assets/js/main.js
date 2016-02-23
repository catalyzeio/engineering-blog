$(document).ready(function(){

    // If there is no summary then hide it
    var sum = $('.blog-left .intro');
    var sumP = $('.blog-left .intro p');
    if( !$.trim( sumP.html() ).length ){
        sum.hide(0);
    }

    // Mobile menu
    var menuBtn = $('#menu');
    var nav = $('.main-header nav');
    menuBtn.click(function(e){
        e.preventDefault();
        nav.fadeToggle(0);
    });

    if( $(window).width() > 900){
        nav.show(0);
    }

});
