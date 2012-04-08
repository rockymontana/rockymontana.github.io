Backbone = require("backbone")

XHProfRun = Backbone.Model.extend {
  defaults: () ->
    return {
      sort:  'wt',
    }

  toggleSort: (param) ->
    @set {sort: param}
}

module.exports = XHProfRun
