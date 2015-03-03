$(document).ready(function() {
    $("form#hit_form input").click(function() {
	alert("Player hits!");

	$.ajax({
	    type: "POST",
	    url: "/game/player/hit"
	}).done(function(msg) {
	    alert(msg);
	});

	return false;
    });
});
