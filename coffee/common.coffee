$('#login_form').submit((e) ->
        e.preventDefault()
        localStorage.setItem('user_id', $('#login').val())
        location.pathname = '/game';
);
