$(document).ready(function() {
    $("form#hit_form input").click(function() {
	alert("Player hits!");

	$.ajax({
	    type: "POST",
	    url: "/game/player/hit"
	});

	return false;
    });
});
