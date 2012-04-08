Backbone = require("backbone")

SymbolView = Backbone.View.extend {
  el: 'section',

  render: () ->
    symbol_template = require("views/xhprof/symbol_table")
    symbol_template({})
    #  ,

        #seeTheThing: (event) ->
        #event.preventDefault()
        #router.navigate('thing', true)
}

module.exports = SymbolView

