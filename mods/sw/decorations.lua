
-- High above the actual beginning, to ensure decorations here don't spawn on
-- unusually tall Carcorsica mountains. (Actual XEN_BEGIN is 13150.)
local XEN_BEGIN = 13500
local XEN_MID = 14150
local XEN_END = 15150
local XEN_UPPERMID = 14300

-- Small pools.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "stairs:slab_cobble",
	sidelen = 8,
	fill_ratio = 0.1,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_pool1.mts",
	flags = "all_floors,force_placement,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = -4,
	replacements = {
		["sw:teststone1"] = "sw:teststone1_hard",
		["default:water_source"] = "default:river_water_source",
	},
})

-- Large pools.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "stairs:slab_cobble",
	sidelen = 8,
	fill_ratio = 0.01,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_pool2.mts",
	flags = "all_floors,force_placement,place_center_x,place_center_z",
	rotation = "0",
	place_offset_y = -1,
	replacements = {
		["sw:teststone1"] = "sw:teststone1_hard",
		["default:water_source"] = "default:river_water_source",
	},
})

--------------------------------------------------------------------------------
-- Large crystal formations.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.01,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_crysform1.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = -1,
	spawn_by = {"default:desert_stone", "rackstone:rackstone"},
	num_spawn_by = 3,
	check_offset = -1,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.02,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_crysform2.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = -1,
	spawn_by = {"default:desert_stone", "rackstone:rackstone"},
	num_spawn_by = 3,
	check_offset = -1,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.02,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_crysform3.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
	spawn_by = {"default:desert_stone", "rackstone:rackstone"},
	num_spawn_by = 3,
	check_offset = -1,
})

-- Add detail to the top of glow crystal formations.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cavestuff:glow_mese",
	sidelen = 8,
	fill_ratio = 0.6,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"stairs:stair_glow_mese",
		"stairs:slab_glow_mese",
		"stairs:micro_glow_mese_16",
		"stairs:micro_glow_mese",
	},
	param2 = 0,
	param2_max = 3,
})

-- Add detail to the bottom of glow crystal formations.
-- Can't combine with top decorations because param2 must be different.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cavestuff:glow_mese",
	sidelen = 8,
	fill_ratio = 0.6,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = {
		"stairs:stair_glow_mese",
		"stairs:slab_glow_mese",
		"stairs:micro_glow_mese_16",
		"stairs:micro_glow_mese",
	},
	param2 = 20,
	param2_max = 23,
})

--------------------------------------------------------------------------------

-- Sunfire Tree 1.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree1.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

-- Sunfire Tree 2.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.0001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree2.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

--Sunfire Tree 3.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree3.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

--Sunfire Tree 4.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.0003,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree4.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

--Sunfire Tree 5.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.0002,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree5.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

--Sunfire Tree 6.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.0003,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree6.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

--Sunfire Tree 7.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.0003,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_tree7.mts",
	flags = "all_floors,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

-- Large yellow crystals.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "sw:teststone2"},
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "mese_crystals:mese_crystal_ore5",
	param2 = 0,
	param2_max = 3,
})

-- Small yellow crystals clustered around larger ones.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {
		"sw:teststone1",
		"sw:teststone2",
		"default:desert_stone",
		"rackstone:rackstone",
	},
	sidelen = 8,
	fill_ratio = 0.3,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"mese_crystals:mese_crystal_ore1",
		"mese_crystals:mese_crystal_ore2",
		"mese_crystals:mese_crystal_ore3",
	},
	param2 = 0,
	param2_max = 3,
	spawn_by = {
		"mese_crystals:mese_crystal_ore5",
		"cavestuff:glow_mese",
	},
	num_spawn_by = 1,
	check_offset = 1,
})

-- Midnight sun and fairy flowers.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:gravel", "default:dirt"},
	sidelen = 8,
	fill_ratio = 0.05,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"aradonia:caveflower6",
		"aradonia:caveflower8",
	},
})

-- Blue crystals clustered around midnight sun flowers.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "sw:teststone2", "default:gravel", "default:dirt"},
	sidelen = 8,
	fill_ratio = 0.7,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"cavestuff:bluecrystal1",
		"cavestuff:bluecrystal2",
		"cavestuff:bluecrystal3",
		"cavestuff:bluecrystal4",
	},
	param2 = 0,
	param2_max = 3,
	spawn_by = "aradonia:caveflower6",
	num_spawn_by = 1,
	check_offset = 1,
})

-- Fire vase.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1","sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "aradonia:caveflower11",
})

-- Candle flower.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.5,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "aradonia:caveflower12",
	spawn_by = "aradonia:caveflower11",
	num_spawn_by = 1,
	check_offset = 1,
	param2 = 10,
})

-- Blue fungus.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "bedrock:bedrock", "sw:teststone1_open"},
	sidelen = 8,
	y_min = XEN_BEGIN,
	y_max = XEN_MID,
	flags = "all_floors",
	decoration = "cavestuff:glow_fungus",
	noise_params = {
		offset = -0.1,
		scale = 0.15,
		spread = {x=32, y=32, z=32},
		seed = 7718,
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
})
-- Star Moss
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "bedrock:bedrock", "sw:teststone1_open"},
	sidelen = 8,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "aradonia:caveflower14",
	param2 = 10,
	noise_params = {
		offset = -0.1,
		scale = 0.35,
		spread = {x=32, y=32, z=32},
		seed = 2018,
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
})	
--White Moonflower
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "bedrock:bedrock", "sw:teststone1_open"},
	sidelen = 8,
	y_min = XEN_UPPERMID -5,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "aradonia:caveflower15",
	noise_params = {
		offset = -0,
		scale = 0.01,
		spread = {x=100, y=100, z=100},
		seed = 2917,
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
})
--Pink Moonflower
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "bedrock:bedrock", "sw:teststone1_open"},
	sidelen = 8,
	y_min = XEN_UPPERMID -5,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "aradonia:caveflower16",
	spawn_by = "aradonia:caveflower15",
	num_spawn_by = 1,
	check_offset = 1,
    fill_ratio = 0.3,
})

	-- Glow worms.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "cavestuff:glow_worm",
	height = 1,
	height_max = 4,
	noise_params = {
		offset = -0.1,
		scale = 0.35,
		spread = {x=32, y=32, z=32},
		seed = 7718,
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
})

