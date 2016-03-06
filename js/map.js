(function() {
  var Map,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Map = (function() {
    function Map(cell_dim_in_px, block_dim_in_px, block_dim_in_cells, map_dim_in_blocks) {
      var cell_px, mhc, mwc, this_obj;
      this.cell_dim_in_px = cell_dim_in_px;
      this.block_dim_in_px = block_dim_in_px;
      this.block_dim_in_cells = block_dim_in_cells;
      this.map_dim_in_blocks = map_dim_in_blocks;
      mhc = parseInt(localStorage.getItem('map_height_cells'));
      mwc = parseInt(localStorage.getItem('map_width_cells'));
      if (mhc == null) {
        mhc = 13;
        localStorage.setItem('map_height_cells', mhc);
      }
      $('#map_height').val(mhc);
      cell_px = this.cell_dim_in_px;
      this_obj = this;
      $('#map_height').change(function(e) {
        var cells;
        cells = parseInt($(this).val());
        $('#map').height(cell_px * cells);
        localStorage.setItem('map_height_cells', cells);
        return this_obj.centerOnHero('the_hero');
      });
      $('#map_width').change(function(e) {
        var cells;
        cells = parseInt($(this).val());
        $('#map').width(cell_px * cells);
        localStorage.setItem('map_width_cells', cells);
        return this_obj.centerOnHero('the_hero');
      });
      if (mwc == null) {
        mwc = 13;
        localStorage.setItem('map_height_cells', mwc);
      }
      $('#map_width').val(mwc);
      $('#map').height(mhc * this.cell_dim_in_px).width(mwc * this.cell_dim_in_px);
      this.initTooltip();
      this.initDragHandler();
      this.addBlocks();
    }

    Map.prototype.initTooltip = function() {
      return $('#blocks').mousemove(function(e) {});
    };

    Map.prototype.initDragHandler = function() {
      var ee, left, moving, sx, sy, top;
      moving = false;
      sx = 0;
      sy = 0;
      top = 0;
      left = 0;
      ee = 0;
      setInterval(function() {
        var dx, dy;
        if (moving && ee) {
          dx = ee.pageX - sx;
          dy = ee.pageY - sy;
          if (!(indexOf.call([-2, -1, 0, 1, 2], dx) >= 0 || indexOf.call([-2, -1, 0, 1, 2], dy) >= 0)) {
            $('#blocks').css('top', top + dy + 'px').css('left', left + dx + 'px');
          }
          return false;
        }
      }, 123);
      return $('#map').mousemove(function(e) {
        return ee = e;
      }).mousedown(function(e) {
        var pos;
        moving = true;
        sx = e.pageX;
        sy = e.pageY;
        pos = $('#blocks').position();
        top = pos.top;
        return left = pos.left;
      }).mouseup(function() {
        return moving = false;
      });
    };

    Map.prototype.addBlocks = function() {
      var block_x, block_y, i, ref, results;
      results = [];
      for (block_x = i = 0, ref = this.map_dim_in_blocks - 1; 0 <= ref ? i <= ref : i >= ref; block_x = 0 <= ref ? ++i : --i) {
        results.push((function() {
          var j, ref1, results1;
          results1 = [];
          for (block_y = j = 0, ref1 = this.map_dim_in_blocks - 1; 0 <= ref1 ? j <= ref1 : j >= ref1; block_y = 0 <= ref1 ? ++j : --j) {
            results1.push($(document.createElement('div')).attr('id', "block_" + block_x + "_" + block_y).addClass('block').css('background-image', "url(img/bg/bg_" + block_x + "_" + block_y + ".png)").css('left', (block_x * this.block_dim_in_px) + "px").css('top', (block_y * this.block_dim_in_px) + "px").appendTo('#blocks'));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    Map.prototype.addCell = function(x, y) {
      var block_x, block_y, left, top;
      block_x = Math.floor(x / this.block_dim_in_cells);
      block_y = Math.floor(y / this.block_dim_in_cells);
      left = x % 10 * this.cell_dim_in_px;
      top = y % 10 * this.cell_dim_in_px;
      return $(document.createElement('div')).attr('id', "cell_" + x + "_" + y).data('x', x).data('y', y).addClass('cell').css('left', left).css('top', top).appendTo("#block_" + block_x + "_" + block_y);
    };

    Map.prototype.applyDmgTo = function(cell, dmg, type) {
      var d;
      d = $(document.createElement('span'));
      d.html(dmg);
      d.addClass('dmg').addClass('dmg_start').addClass(type + "_dmg_start");
      $(cell).append(d);

      /*
      If you apply it instantly it will fuck you up. I do love timeouts anyway...
       */
      return setTimeout(function() {
        d.addClass('dmg_end').addClass(type + "_dmg_end");
        return setTimeout((function() {
          return d.remove();
        }), 1234);
      }, 123);
    };

    Map.prototype.dmg = function(x, y, dmg, ca_dmg) {
      this.applyDmgTo($("#cell_" + x + "_" + y), dmg, 'def');
      return this.applyDmgTo($('#the_hero').parent(), ca_dmg, 'att');
    };

    Map.prototype.remove_units = function() {
      return $('.unit').remove();
    };

    Map.prototype.centerOnHero = function(unit_id) {
      var bias_left, bias_top, block_pos, cell_pos, left, map, top, unit_jq;
      unit_jq = $("#" + unit_id);
      block_pos = unit_jq.parent().parent().position();
      cell_pos = unit_jq.parent().position();
      map = $("#map");
      bias_top = (map.height() - this.cell_dim_in_px) / 2;
      bias_left = (map.width() - this.cell_dim_in_px) / 2;
      top = block_pos.top + cell_pos.top - bias_top;
      left = block_pos.left + cell_pos.left - bias_left;
      return $('#blocks').css('top', -1 * top + 'px').css('left', -1 * left + 'px');
    };

    Map.prototype.append = function(unit) {
      var cell, cell_sel, o;
      cell_sel = "#cell_" + unit.x + "_" + unit.y;
      cell = $(cell_sel);
      if (cell.length === 0) {
        this.addCell(unit.x, unit.y);
      }
      o = $(document.createElement('div')).addClass('unit').addClass(unit.css_class).appendTo(cell_sel);
      if (unit.id) {
        o.attr('id', unit.id);
        if (unit.id === 'the_hero') {
          this.centerOnHero('the_hero');
        }
      }
      if (unit.title) {
        o.attr('title', unit.title);
      }
      return o;
    };

    return Map;

  })();

  this.Map = Map;

}).call(this);
