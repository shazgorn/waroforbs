$('#login_form').submit((e) ->
  e.preventDefault()
  localStorage.setItem('token', $('#login').val())
  location.pathname = '/game';
);