-- Nether vines.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.025,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "nethervine:vine",
	height = 4,
	height_max = 8,
})

-- Glow worms.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "cavestuff:glow_worm",
	height = 8,
	height_max = 32,
})

-- Nether vines.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "nethervine:vine",
	height = 8,
	height_max = 32,
})

-- White crystals.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "sw:teststone2"},
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"cavestuff:whitespike1",
		"cavestuff:whitespike2",
		"cavestuff:whitespike3",
		"cavestuff:whitespike4",
	},
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "bedrock:bedrock",
	sidelen = 8,
	fill_ratio = 0.3,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"cavestuff:whitespike1",
		"cavestuff:whitespike2",
		"cavestuff:whitespike3",
		"cavestuff:whitespike4",
	},
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "sw:teststone1_open"},
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "stairs:slab_bakedclay_terracotta_light_blue",
	param2 = 0,
	param2_max = 3,
})

-- This is supposed to be a strange-looking blue crystal with brown/gold highlights.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.01,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "stairs:slab_bakedclay_terracotta_blue",
	param2 = 20,
	param2_max = 23,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"sw:teststone1", "sw:teststone2"},
	sidelen = 8,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "default:diamondblock",
		noise_params = {
		offset = -0.04,
		scale = 0.05,
		spread = {x=150, y=150, z=150},
		seed = 802,
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.02,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = {
		"bluegrass:plant_2",
		"bluegrass:plant_3",
		"bluegrass:plant_4",
		"bluegrass:plant_5",
		"bluegrass:plant_6",
		"bluegrass:plant_7",
	},
	param2 = 2,
})

-- Twilight bulb.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "vines:luminoustreevineend",
	noise_params = {
		offset = -0.2,
		scale = 0.22,
		spread = {x=100, y=100, z=100},
		seed = 88112, -- Note: using the same seed keeps them with vines.
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
})

-- Twilight vine.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "vines:luminoustreevine",
	noise_params = {
		offset = -0.2,
		scale = 0.22,
		spread = {x=100, y=100, z=100},
		-- Note: using the same seed keeps them with bulbs.
		-- We can't just combine the two decorations into one because one is a vine
		-- and the other is a single node.
		seed = 88112,
		octaves = 3,
		persistence = 0.7,
		lacunarity = 2.0,
		flags = "absvalue",
	},
	height = 4,
	height_max = 10,
})

-- Spider webs in Xen tunnels.
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "sw:teststone2",
	sidelen = 8,
	fill_ratio = 0.001,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	schematic = "schems/xen_web1.mts",
	flags = "all_ceilings,place_center_x,place_center_z",
	rotation = "random",
	place_offset_y = 0,
})

-- Stray cobwebs.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone2",
	sidelen = 8,
	fill_ratio = 0.005,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "xdecor:cobweb",
	height = 1,
	height_max = 3,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "sw:teststone1",
	sidelen = 8,
	fill_ratio = 0.3,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = "default:dirt_with_rainforest_litter",
	spawn_by = {"bedrock:bedrock", "stairs:cobble_slab"},
	num_spawn_by = 1,
	check_offset = 1,
})

-- Regular flowers on dirt near pools.
local ALL_FLOWERS = {}
for k, data in ipairs(flowers.datas) do
	-- data[1] should be flower name.
	ALL_FLOWERS[#ALL_FLOWERS+1] = "flowers:" .. data[1]
end

minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:dirt_with_rainforest_litter",
	sidelen = 8,
	fill_ratio = 0.3,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = ALL_FLOWERS,
})

-- Waterlilies, an important resource.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:river_water_source",
	sidelen = 8,
	fill_ratio = 0.1,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "liquid_surface",
	decoration = "flowers:waterlily",
	param2 = 0,
	param2_max = 3,
})

-- Big Dustflower
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:desert_stone", "rackstone:rackstone"},
	sidelen = 8,
	fill_ratio = 0.004,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	decoration = {
		"aradonia:caveflower18",
	},
})

-- Little Dustflower
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:desert_stone", "rackstone:rackstone"},
	sidelen = 8,
	fill_ratio = 0.3,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_floors",
	spawn_by = "aradonia:caveflower18",
	num_spawn_by = 1,
	decoration = {
		"aradonia:caveflower17",
	},
})

-- Tree vines.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "firetree:luminoustreeleaves",
	sidelen = 8,
	fill_ratio = 0.05,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = "default:papyrus2",
	height = 3,
	height_max = 7,
})

-- Tree moss ... or something like that.
minetest.register_decoration({
	deco_type = "simple",
	place_on = "firetree:luminoustreeleaves",
	sidelen = 8,
	fill_ratio = 0.1,
	y_min = XEN_BEGIN,
	y_max = XEN_END,
	flags = "all_ceilings",
	decoration = {
		"default:grass_1_hanging",
		"default:grass_2_hanging",
		"default:grass_3_hanging",
		"default:grass_4_hanging",
		"default:grass_5_hanging",
	},
	param2 = 2,
})

-- MCAMC! There should be a line ending after this line!
-- If there's no line ending make sure you add one!
-- If your editor is stripping out line endings throw your editor in the trash and buy a new one from Walmart!
