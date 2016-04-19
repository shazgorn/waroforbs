# rename 'css_' to 'attr_'
class Unit
  constructor: (unit) ->
    @id = unit['@id']
    @attr_id = "unit-#{@id}"
    @x = unit['@x']
    @y = unit['@y']
    @type = unit['@type']

class Hero extends Unit
  constructor: (unit) ->
    super unit
    @title = unit['@user_name'] + '(' + unit['@hp'] + ')'

class PlayerHero extends Hero
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-hero'

class OtherPlayerHero extends Hero
  constructor: (unit) ->
    super unit
    @css_class = 'other-player-hero'

class BotHero extends Hero
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

class Town extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'town'
    @title = unit['@user_name'] + ' Town'

class PlayerTown extends Town
  constructor: (unit) ->
    super unit
    @css_class = 'player-unit player-town'
    App.init_town_buildings(unit['@buildings'])
    App.controls.init_town_controls(unit['@actions'])

UnitFactory = (unit_hash, user_id) ->
  if unit_hash?
    switch unit_hash['@type']
      when "hero"
        if unit_hash['@user_id']
          if unit_hash['@user_id'] == user_id
            unit = new PlayerHero unit_hash
          else if unit_hash['@user_name'].search('bot') != -1 then unit = new BotHero unit_hash
          else unit = new OtherPlayerHero unit_hash
      when "orb" then unit = new GreenOrb unit_hash
      when "town"
        if unit_hash['@user_id']
          if unit_hash['@user_id'] == user_id
            unit = new PlayerTown unit_hash
        else
          unit = new Town unit_hash
      else throw new Error 'Unit have no type'
  unit

window.UnitFactory = UnitFactory
