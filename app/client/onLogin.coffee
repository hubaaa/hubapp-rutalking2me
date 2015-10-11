log = new ObjectLogger 'Accounts', 'debug'

Accounts.onLogin  ->
  try
    log.enter "onLogin", arguments
    Meteor.subscribe 'trello-account', {
      onStop: (error)->
        try
          log.enter 'onStop'
          if error?
            log.error error
            alertify.error('Oops. Something went wrong :-( Please try again later.', 2)
        finally
          log.return()
      onReady: ->
        try
          log.enter 'onReady'
        finally
          log.return()
    }
  finally
    log.return()
