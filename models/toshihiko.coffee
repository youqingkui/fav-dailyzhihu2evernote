T = require("toshihiko")

if process.env.NODE_ENV is 'procuct'
  console.log "user proccut dataases"
  toshihiko = new T.Toshihiko process.env.ACE_DB, process.env.ACE_NAME, process.env.ACE_PWD,
    host:process.env.ACE_HOST
else

  toshihiko = new T.Toshihiko("Ace", "root", "", {
    host:'localhost'
  });
  console.log("use localhost databases")

module.exports = toshihiko