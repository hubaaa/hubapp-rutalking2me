log = new ObjectLogger('hubaaa.GitHubEndpointPuller', 'debug')

githubEndpointPulls = new Mongo.Collection "githubEndpointPulls"
githubEndpointPulls._ensureIndex { 'username': 1 }, { unique: true }
githubEndpointPulls._ensureIndex { last_pulled: 1 }

class hubaaa.GitHubEndpointPuller extends hubaaa.EndpointPuller

  ###
  @param @endpoint - Absolute URL to endpoint
  @httpOptions - Passed as is to meteor's HTTP.get
  @pullOptions - Pull specific options:
  ###
  constructor: (@user, jsonPipeOptions = {})->
    try
      log.enter('constructor', arguments)

      expect(@user?).to.be.true
      expect(@user.services.github.username).to.be.ok
      expect(@user.services.github.accessToken).to.be.ok

      @username = @user.services.github.username
      @accessToken = @user.services.github.accessToken

      endpoint = "https://api.github.com/notifications"

      httpOptions =
        headers:
          "Authorization": "token #{@accessToken}"
          "Accept": "application/vnd.github.v3+json"
          "User-Agent": EasyMeteorSettings.getRequiredSetting('serviceConfigurations.github.appName')
          "query": "participating=true"

      jsonPipeOptions =
        filter: @filter
        transform: @transform
        process: @process

      super(endpoint, httpOptions, sendIfModifiedSinceHeader: true, jsonPipeOptions)
    finally
      log.return()


  start: =>
    try
      log.enter 'start'
      @pull()
    finally
      log.return()


  stop: =>
    try
      log.enter 'stop'
      # This is the EndpointPuller pull timeout
      if @pullTimer?
        try
          Meteor.clearTimeout @pullTimer
        catch ex
          log.error ex
        delete @pullTimer
    finally
      log.return()


# Only thing that passes through are new issues in the user's
# personal repos, and where a vacation auto-response has not been posted yet.
# @TODO:
# 1. Support issue comments
# 2. Support pull requests and pull request comments
# 3. Only auto-responding if actually on vacation
  filter: (context, notification)=>
    try
      log.fineEnter('filter', notification)
      expect(notification.reason).to.be.ok

      log.debug notification

      return false if notification.reason isnt "mention"
      return false if notification.unread isnt true

      return true
    finally
      log.fineReturn()

  transform: (context, notification)=>
    try
      log.enter('transform', notification)

      thread =
        repository:
          html_url: notification.repository.html_url
        subject: notification.subject
      # Some fields we pick for debugging purposes only
      apiUrl = notification.subject.url
      if notification.subject.type is 'Issue'
        issueNumber = apiUrl.substr( apiUrl.lastIndexOf('/') + 1 )
        thread.subject.html_url = thread.repository.html_url + "/issues/#{issueNumber}"
      else if notification.subject.type is 'PullRequest'
        pullNumber = apiUrl.substr( apiUrl.lastIndexOf('/') + 1 )
        thread.subject.html_url = thread.repository.html_url + "/pull/#{pullNumber}"
      return thread
    finally
      log.return()

  process: (context, notification, thread)=>
    try
      log.enter('process')
      expect(notification).to.be.ok
      expect(thread).to.be.ok
      expect(@user.profile.name).to.be.ok
      expect(@user.services.slack.accessToken).to.be.ok

      return if not thread.subject.html_url?

      response = SlackAPI.chat.postMessage @user.services.slack.accessToken,
        "@#{@user.profile.name}",
        "You were mentioned in '#{thread.subject.title}' at #{thread.subject.html_url}",
        { }

      log.info response

      return response
    finally
      log.return()
