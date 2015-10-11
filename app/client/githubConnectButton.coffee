log = new ObjectLogger 'Template.githubConnectButton', 'debug'

Template.githubConnectButton.onCreated ->
  try
    log.enter 'onCreated'

    @subscribe 'github-account'

    @vm = new ViewModel 'githubConnectButtonViewModel',
      click: ->
        try
          log.enter 'click'
          if not Meteor.user()?.services?.github?
            Meteor.linkWithGithub { requestPermissions: ['user:email', 'notifications'] }, (error)->
              try
                log.enter 'linkWithGithubCallback'
                if error?
                  log.error error
                  alertify.error('Oops. Something went wrong :-( Please try again later.', 2)
              finally
                log.return()
        finally
          log.return()
  finally
    log.return()

Template.githubConnectButton.onRendered ->
  try
    log.enter 'onRendered'
    @vm.bind(@)
  finally
    log.return()

Template.githubConnectButton.helpers
  username: ->
    try
      log.enter 'username'
      return Meteor.user()?.services?.github?.username
    finally
      log.return()