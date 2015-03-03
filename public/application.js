$(document).ready(function() {
    player_hits();
    player_stands();
});

function player_hits() {
    $(document).on("click", "form#hit_form input", function(){
	alert("Player hits!");
	$.ajax({
	    type: "POST",
	    url: "/game/player/hit"
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});

	return false;
    });
};

function player_stands() {
    $(document).on("click", "form#stand_form input", function(){
	alert("Player stands!");
	$.ajax({
	    type: "POST",
	    url: "/game/player/stand"
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});

	return false;
    });
};




