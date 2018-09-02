
default = default or {}
utility = utility or {}
utility.modpath = minetest.get_modpath("utility")

-- Dummy function.
fireambiance = {}
function fireambiance.on_flame_addremove(pos)
end

function utility.inventory_count_items(inv, listname, itemname)
	local list = inv:get_list(listname)
	local count = 0
	for i = 1, #list, 1 do
		if list[i]:get_name() == itemname then
			count = count + list[i]:get_count()
		end
	end
	return count
end

function utility.get_short_desc(str)
	if string.find(str, "[\n%(]") then
		str = string.sub(str, 1, string.find(str, "[\n%(]")-1)
	end
	str = string.gsub(str, "^%s+", "")
	str = string.gsub(str, "%s+$", "")
	return str
end

dofile(utility.modpath .. "/particle_override.lua")
dofile(utility.modpath .. "/mapsave.lua")

-- Get a player's foot position, given the player's position.
-- Should help compatibility going into 0.5.0 and beyond.
function utility.get_foot_pos(pos)
	return pos
end
function utility.get_middle_pos(pos)
	return vector.add(pos, {x=0, y=1, z=0})
end
function utility.get_head_pos(pos)
	return vector.add(pos, {x=0, y=1.75, z=0})
end

-- Global multipliers for ABMs. Performance setting.
default.ABM_TIMER_MULTIPLIER = 1
default.ABM_CHANCE_MULTIPLIER = 2

-- Global player-movement multiplier values.
default.ROAD_SPEED = 1.3
default.ROAD_SPEED_NETHER = 1.1
default.ROAD_SPEED_CAVERN = 1.15
default.SLOW_SPEED = 0.7
default.SLOW_SPEED_NETHER = 0.85
default.SLOW_SPEED_ICE = 0.85
default.SLOW_SPEED_GRASS = 0.85
default.SLOW_SPEED_PLANTS = 0.55
default.NORM_SPEED = 1.0
default.ROPE_SPEED = 1.1

default.FAST_JUMP = 1.0
default.SLOW_JUMP = 1.0
default.NORM_JUMP = 1.0



function utility.transform_nodebox(nodebox)
	for k, v in ipairs(nodebox) do
		for m, n in ipairs(v) do
			local p = nodebox[k][m]
			p = p / 16
			p = p - 0.5
			nodebox[k][m] = p
		end
	end
	return nodebox
end



-- Public API function. Sort two positions such that the first is always less than the second.
utility.sort_positions = function(p1, p2)
  local pos1 = {x=p1.x, y=p1.y, z=p1.z}
  local pos2 = {x=p2.x, y=p2.y, z=p2.z}
    
  if pos1.x > pos2.x then pos2.x, pos1.x = pos1.x, pos2.x end
  if pos1.y > pos2.y then pos2.y, pos1.y = pos1.y, pos2.y end
  if pos1.z > pos2.z then pos2.z, pos1.z = pos1.z, pos2.z end
    
  return pos1, pos2
end



--
-- optimized helper to put all items in an inventory into a drops list
--

function default.get_inventory_drops(pos, inventory, drops)
  local inv = minetest.get_meta(pos):get_inventory()
  local n = #drops
  for i = 1, inv:get_size(inventory) do
    local stack = inv:get_stack(inventory, i)
    if stack:get_count() > 0 then
      drops[n+1] = stack:to_table()
      n = n + 1
    end
  end
end


--
-- dig upwards
--

function default.dig_up(pos, node, digger)
  if digger == nil then return end
  local np = {x = pos.x, y = pos.y + 1, z = pos.z}
  local nn = minetest.get_node(np)
  if nn.name == node.name then
    minetest.node_dig(np, nn, digger)
  end
end

--
-- Checks if specified volume intersects a protected volume
--

