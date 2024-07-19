
local vm_data = {}
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_stone = minetest.get_content_id("rackstone:rackstone")
local c_cobble = minetest.get_content_id("rackstone:cobble")
local c_bedrock = minetest.get_content_id("bedrock:bedrock")

local NN_DEAD_TREE = "basictrees:tree_trunk_dead"

local abs = math.abs
local floor = math.floor
local max = math.max
local min = math.min

-- Param2 horizontal branch rotations.
local branch_rotations = {4, 8, 12, 16}
local branch_directions = {2, 0, 3, 1}

function ab.generate_biome(vm, minp, maxp, seed, ystart, yend, heightfunc)
	local emin, emax = vm:get_emerged_area()
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local area2d = VoxelArea2D:new({MinEdge={x=emin.x, y=emin.z}, MaxEdge={x=emax.x, y=emax.z}})
	local pr = PseudoRandom(seed + 418)

	vm:get_data(vm_data)

	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z

	local grass = {}
	local trees = {}
	local deadtrees = {}
	local glowstones = {}

	local glowstones_count = pr:next(1, 5)
	for k = 1, glowstones_count do
		glowstones[#glowstones + 1] = {
			x = x0 + pr:next(0, (x1 - x0)),
			z = z0 + pr:next(0, (z1 - z0)),
		}
	end

	local deadtrees_count = 64
	for k = 1, deadtrees_count do
		deadtrees[#deadtrees + 1] = {
			x = x0 + pr:next(0, (x1 - x0)),
			z = z0 + pr:next(0, (z1 - z0)),
		}
	end

	for z = z0, z1 do
		for x = x0, x1 do
			for y = y0, y1 do
				if y >= ystart and y <= yend then
					local vp_c = area:index(x, y, z)
					local vp_u = area:index(x, y + 1, z)

					local cid_c = vm_data[vp_c]
					local cid_u = vm_data[vp_u]

					if cid_c == c_stone and cid_u == c_air then
						-- We have found a surface.
						local ground_y, canyon_offset = heightfunc(x, y, z)

						-- Only cobble the surface, skip caves.
						if y == ground_y then
							vm_data[vp_c] = c_cobble
						end

						-- Surface decorations here.
						if y >= ground_y then
							local grassed = false
							if pr:next(1, 6) == 1 then
								grass[#grass + 1] = {x=x, y=y+1, z=z}
								grassed = true
							end

							-- Place trees when canyons are at least this deep.
							if canyon_offset < -50 and not grassed then
								if pr:next(1, 200) == 1 then
									trees[#trees + 1] = {x=x, y=y, z=z}
								end
							end
						end
					end
				end
			end
		end
	end

	vm:set_data(vm_data)

  for k = 1, #trees do
		ab.place_acacia_tree(vm, trees[k])
  end

  for k = 1, #grass do
		if pr:next(1, 7) == 1 then
			minetest.set_node(grass[k], {name="default:dry_shrub"})
		else
			minetest.set_node(grass[k], {name="default:dry_grass2_" .. pr:next(1, 5), param2=2})
		end
  end

  local function place_ground_decorations(decolist, decofunc)
		for k = 1, #decolist do
			local x = decolist[k].x
			local z = decolist[k].z
			for y = y1, y0, -1 do
				if y >= ystart and y <= yend then
					local vp_c = area:index(x, y, z)
					local vp_u = area:index(x, y + 1, z)
					local ground_y, canyon_offset = heightfunc(x, y, z)

					local cid_c = vm_data[vp_c]
					local cid_u = vm_data[vp_u]

					if cid_c == c_cobble and cid_u == c_air then
						if y >= ground_y and canyon_offset == 0 then
							-- On surface, not in canyon or mesa.
							local p = {x=x, y=y, z=z}
							decofunc(p)

							-- Goto next item.
							break
						end
					end
				end
			end
		end
	end

	local function put_deadtree(pos)
		local p = vector.offset(pos, 0, 1, 0)
		local n = pr:next(2, 5)

		if pr:next(1, 6) == 1 then
			for i = 1, n do
				minetest.set_node(p, {name=NN_DEAD_TREE})
				p = vector.offset(p, 0, 1, 0)
			end
		else
			local diridx = pr:next(1, 4)
			local facedir = branch_directions[diridx]
			local vec = minetest.facedir_to_dir(facedir)

			for i = 1, n do
				minetest.set_node(p, {name=NN_DEAD_TREE, param2=branch_rotations[diridx]})
				p = vector.add(p, vec)
			end
		end
  end

	place_ground_decorations(glowstones, function(pos)
		minetest.set_node(pos, {name="glowstone:minerals"})
	end)

	place_ground_decorations(deadtrees, put_deadtree)
end
