log = new ObjectLogger 'Accounts', 'debug'

#Template.registerHelper 'absoluteUrl', ->
#  return Meteor.absoluteUrl()

Meteor.startup ->
  alertify.defaults.notifier.position = 'top-right'

Accounts.onLogin ->
  try
    log.enter 'onLogin'
    FlowRouter.go("/configure")
  finally
    log.return()

Meteor.startup ->
  Tracker.autorun ->
    try
      log.enter 'onLoginStatusChanged'
      if not Meteor.userId() and not Meteor.loggingIn()
        FlowRouter.go("/")
    finally
      log.return()

FlowRouter.route '/',
  action: ->
    BlazeLayout.render "mainLayout", content: "home"

FlowRouter.route '/login',
  action: ->
    BlazeLayout.render "mainLayout", content: "login"

FlowRouter.route '/configure',
  action: ->
    BlazeLayout.render "mainLayout", content: "configure"
