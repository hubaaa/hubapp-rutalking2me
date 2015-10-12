log = new ObjectLogger 'Meteor.subscribe', 'debug'

Meteor.startup ->
  Meteor.subscribe 'my-account', {
    onStop: (error)->
      try
        log.enter 'my-account.onStop'
        if error?
          log.error error
          alertify.error('Oops. Something went wrong :-( Please try again later.', 2)
      finally
        log.return()
    onReady: ->
      try
        log.enter 'my-account.onReady'
      finally
        log.return()
  }
