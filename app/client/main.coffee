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

BlazeLayout.setRoot('body')

FlowRouter.route '/',
  action: ->
    BlazeLayout.render "mainLayout", content: "home"

FlowRouter.route '/login',
  action: ->
    BlazeLayout.render "mainLayout", content: "login"

FlowRouter.route '/configure',

  triggersEnter: [
    (context, redirect)->
      if not Meteor.userId() and not Meteor.loggingIn()
        redirect("/")
  ]

  action: ->
    BlazeLayout.render "mainLayout", content: "configure"
