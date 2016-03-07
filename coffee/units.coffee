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
    @id = 'hero_' + unit['@id']
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
          if unit_hash['@user'] == user_id
                unit = new PlayerHero unit_hash
                UnitInfo unit_hash
          else if unit_hash['@user'].search('bot') != -1 then unit = new BotHero unit_hash
          else unit = new OtherPlayerHero unit_hash
      when "GreenOrb" then unit = new GreenOrb unit_hash
      else throw new Error 'Unit have no type'
  unit

window.UnitFactory = UnitFactory

# there will be unit info factory placed in separate file, each unit type will
# have it`s own fields i think
UnitInfo = (unit) ->
        $('#unit-id-info').html(unit['@id'])
        $('#player-name-info').html(unit['@user'])
        $('#hp-info').html(unit['@hp'])
        $('#x-info').html(unit['@x'])
        $('#y-info').html(unit['@y'])
