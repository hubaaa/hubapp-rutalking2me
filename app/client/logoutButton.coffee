log = new ObjectLogger 'Template.logoutButton', 'debug'

Template.logoutButton.onCreated ->
  try
    log.enter 'onCreated'

    @vm = new ViewModel 'logoutButtonViewModel',
      logout: ->
        try
          log.enter 'logout'
#          AccountsTemplates.logout()
          Meteor.logout (error)->
            if error?
              alertify.error('Oops. Something went wrong :-( Please try again later.', 2)
        finally
          log.return()
  finally
    log.return()

Template.logoutButton.onRendered ->
  try
    log.enter 'onRendered'
    @vm.bind(@)
  finally
    log.return()
