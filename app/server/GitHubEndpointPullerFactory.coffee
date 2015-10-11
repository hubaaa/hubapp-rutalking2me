log = new ObjectLogger('hubaaa.GitHubEndpointPullerFactory', 'debug')

# TODO: This is a naive implementation. While still in non-clustered app mode,
# we should have a "cron" job that checks every 5 minutes for:
# - GitHub vacation responses in the db that are about to begin in the next 5 minutes
# - GitHub vacation responses that have been stopped and remove them from @pullers.
# TODO: Deal with timezones, if needed
class hubaaa.GitHubEndpointPullerFactory

  instance = null

  @get: ->
    instance ?= new hubaaa.GitHubEndpointPullerFactory

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
      users = @users.find( { 'services.github.accessToken': { $exists: true } } ).fetch()
      for user in users
        expect(user.services.github.username).to.be.ok
        @pullers[user.services.github.username] = new hubaaa.GitHubEndpointPuller(user)
        @pullers[user.services.github.username].start()

      Accounts.onLogin @onLogin
    finally
      log.return()

  onLogin: (login)=>
    try
      log.enter('onLogin')
      expect(login.user).to.be.ok
      return if login.type isnt 'github'
      expect(login.user.services.github.username).to.be.ok
      @pullers[login.user.services.github.username] = new hubaaa.GitHubEndpointPuller(login.user)
      @pullers[login.user.services.github.username].start()
    finally
      log.return()



Meteor.startup ->
  if not process.env.METEOR_TEST_PACKAGES?
    hubaaa.GitHubEndpointPullerFactory.get().init()
