
-- Chance to explode after death.
local function after_dm_die(self, pos)
	if math.random(1, 100) == 1 then
		local def = {
			radius = 5,
			damage_radius = 25,
			ignore_protection = false,
			disable_drops = false,
			ignore_on_blast = false,
		}
		tnt.boom(pos, def)
	end
end

mobs.register_mob("dm:dm", {
	description = "Dungeon Master",
	type = "monster",
	passive = false,
	damage = 4*500,
	damage_group = "crush",
	armor_level = 3,
	attack_type = "dogshoot",
	specific_allies = {
		["griefer:griefer"] = true,
		["griefer:elite_griefer"] = true,
	},
	dogshoot_switch = 1,
	dogshoot_count_max = 10,
	reach = 3,
	shoot_interval = 2.5,
	attack_animals = true,
	arrow = "dm:fireball",
	shoot_offset = 1,
	hp_min = 12*500,
	hp_max = 32*500,
	armor = 60,
	collisionbox = {-0.7, -1, -0.7, 0.7, 1.6, 0.7},
	visual = "mesh",
	mesh = "dm_dm.b3d",
	textures = {
		{"dm_dm1.png"},
		{"dm_dm2.png"},
		{"dm_dm3.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "dm_dm",
		shoot_attack = "dm_fireball",
		death = "dm_die",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 30,
	drops = {
		{name = "default:mese_crystal_fragment", chance = 1, min = 1, max = 5},
		{name = "default:diamond", chance = 5, min = 1, max = 5},
		{name = "default:mese_crystal", chance = 4, min = 1, max = 3},
		{name = "default:diamondblock", chance = 30, min = 1, max = 3},
		{name = "default:mese", chance = 30, min = 1, max = 4},
	},
	water_damage = 5*500,
	lava_damage = 1*500,
	light_damage = 0,
	fear_height = 3,
	animation = {
		stand_start = 0,
		stand_end = 19,
		walk_start = 20,
		walk_end = 35,
		punch_start = 36,
		punch_end = 48,
		shoot_start = 36,
		shoot_end = 48,
		speed_normal = 15,
		speed_run = 15,
	},
  makes_bones_in_lava = false,
  after_die = after_dm_die,
})



mobs.register_arrow("dm:fireball", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"dm_fireball.png"},
	velocity = 8,

	-- Direct hit, no fire ... just plenty of pain.
	hit_player = function(self, player)
		armor.notify_punch_reason({reason="fireball"})
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fireball = 8*500},
		}, nil)
	end,

	hit_mob = function(self, player)
		local puncher

		if self.owner_obj and self.owner_obj:get_pos() then
			puncher = self.owner_obj
		else
			puncher = self.object
		end

		player:punch(puncher, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fireball = 8*500},
		}, nil)
	end,

	-- Node hit, bursts into flame.
	hit_node = function(self, pos, nodename)
		-- Call 'on_arrow_impact' if node defines it.
		local ndef = minetest.registered_nodes[nodename]
		if ndef.on_arrow_impact then
			ndef.on_arrow_impact(pos, pos, self.object, nil)
		end

		-- The tnt explosion function respects protection perfectly (MustTest).
		tnt.boom(pos, {
			radius = 2,
			ignore_protection = false,
			ignore_on_blast = false,
			damage_radius = 3,
			disable_drops = true,
			mob = "dm:dm", -- Launched by this mob type. Thus blast will not damage mobs of this type.
		})
	end
})



mobs.register_egg("dm:dm", "Dungeon Master", "fire_basic_flame.png", 1, true)



mobs.alias_mob("mobs:dungeon_master",           "dm:dm")
mobs.alias_mob("mobs_monster:dungeon_master",   "dm:dm")
