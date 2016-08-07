# rename 'css_' to 'attr_'
class Unit
  constructor: (unit) ->
    @_unit = unit
    @id = unit['@id']
    @attr_id = "unit-#{@id}"
    @x = unit['@x']
    @y = unit['@y']
    @type = unit['@type']
    @dmg = unit['@dmg']
    @def = unit['@def']

  # to call after unit initialization
  init: () ->
    return

class Company extends Unit
  constructor: (unit) ->
    super unit
    @title = unit['@user_name'] + '(' + unit['@hp'] + ')'

class PlayerCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-hero'
    @squads = unit['@squads']
    @hp = unit['@hp']
    @ap = unit['@ap']

class OtherPlayerCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'other-player-hero'

class BotCompany extends Company
  constructor: (unit) ->
    super unit
    @css_class = 'bot-hero'

class GreenOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'green-orb'
    @title = unit['@hp']
    if unit['@hp'] < 50
      @css_class += ' orb-sm'
    else if unit['@hp'] < 100
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

class BlackOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'black-orb'
    @title = unit['@hp']
    if unit['@hp'] < 500
      @css_class += ' orb-sm'
    else if unit['@hp'] < 700
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

class Town extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'town'
    @title = unit['@user_name'] + ' Town'

class PlayerTown extends Town
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-town'
    @adj_companies = unit['@adj_companies']

  init: () ->
    App.init_town_buildings(@_unit['@buildings'])
    App.controls.init_town_controls(@_unit['@actions'])
    App.controls.init_town_workers(@_unit['@workers'], @_unit['@id'], @_unit['@x'], @_unit['@y'])
    App.controls.init_town_inventory(@_unit['@inventory'])

class OtherPlayerTown extends Town
  constructor: (unit) ->
    super unit

UnitFactory = (unit_hash, user_id) ->
  throw new Error 'Unit is not set on map' if !unit_hash['@x']? || !unit_hash['@y']?
  if unit_hash?
    switch unit_hash['@type']
      when "company"
        if unit_hash['@user_id']
          if unit_hash['@user_id'] == user_id
            unit = new PlayerCompany unit_hash
          else if unit_hash['@user_name'].search('bot') != -1 then unit = new BotCompany unit_hash
          else unit = new OtherPlayerCompany unit_hash
      when "orb" then unit = new GreenOrb unit_hash
      when "black_orb" then unit = new BlackOrb unit_hash
      when "town"
        if unit_hash['@user_id']
          if unit_hash['@user_id'] == user_id
            unit = new PlayerTown unit_hash
          else
            unit = new OtherPlayerTown unit_hash
      else throw new Error 'Unit have no type'
  unit

window.UnitFactory = UnitFactory
