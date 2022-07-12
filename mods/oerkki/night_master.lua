
mobs.register_mob("oerkki:night_master", {
	type = "monster",
	description = "Night Master",
	hp_max = 260,
	hp_min = 60,
	collisionbox = {-0.65, -0.4, -0.65, 0.65, 0.4, 0.65},
	visual = "mesh",
	mesh = "moonherontrio.x",
	textures = {
		{"moonherontrio.png"}
	},
	visual_size = {x = 18, y = 18},
	view_range = 40,
	rotate = 270,
	lifetimer = 500,
	floats=1,
	walk_velocity = 3,
	run_velocity = 4,
	fall_speed = 0,
	stepheight = 3,
	sounds = {
		random = "night_master",
		shoot_attack = "dm_fireball",
		distance = 45,
	},
	damage = 10,
	jump = true,
	armor = 60,
	--drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	blood_texture = "nssm_blood.png",
	blood_amount = 50,
	fly = true,
	attack_type = "shoot",
	dogshoot_switch = 1,
	dogshoot_count_max = 10,
	shoot_interval = 5.0,
	arrow = "oerkki:flame_bolt",
	shoot_offset = 1,
	animation = {
		speed_normal = 25,
		speed_run = 35,
		stand_start = 60,
		stand_end = 120,
		walk_start = 20,
		walk_end = 50,
		run_start = 20,
		run_end = 50,
		punch_start = 130,
		punch_end = 160,
	},

	on_die = function(self, pos)

		minetest.add_particlespawner({
			amount=200, --amount
			time=0.1, --time
			minpos={x=pos.x-1, y=pos.y-1, z=pos.z-1}, --minpos
			maxpos={x=pos.x+1, y=pos.y+1, z=pos.z+1}, --maxpos
			minvel={x=-0, y=-0, z=-0}, --minvel
			maxvel={x=1, y=1, z=1}, --maxvel
			minacc={x=-0.5,y=5,z=-0.5}, --minacc
			maxacc={x=0.5,y=5,z=0.5}, --maxacc
			minexptime=0.1, --minexptime
			maxexptime=1, --maxexptime
			minsize=3, --minsize
			maxsize=4, --maxsize
			collisiondetection=false, --collisiondetection
			texture="tnt_smoke.png", --texture
		})

		self.object:remove()

		minetest.add_entity(pos, "oerkki:night_master_2")
	end,
})

mobs.register_mob("oerkki:night_master_2", {
	type = "monster",
	description = "Night Master",
	hp_max = 260,
	hp_min = 60,
	collisionbox = {-0.65, -0.4, -0.65, 0.65, 0.4, 0.65},
	visual = "mesh",
	mesh = "night_master_2.x",
	textures = {
		{"moonherontrio.png"}
	},
	visual_size = {x = 18, y = 18},
	view_range = 40,
	rotate = 270,
	lifetimer = 500,
	floats = 1,
	walk_velocity = 3,
	run_velocity = 4,
	fall_speed = 0,
	stepheight = 3,
	sounds = {
		random = "night_master",
		distance = 45,
	},
	damage = 10,
	jump = true,
	armor = 60,
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	fly = true,
	attack_type = "dogfight",
	animation = {
		speed_normal = 25,
		speed_run = 35,
		stand_start = 60,
		stand_end = 120,
		walk_start = 20,
		walk_end = 50,
		run_start = 20,
		run_end = 50,
		punch_start = 130,
		punch_end = 160,
	},

	on_die = function(self, pos)

		minetest.add_particlespawner({
			amount=200, --amount
			time=0.1, --time
			minpos={x=pos.x-1, y=pos.y-1, z=pos.z-1}, --minpos
			maxpos={x=pos.x+1, y=pos.y+1, z=pos.z+1}, --maxpos
			minvel={x=-0, y=-0, z=-0}, --minvel
			maxvel={x=1, y=1, z=1}, --maxvel
			minacc={x=-0.5,y=5,z=-0.5}, --minacc
			maxacc={x=0.5,y=5,z=0.5}, --maxacc
			minexptime=0.1, --minexptime
			maxexptime=1, --maxexptime
			minsize=3, --minsize
			maxsize=4, --maxsize
			collisiondetection=false, --collisiondetection
			texture="tnt_smoke.png", --texture
		})

		self.object:remove()

		minetest.add_entity(pos, "oerkki:night_master_1")
	end,
})

mobs.register_mob("oerkki:night_master_1", {
	type = "monster",
	description = "Night Master",
	hp_max = 270,
	hp_min = 70,
	collisionbox = {-0.65, -0.4, -0.65, 0.65, 0.4, 0.65},
	visual = "mesh",
	mesh = "night_master_1.x",
	textures = {
		{"moonherontrio.png"}
	},
	visual_size = {x = 18, y = 18},
	view_range = 40,
	rotate = 270,
	lifetimer = 500,
	floats=1,
	walk_velocity = 3,
	run_velocity = 4,
	fall_speed = 0,
	stepheight = 3,
	sounds = {
		random = "night_master",
		distance = 45,
	},
	damage = 12,
	jump = true,
	drops = {
		--{name = "mobs:flame_staff", chance = 1, min = 1, max = 1},
		--{name = "nssm:life_energy", chance = 1, min = 6, max = 7},
		--{name = "nssm:heron_leg", chance = 1, min = 1, max = 1},
		--{name = "nssm:night_feather", chance = 1, min = 1, max = 1},
	},
	armor = 50,
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	fly = true,
	attack_type = "dogfight",
	animation = {
		speed_normal = 25,
		speed_run = 35,
		stand_start = 60,
		stand_end = 120,
		walk_start = 20,
		walk_end = 50,
		run_start = 20,
		run_end = 50,
		punch_start = 130,
		punch_end = 160,
	}
})

mobs.register_arrow("oerkki:flame_bolt", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"dm_fireball.png"},
	velocity = 16,

	-- Direct hit, no fire ... just plenty of pain.
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 2},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	-- Node hit, bursts into flame.
	hit_node = function(self, pos, node)
		-- The tnt explosion function respects protection perfectly (MustTest).
		tnt.boom(pos, {
			radius = math.random(1, 2),
			ignore_protection = false,
			ignore_on_blast = false,
			damage_radius = 3,
			disable_drops = true,

			-- Launched by this mob type. Blast will not damage mobs of this type.
			mob = "oerkki:night_master",
		})

		minetest.add_item(pos, "mobs:flame_bolt")
	end
})

mobs.register_egg("oerkki:night_master", "Night Master", "default_obsidian.png", 1)