# TODO: We can do a much better DRY work here and have one configurable connect button instead

log = new ObjectLogger 'Template.trelloConnectButton', 'debug'

Template.trelloConnectButton.onCreated ->
  try
    log.enter 'onCreated'

    @subscribe 'trello-account'

    @vm = new ViewModel 'githubConnectButtonViewModel',
      click: ->
        try
          log.enter 'click'
          if not Meteor.user()?.services?.trello?
            Meteor.linkWithTrello { requestPermissions: ['read'] }, (error)->
              try
                log.enter 'linkWithTrelloCallback'
                if error?
                  alertify.error('Oops. Something went wrong :-( Please try again later.', 2)
              finally
                log.return()
        finally
          log.return()
  finally
    log.return()

Template.trelloConnectButton.onRendered ->
  try
    log.enter 'onRendered'
    @vm.bind(@)
  finally
    log.return()

Template.trelloConnectButton.helpers
  username: ->
    try
      log.enter 'username'
      return Meteor.user()?.services?.trello?.username
    finally
      log.return()