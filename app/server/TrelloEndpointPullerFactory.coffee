# TODO: Here too, DRY - a single factory, configurable by service name

log = new ObjectLogger('hubaaa.TrelloEndpointPullerFactory', 'debug')

# TODO: This is a naive implementation. While still in non-clustered app mode,
# we should have a "cron" job that checks every 5 minutes for:
# - GitHub vacation responses in the db that are about to begin in the next 5 minutes
# - GitHub vacation responses that have been stopped and remove them from @pullers.
# TODO: Deal with timezones, if needed
class hubaaa.TrelloEndpointPullerFactory

  instance = null

  @get: ->
    instance ?= new hubaaa.TrelloEndpointPullerFactory

  constructor: (@users = Meteor.users)->
    try
      log.enter('constructor', arguments)
      expect(@users).to.be.an.instanceof Mongo.Collection
      @pullers = {}
    finally
      log.return()

  init: =>
    try
      log.enter('start')
      users = @users.find( { 'services.trello.accessToken': { $exists: true } } ).fetch()
      for user in users
        expect(user.services.trello.username).to.be.ok
        @pullers[user.services.trello.username] = new hubaaa.TrelloEndpointPuller(user)
        @pullers[user.services.trello.username].start()

      Accounts.onLogin @onLogin
    finally
      log.return()

  onLogin: (login)=>
    try
      log.enter('onLogin')
      expect(login.user).to.be.ok
      return if login.type isnt 'trello'
      expect(login.user.services.trello.username).to.be.ok
      Meteor.defer =>
        @pullers[login.user.services.trello.username] = new hubaaa.TrelloEndpointPuller(login.user)
        @pullers[login.user.services.trello.username].start()
    finally
      log.return()



Meteor.startup ->
  if not process.env.METEOR_TEST_PACKAGES?
    hubaaa.TrelloEndpointPullerFactory.get().init()
