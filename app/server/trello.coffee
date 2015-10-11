#TODO: Here too, we can do a much better DRY job, and generate publications for all the services we support, at once

log = new ObjectLogger 'Meteor.publish', 'debug'

Meteor.publish 'trello-account', ->
  try
    log.enter 'trello-account'
    return if not @userId?
    return Meteor.users.find { $and: [ { _id: @userId }, { 'services.trello': { $exists: true } } ] },
      { fields: { 'services.trello.username': 1 } }
  finally
    log.return()

