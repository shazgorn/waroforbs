describe "InventoryView", ->
  it "calculating empty slots", ->
    old_inventory =
      gold: 0
      wood: 0
      stone: 0
      settlers: 0
    new_inventory =
      gold: 1
      wood: 0
      stone: 0
      settlers: 0
    empty_inventory =
      gold: 0
      wood: 0
      stone: 0
      settlers: 0

    inventory_view = new InventoryView($(document.createElement('div')), null)
    expect(App.resource_info['gold'].title).toBe('')
    expect(inventory_view.calc_empty_slots_to_hide(empty_inventory)).toBe(0)
    # expect(inventory_view.calc_empty_slots_to_hide(new_inventory)).toBe(1)
    empty_slots_to_hide = inventory_view.calc_empty_slots_to_hide(empty_inventory)
    empty_slots_to_hide = 5
    for f in [empty_slots_to_hide...0]
      console.log(f)
