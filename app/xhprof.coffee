class XHProf
  constructor: (xhprof_data) ->
    @data = xhprof_data
    @possible_metrics = {
      wt: ["Wall", "microsecs", "walltime"],
      ut: ["User", "microsecs", "user cpu time"],
      st: ["Sys", "microsecs", "system cpu time"],
      cpu: ["Cpu", "microsecs", "cpu time"],
      mu: ["MUse", "bytes", "memory usage"],
      pmu: ["PMUse", "bytes", "peak memory usage"],
      samples: ["Samples", "samples", "cpu time"]
    }
    @overall_totals = {ct: 0, wt: 0, ut: 0, st: 0, cpu: 0, mu: 0, pmu: 0, samples: 0}


  getTotals: ->
    @totals = @data['main()']
    @totals['ct'] = @getCallCount()
    return @totals

  getCallCount: () ->
    call_count = 0
    for symbol, metrics of @data
      call_count += metrics['ct']
    return call_count

  getPercentage: (symbol_value, metric) ->
    switch metric
      when "excl_wt"
        metric = "wt"
      when "excl_cpu"
        metric = "cpu"
      when "excl_mu"
        metric = "mu"
      when "excl_pmu"
        metric = "pmu"

    (100 * (symbol_value / @overall_totals[metric])).toFixed(2)

  getFlattenedData: ->
    @flat_info = @computeFlatInfo() unless @flat_info?
    @flat_info

  # Takes a parent/child function name encoded as
  # "a==>b" and returns array("a", "b").
  # @param {Object} parent_child
  parseParentChild: (parent_child) ->
    ret = parent_child.split "==>"

    # Return if both parent and child are set
    if ret[1]? then ret else [null, ret[0]]

  getMetrics: (xhprof_data) ->
    # get list of valid metrics
    possible_metrics = @possible_metrics

    # return those that are present in the raw data.
    # We'll just look at the root of the subtree for this.
    metrics = []
    for metric, desc of possible_metrics
      metrics.push metric if xhprof_data["main()"][metric]?
    return metrics

  computeInclusiveTimes: (raw_data) ->
    metrics = @getMetrics(raw_data)
    symbol_tab = {}

    # First compute inclusive time for each function and total
    # call count for each function across all parents the
    # function is called from.
    for parent_child, info of raw_data
      [parent, child] = @parseParentChild(parent_child)

      if parent == child
        # XHProf PHP extension should never trigger this situation any more.
        # Recursion is handled in the XHProf PHP extension by giving nested
        # calls a unique recursion-depth appended name (for example, foo@1).
        console.log "Error in Raw Data: parent & child are both: #{parent}"
        return

      if !symbol_tab[child]?
        symbol_tab[child] = {symbol: child, ct: info["ct"]}
        for metric in metrics
          symbol_tab[child][metric] = info[metric]
      else
        # increment call count for this child
        symbol_tab[child]["ct"] += info["ct"]

        # update inclusive times/metric for this child
        for metric in metrics
          symbol_tab[child][metric] += info[metric]

    return symbol_tab

  computeFlatInfo: ->
    metrics = @getMetrics(@data)

    # Compute inclusive times for each function.
    symbol_tab = @computeInclusiveTimes(@data)

    # Total metric value is the metric value for "main()".
    for metric in metrics
      @overall_totals[metric] = symbol_tab["main()"][metric]

    # Initialize exclusive (self) metric value to inclusive metric value to start with.
    # In the same pass, also add up the total number of function calls.
    for symbol, info of symbol_tab
      for metric in metrics
        symbol_tab[symbol]["excl_#{metric}"] = symbol_tab[symbol][metric]

      # Keep track of total number of calls.
      @overall_totals["ct"] += info["ct"]

    return @adjustParentChildInfo(symbol_tab, metrics)

  # Adjust exclusive times by deducting inclusive time of children.
  adjustParentChildInfo: (symbol_tab, metrics) ->
     for parent_child, info of @data
       [parent, child] = @parseParentChild(parent_child)

       if parent?
         for metric in metrics
           # make sure the parent exists hasn't been pruned.
           if symbol_tab[parent]?
             symbol_tab[parent]["excl_#{metric}"] -= info[metric]
     return symbol_tab


module.exports = XHProf
