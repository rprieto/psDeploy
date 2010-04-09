
$(document).ready(function() {

	// Add code syntax highlighting
	prettyPrint();

	// Make headers clickable to reveal content
	$('.collapsible-header').click(function(){
		$(this).next().toggle();
		return false;
	});

	$(".accordion").accordion({
		header: 'h4',
		collapsible: true,
		active: false,
		autoHeight: false
	});
	
	$('.collapsible-header').click(function(){
		var x = $(this).parent().children(".collapsible-content");
		$(this).parent().children(".collapsible-content").css('display', 'none');
		$(this).next(".collapsible-content").css('display', 'block');
		return false;
	});
	
});
