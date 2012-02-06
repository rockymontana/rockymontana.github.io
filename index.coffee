require("coffee-script")
stitch  = require("stitch")
argv    = process.argv.slice(2)
fs      = require("fs")

package = stitch.createPackage(
  paths: [
    __dirname + "/node_modules/backbone"
    __dirname + "/node_modules/underscore"
    __dirname + "/app"
  ]

  dependencies: [
     __dirname + '/lib/jquery.min.js'
     __dirname + '/lib/jquery-ui/ui/jquery.ui.core.js'
     __dirname + '/lib/UI-TableSorter/js/jquery-ui-tablesorter-1.0.0.js'
     __dirname + '/lib/unserialize.js'
     __dirname + '/lib/number_format.js'
  ]
)

package.compile (err, source) ->
  #fs.writeFile 'package.js', source, (err) ->
  fs.writeFile 'public/application.js', source, (err) ->
    throw err if err
    console.log 'Compiled package.js'
