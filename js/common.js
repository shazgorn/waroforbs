(function() {
  jQuery('#login_form').submit(function(e) {
    e.preventDefault();
    localStorage.setItem('user_id', $('#login').val());
    return location.pathname = '/game';
  });

}).call(this);
