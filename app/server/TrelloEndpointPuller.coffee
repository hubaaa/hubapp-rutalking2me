log = new ObjectLogger('TrelloEndpointPuller', 'info')

@trelloEndpointPulls = new Mongo.Collection "trelloEndpointPulls"
trelloEndpointPulls._ensureIndex { 'id': 1 }

class hubaaa.TrelloEndpointPuller extends hubaaa.EndpointPuller


  constructor: (@user, jsonPipeOptions = {})->
    try
      log.enter('constructor', arguments)

      expect(@user?).to.be.true
      expect(@user.services.trello.username).to.be.ok
      expect(@user.services.trello.accessToken).to.be.ok

      @username = @user.services.trello.username
      @accessToken = @user.services.trello.accessToken
      @lastNotificationId = 'null'

      endpoint = "https://api.trello.com/1/members/me/notifications"

      defaultJsonPipeOptions =
        filter: @filter
        transform: @transform
        process: @process
        outputCollection: trelloEndpointPulls

      jsonPipeOptions = _.extend(defaultJsonPipeOptions, jsonPipeOptions)

      httpOptions =
        headers: {}
        params:  # https://developers.trello.com/advanced-reference/member#get-1-members-idmember-or-username-notifications
          key: EasyMeteorSettings.getRequiredSetting('serviceConfigurations.trello.consumerKey')
          token: @accessToken
          read_filter: "unread" #Only unread notification
          filter: "mentionedOnCard" #Only where user is mentioned on card

      pullOptions =
        getUrlParams: @_buildQueryParams

      super(endpoint, httpOptions , pullOptions, jsonPipeOptions)
    finally
      log.return()




  _buildQueryParams: ()=>
    try
      log.enter("_buildQueryParams",)

      lastNotificationId = trelloEndpointPulls.findOne({'user.id': @user.id}, {sort: createdAt:-1})?.id || "null"
      params =
        since: lastNotificationId
      return params


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


  filter: (context, notification)=>
    try
      log.fineEnter('filter', notification)
      log.debug notification
      exists = trelloEndpointPulls.findOne({id: notification.id})?
      return !exists
    finally
      log.fineReturn()


  transform: (context, notification)=>
    try
      log.enter('transform', notification)
      notification.createdAt = new Date(notification.date)
      notification.user = {
        id: @user.id
      }
      return notification
    finally
      log.return()

  process: (context, notification, thread)=>
    try
      log.enter('process')
      expect(@user.services.slack.incoming_webhook.url).to.be.ok
      expect(notification.data.card.name).to.be.ok

      response = HTTP.post @user.services.slack.incoming_webhook.url, {
        data:
          username: 'rutalking2me',
          text: "You were mentioned in the card '#{notification.data.card.name}' at <https://trello.com/c/#{notification.data.card.shortLink}>"
      }
      return {}
    finally
      log.return()
