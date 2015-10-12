FlowRouter.route '/',
  triggersEnter: [
    (context, redirect)->
      if Meteor.userId()
        redirect("/configure")
  ]
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
