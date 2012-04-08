XHProf = require("xhprof")
Backbone = require("backbone")
_ = require("underscore")

SummaryView = Backbone.View.extend {
  el: 'section',

  events: {
    "click .sort" : "toggleSort"
    "click .sort" : "toggleSort"
    "click #reset" : "resetRun"
    "dragover" : "handleDragover"
    "ondrop" : "handleDrop"
    "drop" : "handleDrop"
  }

  initialize: ->
    @model.bind 'change', @render, @

  toggleSort: (e) ->
    id = $(e.currentTarget).attr('id')
    @model.toggleSort id

  render: ->
    current_run = localStorage.getItem 'xhprof:current_run'
    el = $(@el)
    if cache = current_run and JSON.parse(current_run)
      @xhprof = new XHProf cache.data
      el.html @renderSummary(@xhprof)
      el.removeAttr("id") if el.attr("id") is "drop-area"
    else
      el.attr("id", "drop-area")
      el.html('Drop an XHProf file onto this space!')

  renderSummary: (@xhprof) ->
    xhprof_data = @xhprof.getFlattenedData()
    totals = {}
    for metric, total of @xhprof.getTotals()
      totals[metric] = number_format(total)

    # Render eco template for runs summary.
    summary_template = require("views/xhprof/summary")
    summary = summary_template(totals)

    sort = @model.get('sort')
    xhprof_sorted = _.sortBy(xhprof_data, (val, key, object) ->
      -val[sort]
    )

    # Render eco template for runs table.
    runs_template = require("views/xhprof/runs")
    runs = runs_template {
      symbols: xhprof_sorted[0..50]
      per: (metric, name) => @xhprof.getPercentage(metric, name)
    }

    buttons_template = require("views/xhprof/buttons")
    buttons = buttons_template({})

    buttons + summary + runs

  resetRun: ->
    localStorage.removeItem "xhprof:current_run"
    @render()

  handleDragover: (event) ->
    event.stopPropagation()
    event.preventDefault()

  handleDrop: (event) ->
    event.stopPropagation()
    event.preventDefault()
    files = event.originalEvent.dataTransfer.files
    @handleFiles files
    #, false
  handleFiles: (files) ->
    file = files[0]

    reader = new FileReader()

    # init the reader event handlers
    reader.onloadend = (evt) => @handleReaderLoadEnd(evt, file)

    # begin the read operation
    reader.readAsText(file)

  handleReaderProgress: (evt) ->
    if (evt.lengthComputable)
      loaded = (evt.loaded / evt.total)

      $("#progressbar").progressbar({ value: loaded * 100 })

  handleReaderLoadEnd: (evt, file) ->
    # Get the raw serialized array from the file dropped.
    file_contents = evt.target.result

    [run_id, namespace] = file.name.split(".")

    # Unserialize the data and flatten the dag into per symbol stats.
    xhprof_obj = unserialize(file_contents)
    @xhprof = new XHProf(xhprof_obj)
    cache = {
      run_id: run_id
      namespace: namespace
      data: xhprof_obj
    }
    localStorage.setItem "xhprof:current_run", JSON.stringify(cache)

    @render()
}

module.exports = SummaryView
