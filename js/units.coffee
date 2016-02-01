class Unit
  constructor: (unit) ->
    @x = unit['@pos'] // 1000
    @y = unit['@pos'] % 1000

class Hero extends Unit
  constructor: (unit) ->
    super unit
    @title = unit['@user'] + '(' + unit['@hp'] + ')'

class PlayerHero extends Hero
  constructor: (unit) ->
    super unit
    @id = 'the_hero'
    @css_class = 'player_hero'

class OtherPlayerHero extends Hero
  constructor: (unit) ->
    super unit
    @css_class = 'other_player_hero'

class BotHero extends Hero
  constructor: (unit) ->
    super unit
    @css_class = 'bot_hero'

class GreenOrb extends Unit
  constructor: (unit) ->
    super unit
    @css_class = 'green_orb'
    @title = unit['@hp']
    if unit['@hp'] < 50
      @css_class += ' orb-sm'
    else if unit['@hp'] < 100
      @css_class += ' orb-md'
    else
      @css_class += ' orb'

UnitFactory = (unit_hash, user_id) ->
  if unit_hash?
    switch unit_hash.type
      when "PlayerHero"
        if unit_hash['@user']
          if unit_hash['@user'] == user_id then unit = new PlayerHero unit_hash
          else if unit_hash['@user'].search('bot') != -1 then unit = new BotHero unit_hash
          else unit = new OtherPlayerHero unit_hash
      when "GreenOrb" then unit = new GreenOrb unit_hash
      else throw new Error 'Unit have no type'
  unit

window.UnitFactory = UnitFactory
