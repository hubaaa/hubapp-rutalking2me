log = new ObjectLogger 'Accounts', 'debug'

Accounts.onLogin (data)->
  try
    log.enter 'onLogin', data
  finally
    log.return()
