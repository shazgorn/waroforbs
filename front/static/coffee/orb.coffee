class GreenOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'green-orb'
    @title = @life
    if @life < 50
      @css_class += ' orb-sm'
    else if @life < 100
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

  create_view: () ->
    @view = new GreenOrbView(this)


class BlackOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'black-orb'
    @title = @life
    if @life < 500
      @css_class += ' orb-sm'
    else if @life < 700
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

  create_view: () ->
    if !@dead
      @view = new BlackOrbView(this)

window.GreenOrb = GreenOrb
window.BlackOrb = BlackOrb
