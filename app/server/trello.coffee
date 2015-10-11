#TODO: Here too, we can do a much better DRY job, and generate publications for all the services we support, at once

log = new ObjectLogger 'Meteor.publish', 'debug'

Meteor.publish 'trello-account', ->
  try
    log.enter 'trello-account', @userId
    return if not @userId?
    cursor =  Meteor.users.find { $and: [ { _id: @userId }, { 'services.trello': { $exists: true } } ] },
      { fields: { 'services.trello.username': 1 } }

    log.debug("user", cursor.fetch())

    return cursor
  finally
    log.return()

