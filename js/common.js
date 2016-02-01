$(function() {
    $('#login_form').submit(function(e) {
	e.preventDefault();
	localStorage.setItem('user_id', $('#login').val());
	location.pathname = '/game';
    });
});
