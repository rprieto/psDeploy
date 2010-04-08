
// Add code syntax highlighting
prettyPrint();

$(document).ready(function() {

	// Make headers clickable to reveal content
	$('.collapsible-header').click(function(){
		$(this).next().toggle();
		return false;
	});
	
});
