log = new ObjectLogger 'Template.slackLoginButton', 'debug'

Template.slackLoginButton.onCreated ->
  try
    log.enter 'onCreated'

    @vm = new ViewModel 'slackLoginButtonViewModel',
      login: ->
        try
          log.enter 'login'
          Meteor.loginWithSlack
            requestPermissions: ['incoming-webhook']
#            requestPermissions: ['identify', 'post']
        finally
          log.return()
  finally
    log.return()

Template.slackLoginButton.onRendered ->
  try
    log.enter 'onRendered'
    @vm.bind(@)
  finally
    log.return()
