log = new ObjectLogger 'Meteor.publish', 'debug'
Meteor.publish 'github-account', ->
  try
    log.enter 'github-account'
    return if not @userId?
    return Meteor.users.find { $and: [ { _id: @userId }, { 'services.github': { $exists: true } } ] },
      { fields: { 'services.github.username': 1 } }
  finally
    log.return()

