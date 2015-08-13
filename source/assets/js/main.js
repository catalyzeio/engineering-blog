$(document).ready(function(){

	var sum = $('.blog-left .intro');
	var sumP = $('.blog-left .intro p');

	// If there is no summary then hide it
	if( !$.trim( sumP.html() ).length ){
		sum.hide(0);
	}

});