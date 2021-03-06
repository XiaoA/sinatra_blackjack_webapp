$(document).ready(function() {
    player_hits();
    player_stands();
    dealer_hits();
});

function player_hits() {
    $(document).on("click", "form#hit_form input", function(){
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
	$.ajax({
	    type: "POST",
	    url: "/game/player/stand"
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});

	return false;
    });
};

function dealer_hits() {
    $(document).on("click", "form#dealer_hit input", function(){
	$.ajax({
	    type: "POST",
	    url: "/game/dealer/hit"
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});

	return false;
    });
};




