# Sign-up form
$('#sign-up').on 'submit', (e) ->
  target = $(e.target);
  email = target.find('.email input').val()
  username = target.find('.username input').val()
  password = target.find('.password input').val()
  repassword = target.find('.repassword input').val()

  data =
    email: email,
    username: username,
    password: password,
    repassword: repassword
  urlbase = 'http://' + document.location.hostname + ':5000'
  settings = {
    url: urlbase + '/v1/users.create'
    type: 'POST'
    dataType: 'json'
    contentType: "application/json; charset=utf-8"
    crossDomain : true
    data: JSON.stringify data
    success: (data) ->
      window.location = '/'
    error: (errors) ->
      errors = errors.responseJSON.errors

      handleErrors target, errors
  }

  $.ajax settings

  return false

# Sign-in form
$('#sign-in').on 'submit', (e) ->
  target = $(e.target);
  email = target.find('.email input').val()
  password = target.find('.password input').val()

  data =
    email: email,
    password: password
  urlbase = 'http://' + document.location.hostname + ':5000'
  settings = {
    url: urlbase + '/v1/users.login'
    type: 'POST'
    dataType: 'json'
    contentType: "application/json; charset=utf-8"
    crossDomain : true
    data: JSON.stringify data
    xhrFields:
      withCredentials: true
    success: () ->
      window.location = '/'
    error: (errors) ->
      errors = errors.responseJSON.errors

      handleErrors target, errors
  }

  $.ajax settings

  return false

# Hide/show forms
$('.sign-in-btn').on 'click', () ->
  $('.signup').addClass 'hidden'
  $('.login').removeClass 'hidden'
  $('.sign-in-link').addClass 'hidden'
  $('.sign-up-link').removeClass 'hidden'

$('.sign-up-btn').on 'click', () ->
  $('.login').addClass 'hidden'
  $('.signup').removeClass 'hidden'
  $('.sign-up-link').addClass 'hidden'
  $('.sign-in-link').removeClass 'hidden'

# Handle errors
handleErrors = (target, errors) ->
  target.find('.input-wrapper').removeClass 'error'
  target.find('.input-wrapper input').removeClass 'error'

  errors.forEach (error) ->
    element = target.find('.input-wrapper.' + error.field)

    element.attr('error-attribute', error.message)
    element.addClass 'error'
    element.find('input').addClass 'error'
