
if not minetest.global_exists("gdac_invis") then gdac_invis = {} end
gdac_invis.modpath = minetest.get_modpath("gdac_invis")
gdac_invis.players = gdac_invis.players or {}



gdac_invis.is_invisible = function(name)
  if gdac_invis.players[name] then
    return true
  else
    return false
  end
end



-- Must be called with the server-internal name of a player.
function gdac_invis.gpn(pname)
	if gdac_invis.is_invisible(pname) then
		return ""
	end
	return rename.gpn(pname)
end



gdac_invis.toggle_invisibility = function(name, param)
	if cloaking.is_cloaked(name) then
		minetest.chat_send_player(name, "# Server: You are currently cloaked! The cloak will be disabled, first.")
		minetest.chat_send_player(name, "# Server: The delay involved in switching invisibility systems may allow you to be briefly seen.")
		cloaking.toggle_cloak(name)
	end

  local player = minetest.get_player_by_name(name)
  if player and player:is_player() then
    if not gdac_invis.players[name] then
      gdac_invis.players[name] = {}

      pova.set_modifier(player, "nametag",
        {color={a=0, r=0, g=0, b=0}, text=""}, "gdac_invis",
        {priority=1000})
      
      pova.set_modifier(player, "properties", {
        visual_size = {x=0, y=0},
        makes_footstep_sound = false,

				-- Cannot be zero-size because otherwise player would fall through cracks.
        --collisionbox = {0},
				--selectionbox = {0},

				collide_with_objects = false,
				is_visible = false,
				pointable = false,
				show_on_minimap = false,
      }, "gdac_invis", {priority=1000})

      player:set_observers({})
      
      minetest.chat_send_player(name, "# Server: Administrative cloak enabled.")
    else
      pova.remove_modifier(player, "nametag", "gdac_invis")
      pova.remove_modifier(player, "properties", "gdac_invis")

      player:set_observers(nil)

      gdac_invis.players[name] = nil
      minetest.chat_send_player(name, "# Server: Invisibility cloak disabled.")
    end
  end

  --[[
  local whoseesme = player:get_effective_observers()
  if whoseesme then
    local count = 0
    for k, v in pairs(whoseesme) do
      print(k .. " sees you")
      count = count + 1
    end
    print(count .. " people see you")
  else
    print('all see you')
  end
  --]]

  return true
end



if not gdac_invis.run_once then
  minetest.register_privilege("gdac_invis", {
    description = "Administrative invisibility mode.",
    give_to_singleplayer = false,
  })
  
  minetest.register_chatcommand("invisible", {
    params = "",
    description = "",
    privs = {gdac_invis=true},
    func = function(...)
      return gdac_invis.toggle_invisibility(...)
    end,
  })
  
  minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    gdac_invis.players[name] = nil
  end)
  
  -- Reloadable.
  local file = gdac_invis.modpath .. "/init.lua"
  local name = "gdac_invis:core"
  reload.register_file(name, file, false)
  
  gdac_invis.run_once = true
end


