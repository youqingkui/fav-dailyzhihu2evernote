email = require('./email')()


txErr = (infoJson, cb) ->
  console.error infoJson.err

  logInfo = ""
  for k, v of infoJson
    logInfo +=  k + ": " + v + "\n"

  emailBody = (logInfo)
  email.send(emailBody, to=null, subj='HI ACE DAILY')

  if cb
    return cb(infoJson.err)

module.exports = txErr


