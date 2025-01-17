
if not minetest.global_exists("trash") then trash = {} end
trash.modpath = minetest.get_modpath("trash")

-- XP loss for trashing stuff is 1 per item, multiplied by this.
local TRASH_XP_MOD = 0.75

function trash.get_listname()
	return "detached:trash", "main"
end

function trash.get_iconname()
	return "trash_trash_icon.png"
end

function trash.allow_put(inv, listname, index, stack, player)
	if passport.is_passport(stack:get_name()) then
		return 0
	end

	-- Don't allow minegeld to be trashed.
	if minetest.get_item_group(stack:get_name(), "minegeld") ~= 0 then
		return 0
	end

	-- Don't allow safes to be trashed.
	if safe.is_safe_name(stack:get_name()) then
		return 0
	end

	local stack_count = stack:get_count()

	-- Do not allow trashing of tools that have gained rank.
	if toolranks.get_tool_level(stack) > 1 then
		return 0
	end

	-- Do not allow trashing of items with engraved names.
	if engraver.item_has_custom_description(stack) then
		return 0
	end

	return stack_count
end

function trash.on_put(inv, to_list, to_index, stack, player)
	local stack = inv:get_stack(to_list, to_index)

	inv:set_stack(to_list, to_index, ItemStack(nil))

	if player and player:is_player() then
		local pos = player:get_pos()
		-- Play a trash sound. Let other players hear it.
		minetest.sound_play("trash_trash", {
			gain=1.0,
			pos=pos,
			max_hear_distance=16,
		}, true)

		local count = stack:get_count()
		local pname = player:get_player_name()

		-- Discourage use of the trash slot, especially for things like mass cobble.
		-- I'd much rather see players storing cobble in chests everywhere.
		xp.subtract_xp(pname, "digxp", count * TRASH_XP_MOD)

		minetest.log("action", pname .. " trashes " ..
			"\"" .. stack:get_name() .. " " .. count .. "\"" ..
			" using inventory trash slot.")
	end
end

function trash.on_drop_item(oldstack, newstack, dropper, pos)
	if dropper and dropper:is_player() then
		local pname = dropper:get_player_name()
		local sdef = oldstack:get_definition()
		if sdef and not sdef._xp_zerocost_drop then
			local count = oldstack:get_count()
			local xp_mult = TRASH_XP_MOD
			xp.subtract_xp(pname, "digxp", count * xp_mult)
		end
	end
end

function trash.on_pulverize(pname, param)
	local player = minetest.get_player_by_name(pname)
	if not player then
		minetest.log("error", "Unable to pulverize, no player.")
		minetest.chat_send_player(pname, "# Server: Unable to pulverize, no player.")
		return false
	end

	local wielded_item = player:get_wielded_item()
	if wielded_item:is_empty() then
		minetest.chat_send_player(pname, "# Server: Unable to pulverize, no item in hand.")
		return false
	end

	local count = wielded_item:get_count()

	minetest.log("action", pname .. " pulverized \"" ..
		wielded_item:get_name() .. " " .. count .. "\"")

	xp.subtract_xp(pname, "digxp", count * TRASH_XP_MOD)

	player:set_wielded_item(nil)
	minetest.chat_send_player(pname, "# Server: An item was pulverized.")
	return true
end

if not trash.registered then
	local inv = minetest.create_detached_inventory("trash", {
		allow_put = function(...)
			return trash.allow_put(...)
		end,

		on_put = function(...)
			return trash.on_put(...)
		end,
	})

	minetest.register_on_player_dropitem(function(...) return trash.on_drop_item(...) end)

	inv:set_size("main", 1)

	minetest.override_chatcommand("pulverize", {
		func = function(...) return trash.on_pulverize(...) end,
	})

	local c = "trash:core"
	local f = trash.modpath .. "/init.lua"
	reload.register_file(c, f, false)

	trash.registered = true
end
