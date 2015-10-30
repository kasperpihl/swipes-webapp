var $ = window.jQuery;
var checkbox = $('.checkbox');
var check = $('.check');

$(document).ready(function(){
	checkbox.on('click', function() {
		if ($(this).children(check).hasClass('checked')) {
			$(this).children(check).removeClass('checked');
		} else {
			$(this).children(check).addClass('checked');
		}
	})

	$('.more-checkboxes').on('click', function() {
		if ($('.dropdown').hasClass('dropped')) {	
			$('.dropdown').removeClass('dropped');
		} else {	
			$('.dropdown').addClass('dropped');		
		}
	})
})


