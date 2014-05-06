define [
], () ->
  class Authenticator
    auth: ->
      div = $("<div id='authenticator' />")

      ifame = $("<iframe src='...'></iframe>")
      
      div.addClass 'a'

  Authenticator