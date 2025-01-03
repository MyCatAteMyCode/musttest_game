
local REALM_START = 21150
local REALM_END = 23450
local REALM_GROUND = 21150+2000
local LAVA_SEA_HEIGHT = 21170

local abs = math.abs
local floor = math.floor
local max = math.max
local min = math.min
local pr = PseudoRandom(5829)

local vm_data = {}
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_bedrock = minetest.get_content_id("bedrock:bedrock")
local c_cobble = minetest.get_content_id("rackstone:cobble")
local c_lava = minetest.get_content_id("lbrim:lava_source")



function ab.generate_caverns(vm, minp, maxp, seed)
	local emin, emax = vm:get_emerged_area()
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})

	vm:get_data(vm_data)

	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z

	y0 = max(REALM_START, y0)
	y1 = min(REALM_END, y1)

	-- Compute side lengths.
	-- Note: noise maps use overgeneration coordinates/sizes.
	-- This is to support horizontal shearing.
	local side_len_x = ((emax.x-emin.x)+1)
	local side_len_y = ((emax.y-emin.y)+1)
	local side_len_z = ((emax.z-emin.z)+1)
	local sides2D = {x=side_len_x, y=side_len_z}
	local sides3D = {x=side_len_x, y=side_len_y, z=side_len_z}
	local bp2d = {x=emin.x, y=emin.z}
	local bp3d = {x=emin.x, y=emin.y, z=emin.z}

	local noisemap1 = ab.get_3d_noise(bp3d, sides3D, "cavern_noise1")
	local noisemap2 = ab.get_3d_noise(bp3d, sides3D, "cavern_noise2")
	local noisemap3 = ab.get_3d_noise(bp3d, sides3D, "cavern_noise3")
	local noisemap4 = ab.get_3d_noise(bp3d, sides3D, "cavern_noise4")
	local noisemap5 = ab.get_3d_noise(bp3d, sides3D, "cavern_noise5")

	local function is_cavern(x, y, z, ground_y)
		local idx = area:index(x, y, z)

		local n1 = noisemap1[idx]
		local n2 = noisemap2[idx]
		local n3 = noisemap3[idx]
		local n4 = noisemap4[idx]
		local n5 = noisemap5[idx]

		if y < (ground_y - (350 + (abs(n4) * 50))) then
			local noise1 = n1 + n2 + n3
			local noise2 = abs(n5)
			if noise1 < -0.2 then
				if noise1 > -0.3 and noise2 > 0.2 then
					return false
				end
				return true
			end
		end

		return false
	end

	for z = z0, z1 do
		for x = x0, x1 do
			-- 0: undefined
			-- 1: stone
			-- 2: cavern
			local toggle = 0

			local ground_y = REALM_GROUND

			for y = y0, y1 do
				local is_floor = false
				local is_ceiling = false

				if is_cavern(x, y, z, ground_y) then
					if toggle == 1 then
						is_floor = true
					end
					toggle = 2

					local vp = area:index(x, y, z)
					local cid = vm_data[vp]

					-- Do NOT carve caverns through bedrock or "ignore".
					-- Skip air since there's nothing there anyway.
					if cid ~= c_air and cid ~= c_ignore and cid ~= c_bedrock then
						if y <= LAVA_SEA_HEIGHT then
							vm_data[vp] = c_lava
						else
							vm_data[vp] = c_air
						end
					end
				else
					if toggle == 2 then
						is_ceiling = true
					end
					toggle = 1
				end

				-- Deal with floors or ceilings as we find them in the Y-column.
				if y < ground_y and (is_floor or is_ceiling) then
					local vp = area:index(x, y, z)
					local cid = vm_data[vp]

					-- Do NOT carve caverns through bedrock or "ignore".
					if cid ~= c_ignore and cid ~= c_bedrock then
						vm_data[vp] = c_cobble
					end
				end
			end
		end
	end

	vm:set_data(vm_data)
end
