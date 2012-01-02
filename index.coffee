require("coffee-script")
stitch  = require("stitch")
express = require("express")
argv    = process.argv.slice(2)

package = stitch.createPackage(
  # Specify the paths you want Stitch to automatically bundle up
  paths: [
    __dirname + "/app"
  ]

  # Specify your base libraries
  dependencies: [
     __dirname + '/lib/jquery.min.js'
     __dirname + '/lib/jquery-ui/ui/jquery.ui.core.js'
     __dirname + '/lib/UI-TableSorter/js/jquery-ui-tablesorter-1.0.0.js'
     __dirname + '/lib/unserialize.js'
     __dirname + '/lib/number_format.js'
  ]
)
app = express.createServer()

app.configure ->
  app.set "views", __dirname + "/views"
  app.use app.router
  app.use express.static(__dirname + "/public")
  app.get "/application.js", package.createServer()

port = argv[0] or process.env.PORT or 9294
console.log "Starting server on port: #{port}"
app.listen port
