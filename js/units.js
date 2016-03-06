(function() {
  var BotHero, GreenOrb, Hero, OtherPlayerHero, PlayerHero, Unit, UnitFactory, UnitInfo,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Unit = (function() {
    function Unit(unit) {
      this.x = Math.floor(unit['@pos'] / 1000);
      this.y = unit['@pos'] % 1000;
    }

    return Unit;

  })();

  Hero = (function(superClass) {
    extend(Hero, superClass);

    function Hero(unit) {
      Hero.__super__.constructor.call(this, unit);
      this.title = unit['@user'] + '(' + unit['@hp'] + ')';
    }

    return Hero;

  })(Unit);

  PlayerHero = (function(superClass) {
    extend(PlayerHero, superClass);

    function PlayerHero(unit) {
      PlayerHero.__super__.constructor.call(this, unit);
      this.id = 'the_hero';
      this.css_class = 'player_hero';
    }

    return PlayerHero;

  })(Hero);

  OtherPlayerHero = (function(superClass) {
    extend(OtherPlayerHero, superClass);

    function OtherPlayerHero(unit) {
      OtherPlayerHero.__super__.constructor.call(this, unit);
      this.css_class = 'other_player_hero';
    }

    return OtherPlayerHero;

  })(Hero);

  BotHero = (function(superClass) {
    extend(BotHero, superClass);

    function BotHero(unit) {
      BotHero.__super__.constructor.call(this, unit);
      this.css_class = 'bot_hero';
    }

    return BotHero;

  })(Hero);

  GreenOrb = (function(superClass) {
    extend(GreenOrb, superClass);

    function GreenOrb(unit) {
      GreenOrb.__super__.constructor.call(this, unit);
      this.css_class = 'green_orb';
      this.title = unit['@hp'];
      if (unit['@hp'] < 50) {
        this.css_class += ' orb-sm';
      } else if (unit['@hp'] < 100) {
        this.css_class += ' orb-md';
      } else {
        this.css_class += ' orb';
      }
    }

    return GreenOrb;

  })(Unit);

  UnitFactory = function(unit_hash, user_id) {
    var unit;
    if (unit_hash != null) {
      switch (unit_hash.type) {
        case "PlayerHero":
          if (unit_hash['@user']) {
            if (unit_hash['@user'] === user_id) {
              unit = new PlayerHero(unit_hash);
              UnitInfo(unit_hash);
            } else if (unit_hash['@user'].search('bot') !== -1) {
              unit = new BotHero(unit_hash);
            } else {
              unit = new OtherPlayerHero(unit_hash);
            }
          }
          break;
        case "GreenOrb":
          unit = new GreenOrb(unit_hash);
          break;
        default:
          throw new Error('Unit have no type');
      }
    }
    return unit;
  };

  window.UnitFactory = UnitFactory;

  UnitInfo = function(unit) {
    $('#player-name-info').html(unit['@user']);
    $('#hp-info').html(unit['@hp']);
    $('#x-info').html(unit['@x']);
    return $('#y-info').html(unit['@y']);
  };

}).call(this);
