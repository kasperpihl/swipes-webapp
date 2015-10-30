alert('asfg')


var checkbox = $('.checkbox');
var check = $('.check');

checkbox.on('click', function() {
	if ($(this).children(check).hasClass('checked')) {
		$(this).children(check).removeClass('checked');
	} else {
		$(this).children(check).addClass('checked');
	}
})

$('.more-checkboxes').on('click', function() {
	console.log('main');
	if ($('.dropdown').hasClass('dropped')) {
		console.log('if');		
		$('.dropdown').removeClass('dropped');
	} else {
		console.log('else');	
		$('.dropdown').addClass('dropped');		
	}
})