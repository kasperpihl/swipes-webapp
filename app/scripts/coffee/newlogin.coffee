# Sign-up form
$('#sign-up').on 'submit', (e) ->
  target = $(e.target);
  email = target.find('.email').val()
  username = target.find('.username').val()
  password = target.find('.password').val()
  repassword = target.find('.repassword').val()

  data =
    email: email,
    username: username,
    password: password,
    repassword: repassword

  settings = {
    url: 'http://localhost:5000/v1/users.create'
    type: 'POST'
    dataType: 'json'
    contentType: "application/json; charset=utf-8"
    crossDomain : true
    data: JSON.stringify data
    success: (data) ->
      target.find('.email').val('')
      target.find('.username').val('')
      target.find('.password').val('')
      target.find('.repassword').val('')
    error: (error) ->
      console.log error.err
  }

  $.ajax settings

  return false

# Sign-in form
$('#sign-in').on 'submit', (e) ->
  target = $(e.target);
  email = target.find('.email').val()
  password = target.find('.password').val()

  data =
    email: email,
    password: password

  settings = {
    url: 'http://localhost:5000/v1/users.login'
    type: 'POST'
    dataType: 'json'
    contentType: "application/json; charset=utf-8"
    crossDomain : true
    data: JSON.stringify data
    xhrFields:
      withCredentials: true
    success: () ->
      window.location = '/'
    error: (error) ->
      console.log error.err
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