function default.intersects_protection(minp, maxp, player_name, interval)
  -- 'interval' is the largest allowed interval for the 3D lattice of checks

  -- Compute the optimal float step 'd' for each axis so that all corners and
  -- borders are checked. 'd' will be smaller or equal to 'interval'.
  -- Subtracting 1e-4 ensures that the max co-ordinate will be reached by the
  -- for loop (which might otherwise not be the case due to rounding errors).
  local d = {}
  for _, c in pairs({"x", "y", "z"}) do
    if maxp[c] > minp[c] then
      d[c] = (maxp[c] - minp[c]) / math.ceil((maxp[c] - minp[c]) / interval) - 1e-4
    elseif maxp[c] == minp[c] then
      d[c] = 1 -- Any value larger than 0 to avoid division by zero
    else -- maxp[c] < minp[c], print error and treat as protection intersected
      minetest.log("error", "maxp < minp in 'default.intersects_protection()'")
      return true
    end
  end

  for zf = minp.z, maxp.z, d.z do
    local z = math.floor(zf + 0.5)
    for yf = minp.y, maxp.y, d.y do
      local y = math.floor(yf + 0.5)
      for xf = minp.x, maxp.x, d.x do
        local x = math.floor(xf + 0.5)
        if minetest.test_protection({x = x, y = y, z = z}, player_name) then
          return true
        end
      end
    end
  end

  return false
end



default.get_raillike_selection_box = function()
  return {
    type = "fixed",
    -- but how to specify the dimensions for curved and sideways rails?
    fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
  }
end

default.get_raillike_collision_box = function()
  return {
    type = "fixed",
    fixed = {
      {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
    },
  }
end


--
-- Sapling 'on place' function to check protection of node and resulting tree volume
--

function default.sapling_on_place(itemstack, placer, pointed_thing,
		sapling_name, minp_relative, maxp_relative, interval)
	-- Position of sapling
	local pos = pointed_thing.under
	local node = minetest.get_node_or_nil(pos)
	local pdef = node and minetest.reg_ns_nodes[node.name]

	if pdef and pdef.on_rightclick and not placer:get_player_control().sneak then
		return pdef.on_rightclick(pos, node, placer, itemstack, pointed_thing)
	end

	if not pdef or not pdef.buildable_to then
		pos = pointed_thing.above
		node = minetest.get_node_or_nil(pos)
		pdef = node and minetest.reg_ns_nodes[node.name]
		if not pdef or not pdef.buildable_to then
			return itemstack
		end
	end

	local player_name = placer:get_player_name()
	-- Check sapling position for protection
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return itemstack
	end
	-- Check tree volume for protection
	if default.intersects_protection(
			vector.add(pos, vector.add(minp_relative, {x=-1, y=-1, z=-1})),
			vector.add(pos, vector.add(maxp_relative, {x=1, y=1, z=1})),
			player_name,
			interval) then
		minetest.record_protection_violation(pos, player_name)
		-- Print extra information to explain
		minetest.chat_send_player(player_name, "# Server: Tree will intersect protection!")
		return itemstack
	end

	minetest.log("action", player_name .. " places node "
			.. sapling_name .. " at " .. minetest.pos_to_string(pos))

	local take_item = not minetest.setting_getbool("creative_mode")
	local newnode = {name = sapling_name}
	local ndef = minetest.reg_ns_nodes[sapling_name]
	minetest.set_node(pos, newnode)

	-- Run callback
	if ndef and ndef.after_place_node then
		-- Deepcopy place_to and pointed_thing because callback can modify it
		if ndef.after_place_node(table.copy(pos), placer,
				itemstack, table.copy(pointed_thing)) then
			take_item = false
		end
	end

	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		if callback(table.copy(pos), table.copy(newnode),
				placer, table.copy(node or {}),
				itemstack, table.copy(pointed_thing)) then
			take_item = false
		end
	end

	if take_item then
		itemstack:take_item()
	end

	return itemstack
end

--
-- NOTICE: This method is not an official part of the API yet!
-- This method may change in future.
--

function utility.can_interact_with_node(player, pos)
	if player then
		if minetest.check_player_privs(player, "protection_bypass") then
			return true
		end
	else
		return false
	end

	local meta = minetest.get_meta(pos)
  local owner = meta:get_string("owner") or ""

	if owner == "" or owner == player:get_player_name() then
		-- Owner can access the node to any time
		return true
	end

	-- is player wielding the right key?
	local item = player:get_wielded_item()
	if item:get_name() == "default:key" then
		local key_meta = item:get_meta()

		if key_meta:get_string("secret") == "" then
			local key_oldmeta = item:get_metadata()
			if key_oldmeta == "" or not minetest.parse_json(key_oldmeta) then
				return false
			end

			key_meta:set_string("secret", minetest.parse_json(key_oldmeta).secret)
			item:set_metadata("")
		end

		return meta:get_string("key_lock_secret") == key_meta:get_string("secret")
	end

	return false
end
