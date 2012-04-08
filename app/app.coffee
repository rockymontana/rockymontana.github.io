Backbone = require("backbone")
_ = require("underscore")
SummaryView = require("summary_view")
SymbolView = require("symbol_view")
XHProf = require("xhprof")
XHProfRun = require("xhprof_run")

App =
  init: ->
    xhprof_run = new XHProfRun
    SummaryView = new SummaryView {model: xhprof_run}
    SymbolView = new SymbolView

    Router = Backbone.Router.extend {
      routes: {
        '': 'dropzone'
      },
      dropzone: () ->
        SummaryView.render()
    }

    router = new Router
    Backbone.history.start()

  numberFormat: (number) ->
    # Use number_format from php.js
    number_format(number)


module.exports = App
