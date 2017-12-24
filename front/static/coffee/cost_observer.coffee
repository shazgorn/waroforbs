class CostObserver
  ##
  # @param {string} target
  # @param {Object} cost
  constructor: (target, cost) ->
    @target = target
    @cost = cost
    @cost_q_el = {}
    @cost_res_el = {}
    @building_cost = $(document.createElement('div'))
      .addClass('card-cost')
      .appendTo(@target)
    for res, q of @cost
      @add_cost(res, q)

  add_cost: (res, q) ->
    @cost_q_el[res] = $(document.createElement('div'))
      .addClass('resource-q')
      .html(q)
    @cost_res_el[res] = $(document.createElement('div'))
      .addClass('resource cost')
      .append(
        $(document.createElement('div'))
          .addClass('resource-ico ' + res)
          .attr('title', App.resource_info[res].title + ' ' + q),
        @cost_q_el[res],
      )
      .appendTo(@building_cost)

  update: (cost) ->
    for res, q of cost
      unless @cost_q_el[res]
        @add_cost(res, q)
      @cost_q_el[res].html(q)

window.CostObserver = CostObserver
