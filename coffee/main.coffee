login = localStorage.getItem('token')

if login
  $('#login').val(login)

$('#login-form').submit((e) ->
  e.preventDefault()
  login = $('#login').val()
  if login
    localStorage.setItem('token', login)
    location.pathname = '/game'
)
