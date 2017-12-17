class CostObserver
  ##
  # @param {Object} cost
  # @param {string} target
  constructor: (cost, target) ->
    @cost = cost
    @cost_q_el = {}
    @cost_res_el = {}
    @target = target
    for res, q of @cost
      @add_cost(res, q)

  add_cost: (res, q) ->
    @cost_q_el[res] = $(document.createElement('div'))
      .addClass('resource-q')
      .html(q)
    @cost_res_el[res] = $(document.createElement('div'))
      .addClass('resource cost')
      .addClass(res)
      .attr('title', App.resource_info[res].title + ' ' + q)
      .html(@cost_q_el[res])
      .appendTo(@target)

  update: (cost) ->
    for res, q of cost
      unless @cost_q_el[res]
        @add_cost(res, q)
      @cost_q_el[res].html(q)

window.CostObserver = CostObserver
