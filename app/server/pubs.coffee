log = new ObjectLogger 'Meteor.publish', 'debug'

Meteor.publish 'my-account', ->
  try
    log.enter 'my-account'
    return if not @userId?
    return Meteor.users.find { _id: @userId }, {
      fields:
        'profile': 1
        'services.slack.user': 1
        'services.trello.username': 1
        'services.github.username': 1
    }
  finally
    log.return()
