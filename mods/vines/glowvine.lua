
-- New Vines for Xen



 minetest.register_node('vine:luminoustreevine', {
	 drawtype = "plantlike",
	 inventory_image = "dvd_luminousvineend.png",
	 weild_image = "dvd_luminousvine.png",
	 description = 'Twilight Vine End',
	 tiles = {'dvd_luminousvineend.png'},
	 paramtype = "light",
	 sunlight_propagates = true, 
	 light_source = 6,
	 paramtype2 = "wallmounted",
	 is_ground_content = false, 
	 walkable = false,
	 climbable = true,
	 groups = {level = 1, snappy=3, oddly_breakable_by_hand=1},
 })
 
  minetest.register_node('vine:luminoustreevineend', {
	 drawtype = "plantlike",
	 inventory_image = "dvd_luminousvine.png",
	 weild_image = "dvd_luminousvine.png",
	 description = 'Twilight Vine',
	 tiles = {'dvd_luminousvine.png'},
	 paramtype = "light",
	 sunlight_propagates = true, 
	 light_source = 6,
	 paramtype2 = "wallmounted",
	 is_ground_content = false, 
	 walkable = false,
	 climbable = true,
	 groups = {level = 1, snappy=3, oddly_breakable_by_hand=1},
 })