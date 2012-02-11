XHProf = require('../app/xhprof.coffee')

xhprof_data = {
  "function_two()=:function_three": {
    "ct": 1
    "wt": 137
    "cpu": 221
    "mu": 952
    "pmu": 0
  }
  "function_one()=:function_two": {
    "ct": 2
    "wt": 6
    "cpu": 9
    "mu": 1480
    "pmu": 0
  }
  "main()=:function_one": {
    "ct": 2
    "wt": 6
    "cpu": 9
    "mu": 1480
    "pmu": 0
  }
  "main()": {
    "ct": 1
    "wt": 1546311
    "cpu": 642577
    "mu": 52600504
    "pmu": 57486368
  }
}

describe "parser", ->
  xhprof = new XHProf(xhprof_data)
  it "should get totals", ->
    totals = xhprof.getTotals()
    expect(totals).toEqual {
     'ct': 6
     'wt': 1546311
     'cpu': 642577
     'mu': 52600504
     'pmu': 57486368
    }
