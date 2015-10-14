log = new ObjectLogger 'Template.loginButton', 'debug'

Template.loginButton.onCreated ->
  try
    log.enter 'onCreated'

    @vm = new ViewModel 'loginButtonViewModel',
      login: ->
        try
          log.enter 'login'
          Meteor.loginWithSlack
            requestPermissions: ['incoming-webhook']
        finally
          log.return()
  finally
    log.return()

Template.loginButton.onRendered ->
  try
    log.enter 'onRendered'
    @vm.bind(@)
  finally
    log.return()
