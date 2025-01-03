
-- Use whenever you would use `minetest.registered_nodes' but don't need stairs.
minetest.reg_ns_nodes = {}

if not minetest.global_exists("falldamage") then falldamage = {} end
falldamage.modpath = minetest.get_modpath("falldamage")
dofile(falldamage.modpath .. "/tilesheet.lua")
dofile(falldamage.modpath .. "/rangecheck.lua")
dofile(falldamage.modpath .. "/liquidinteraction.lua")



local on_drop_callbacks = {}
local function call_on_drop_callbacks(oldstack, newstack, dropper, pos)
	local n = #on_drop_callbacks
	for k = 1, n do
		local cb = on_drop_callbacks[k]
		cb(oldstack, newstack, dropper, pos)
	end
end
function minetest.register_on_player_dropitem(func)
	assert(type(func) == "function")
	on_drop_callbacks[#on_drop_callbacks + 1] = func
end
local function override_on_drop(def)
	local old_on_drop = def.on_drop or minetest.item_drop

	function def.on_drop(itemstack, dropper, pos)
		local oldstack = ItemStack(itemstack)
		local oldcount = oldstack:get_count()
		local newstack = old_on_drop(itemstack, dropper, pos)

		if not newstack then
			-- If we reach here, we cannot do anything!
			-- 'minetest.item_drop' can return nil if adding object to world fails.
			return
		end

		local newcount = newstack:get_count()
		if newcount < oldcount then
			call_on_drop_callbacks(oldstack, newstack, dropper, pos)
		end

		return newstack
	end
end



local function copy_pointed_thing(pointed_thing)
	return {
		type  = pointed_thing.type,
		above = vector.new(pointed_thing.above),
		under = vector.new(pointed_thing.under),
		ref   = pointed_thing.ref,
	}
end



local old_register_craftitem = minetest.register_craftitem
function minetest.register_craftitem(name, def2)
	local def = table.copy(def2)

	if type(def.stack_max) == "nil" then
		def.stack_max = 64
	end
	if type(def.inventory_image) == "string" then
		def.inventory_image = image.get(def.inventory_image)
	end
	if type(def.wield_image) == "string" then
		def.wield_image = image.get(def.wield_image)
	end

	override_on_drop(def)

	return old_register_craftitem(name, def)
end



local old_register_tool = minetest.register_tool
function minetest.register_tool(name, def)
	local ndef = table.copy(def)
	if ndef.tool_capabilities then
		local rangemod = (ndef.tool_capabilities.range_modifier or 1)
		local defrange = 4

		-- Swords have less range, should make fighting the mobs a bit more challenging.
		if name:find("sword") then
			-- Note: not really a good idea. Leave at 4.
			-- Too many player expectations would break.
			defrange = 4
		end

		-- Get the damage groups from centralized source.
		ndef.tool_capabilities.damage_groups =
			sysdmg.get_damage_groups_for(name, ndef.tool_capabilities.damage_groups)

		ndef.range = (ndef.range or defrange) * rangemod
	end

	override_on_drop(ndef)

	return old_register_tool(name, ndef)
end



-- Override minetest.register_node so that we can modify the falling damage GLOBALLY.
-- And fix stuff the engine no longer takes care of for us.
local old_register_node = minetest.register_node;
local function register_node(name, def2)
	local def = table.copy(def2)

	-- Make sure groups table exists (even if its empty).
	if not def.groups then def.groups = {} end

	if not def.groups.fall_damage_add_percent then
		def.groups.fall_damage_add_percent = 30
	end

	-- Any nodes dealing env damage get added to the 'env_damage' group.
	if def.damage_per_second ~= 0 then
		def.groups.env_damage = 1
	end

	-- Any airlike drawtype nodes get added to the 'airlike' group.
	-- Note: this includes any airlike drawtype nodes from the maptools files.
	if def.drawtype == "airlike" then
		def.groups.airlike = 1
	end

	-- Compatibility code, used to be in Minetest core but since 5.9.0 was removed.
	if def.drawtype == "nodebox" or def.drawtype == "mesh" then
		if type(def.use_texture_alpha) == "nil" then
			def.use_texture_alpha = "clip"
		end
	end

	-- Any nodes with "brick" or "block" in the name have dig prediction disabled.
	-- This makes them "glitch proof" to normal clients.
	if name:find("brick$") or name:find("block$") then
		if not def.node_dig_prediction then
			def.node_dig_prediction = ""
		end
	end

	if not def.movement_speed_multiplier then
		if def.drawtype == "nodebox" or def.drawtype == "mesh" then
			if not string.find(name, "^vines:") then
				def.movement_speed_multiplier = default.SLOW_SPEED
			end
		end
	end

	if type(def.stack_max) == "nil" then
		def.stack_max = 64
	end

	-- Every node that overrides 'on_punch' must have its 'on_punch'
	-- handler wrapped in one that calls punchnode callbacks.
	if def.on_punch then
		local on_punch = def.on_punch
		def.on_punch = function(pos, node, puncher, pointed_thing)
			-- Run script hook
			for _, callback in ipairs(core.registered_on_punchnodes) do
				-- Copy pos and node because callback can modify them
				local pos_copy = vector.new(pos)
				local node_copy = {name=node.name, param1=node.param1, param2=node.param2}
				local pointed_thing_copy = pointed_thing and copy_pointed_thing(pointed_thing) or nil
				callback(pos_copy, node_copy, puncher, pointed_thing_copy)
			end
			return on_punch(pos, node, puncher, pointed_thing)
		end
	end

	-- If the node defines 'can_dig' then we must create a wrapper
	-- that calls 'minetest.is_protected' if that function returns false.
	-- This is because the engine will skip the protection check in core.
	if def.can_dig then
		local can_dig = def.can_dig
		function def.can_dig(pos, digger)
			local result = can_dig(pos, digger) -- Call old function.
			if not result then
				-- Old function returned false, we must check protection (because MT core will not do this).
				local pname = ""
				if digger and digger:is_player() then
					pname = digger:get_player_name()
				end
				if minetest.test_protection(pos, pname) then
					protector.punish_player(pos, pname)
				end
			end
			return result
			-- If the old function returned true (i.e., player can dig)
			-- the MT core will follow up with a protection check.
		end
	end

	override_on_drop(def)

	if type(def.tiles) == "table" then
		for k, v in pairs(def.tiles) do
			if type(v) == "string" then
				def.tiles[k] = image.get(v)
			end
		end
	end
	if type(def.inventory_image) == "string" then
		def.inventory_image = image.get(def.inventory_image)
	end
	if type(def.wield_image) == "string" then
		def.wield_image = image.get(def.wield_image)
	end

	if def.groups.notify_construct and def.groups.notify_construct > 0 then
		if def.on_construct then
			local old = def.on_construct
			def.on_construct = function(pos)
				notify.notify_adjacent(pos)
				return old(pos)
			end
		else
			def.on_construct = function(pos)
				notify.notify_adjacent(pos)
			end
		end
	end
  
	if def.groups.notify_destruct and def.groups.notify_destruct > 0 then
		if def.on_destruct then
			local old = def.on_destruct
			def.on_destruct = function(pos)
				notify.notify_adjacent(pos)
				return old(pos)
			end
		else
			def.on_destruct = function(pos)
				notify.notify_adjacent(pos)
			end
		end
	end

	-- For nodes in the falling group, the default behavior is to fall when
	-- struck by any arrow.
	if def.groups.falling_node and def.groups.falling_node ~= 0 then
		local old_on_arrow_impact = def.on_arrow_impact
		function def.on_arrow_impact(under, above, entity, intersection_point)
			if old_on_arrow_impact then
				old_on_arrow_impact(under, above, entity, intersection_point)
			end

			if not minetest.test_protection(under, "") then
				core.spawn_falling_node(under)
			end
		end
	end

	falldamage.apply_range_checks(def)
	falldamage.apply_liquid_interaction_mod(name, def)
	if def.sounds then
		assert(type(def.sounds) == "table", name)
	end
	old_register_node(name, def)

	-- Populate table of all non-stair nodes.
	if not name:find("^%:?stairs:") then
		local first, second = name:match("^%:?([%w_]+)%:([%w_]+)$")
		local n = first .. ":" .. second
		local def = minetest.registered_nodes[n]
		minetest.reg_ns_nodes[n] = def
	end
end
minetest.register_node = register_node

-- Make sure our custom node tables contain entries for air and ignore.
minetest.reg_ns_nodes["air"] = minetest.registered_nodes["air"]
minetest.reg_ns_nodes["ignore"] = minetest.registered_nodes["ignore"]
