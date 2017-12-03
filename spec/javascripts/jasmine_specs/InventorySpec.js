describe("InventoryView", function() {
  return it("calculating empty slots", function() {
    var empty_inventory, empty_slots_to_hide, f, i, inventory_view, new_inventory, old_inventory, ref, results;
    old_inventory = {
      gold: 0,
      wood: 0,
      stone: 0,
      settlers: 0
    };
    new_inventory = {
      gold: 1,
      wood: 0,
      stone: 0,
      settlers: 0
    };
    empty_inventory = {
      gold: 0,
      wood: 0,
      stone: 0,
      settlers: 0
    };
    inventory_view = new InventoryView($(document.createElement('div')), null);
    expect(App.resource_info['gold'].title).toBe('');
    expect(inventory_view.calc_empty_slots_to_hide(empty_inventory)).toBe(0);
    // expect(inventory_view.calc_empty_slots_to_hide(new_inventory)).toBe(1)
    empty_slots_to_hide = inventory_view.calc_empty_slots_to_hide(empty_inventory);
    empty_slots_to_hide = 5;
    results = [];
    for (f = i = ref = empty_slots_to_hide; ref <= 0 ? i < 0 : i > 0; f = ref <= 0 ? ++i : --i) {
      results.push(console.log(f));
    }
    return results;
  });
});
