minetest.register_craftitem("throwing:arrow_teleport", {
	description = "Teleport Arrow",
	inventory_image = "throwing_arrow_teleport.png",
})

minetest.register_node("throwing:arrow_teleport_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},
			
			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"throwing_arrow_teleport.png", "throwing_arrow_teleport.png", "throwing_arrow_teleport_back.png", "throwing_arrow_teleport_front.png", "throwing_arrow_teleport_2.png", "throwing_arrow_teleport.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	_name = "throwing:arrow_teleport",
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"throwing:arrow_teleport_box"},
	lastpos = {},
	collisionbox = {0,0,0,0,0,0},
	player = "",
}

local air_nodes = {"air", "group:airlike"}

local function do_teleport(self, above)
	if not self.player_name then
		return
	end

	-- Player may have logged off after firing the arrow.
	local player = minetest.get_player_by_name(self.player_name)
	local tpos = minetest.find_node_near(above, 1, air_nodes, true)

	if player and tpos then
		player:set_pos(tpos)
	end
end

function THROWING_ARROW_ENTITY.hit_player(self, obj, intersection_point)
	do_teleport(self, intersection_point)
end

function THROWING_ARROW_ENTITY.hit_object(self, obj, intersection_point)
	do_teleport(self, intersection_point)
end

function THROWING_ARROW_ENTITY.hit_node(self, above, under, intersection_point)
	do_teleport(self, above)
end

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	throwing.do_fly(self, dtime)
end

minetest.register_entity("throwing:arrow_teleport_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = 'throwing:arrow_teleport 8',
	recipe = {
		{'default:stick', 'default:stick', 'starpearl:pearl'}
	}
})

minetest.register_craft({
	output = 'throwing:arrow_teleport 8',
	recipe = {
		{'starpearl:pearl', 'default:stick', 'default:stick'}
	}
})
