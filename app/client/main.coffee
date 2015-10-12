log = new ObjectLogger 'Accounts', 'debug'

getSubdomain = (url)->
  url = url.replace("https://","")
  url = url.replace("http://", "")
  return url.split(".")?[0]

Template.registerHelper 'team', ->
  try
    log.enter 'team'
    return if not Meteor.userId()
    team_url = Meteor.user().profile?.team_url
    return if not team_url?
    return getSubdomain team_url
  finally
    log.return()

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
