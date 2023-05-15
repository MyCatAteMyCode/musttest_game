
-- Caverealm noise, choses when cave biomes can spawn and what is left stone.
local noise1param3d = {
    offset = 0,
    scale = 1,
    spread = {x=128, y=128, z=128},
    seed = 708291,
    octaves = 6,
    persist = 0.7,
    lacunarity = 2
}

-- Vein noise. Choses size & frequency of floor or roof ore veins.
local noise2param3d = {
    offset = 0,
    scale = 1,
    spread = {x=128, y=128, z=128},
    seed = 48791,
    octaves = 4,
    persist = 0.5,
    lacunarity = 2
}

-- Biome noise, used to chose what cave biome should generate.
local noise3param3d = {
    offset = 0,
    scale = 1,
    spread = {x=512, y=512, z=512},
    seed = 127726,
    octaves = 4,
    persist = 0.7,
    lacunarity = 2
}

-- Content-IDs for the voxel manipulator.
local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_cobble = minetest.get_content_id("cavestuff:cobble") -- Special nodetype.
local c_mossy_cobble = minetest.get_content_id("default:mossycobble")
local c_cobble_moss = minetest.get_content_id("cavestuff:cobble_with_moss")
local c_cobble_lichen = minetest.get_content_id("cavestuff:cobble_with_lichen")
local c_cobble_algae = minetest.get_content_id("cavestuff:cobble_with_algae")
local c_cobble_salt = minetest.get_content_id("cavestuff:cobble_with_salt")
local c_coal_block = minetest.get_content_id("default:coalblock")
local c_quartz_block = minetest.get_content_id("quartz:block")
local c_dark_obsidian = minetest.get_content_id("cavestuff:dark_obsidian")
local c_thin_ice = minetest.get_content_id("ice:thin_ice")
local c_ice = minetest.get_content_id("default:ice")
local c_sandy_ice = minetest.get_content_id("sand:sand_with_ice_crystals")

-- These tables are updated per chunk-generation iteration.
-- Keeping them external improves performance according to MT Lua docs.
local data = {} -- Voxelmanip data table external for performance.
local noisemap1 = {}
local noisemap2 = {}
local noisemap3 = {}

-- Mapgen notes: this algorithm does not create any caves. It populates caves
-- already generated by the C++ mapgen. Use huge Valleys caves for best results.
cavegen.generate = function(minp, maxp, seed)
  -- Do not run for chunks above or below the caverealm region.
  if minp.y > -5000 or maxp.y < -23000 then
    return
  end
  
  -- Grab the voxel manipulator.
  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  vm:get_data(data)
  local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
  local area2 = VoxelArea:new{MinEdge=minp, MaxEdge=maxp} -- Noise area.
  
  local pr = PseudoRandom(seed + 71)
  
  local x1 = maxp.x
  local y1 = maxp.y
  local z1 = maxp.z
  local x0 = minp.x
  local y0 = minp.y
  local z0 = minp.z
  
  -- Compute side lengths. 
  local side_len_x = ((x1-x0)+1)
  local side_len_y = ((y1-y0)+1)
  local side_len_z = ((z1-z0)+1)
  local sides3D = {x=side_len_x, y=side_len_y, z=side_len_z}
  local bp3d = {x=x0, y=y0, z=z0}
  
  local perlin1 = minetest.get_perlin_map(noise1param3d, sides3D)
  perlin1:get_3d_map_flat(bp3d, noisemap1)
  
  local perlin2 = minetest.get_perlin_map(noise2param3d, sides3D)
  perlin2:get_3d_map_flat(bp3d, noisemap2)
  
  local perlin3 = minetest.get_perlin_map(noise3param3d, sides3D)
  perlin3:get_3d_map_flat(bp3d, noisemap3)
  
  local floor = math.floor
  local ceil = math.ceil
  local abs = math.abs
  local clamp = function(v, l, u)
    if v < l then return l end
    if v > u then return u end
    return v
  end
  
  -- Compute caverealm threshold. 0 = no caverealm, 1 = max possible.
  local compute_threshold = function(y)
    -- Height values outside outer range result in 0.
    if y > -5000 then
      return 0
    elseif y > -17000 then
      -- Y is below -5k and above -10k. Need fade!
      local a = (y+5000)/12000 -- Get value between 1 and 0.
      return abs(a)
    elseif y > -22000 then
      return 1
    elseif y > -23000 then
      -- Y is below -22k and above -23k. Need fade!
      local a = (y+23000)/1000 -- Get value between 1 and 0.
      return a
    else
      return 0
    end
  end
  
  -- These tables will be filled with locations for decorations,
  -- calculated by the voxel manipulator code. After the voxel manipulator
  -- runs, decorations should be placed at locations in these tables.
  local glowstrings = {}
  local rooficicles = {}
  local floorcicles = {}
  local mycenashrom = {}
  local fungusshrom = {}
  local cavespikeps = {}
  local saltcrystal = {}
  local moongemspos = {}
  local sapphrspike = {} -- Sapphire spikes.
  local emraldspike = {} -- Emerald spikes.
  local emraldspik2 = {} -- Emerald spikes.
  local rubyspikes1 = {}
  local amethystspk = {}
  local mesespikes1 = {}
  local swaterwells = {}
  
  for z = z0, z1 do
    for x = x0, x1 do
      for y = y0, y1 do
        -- Get index into 3D noise array.
        local ni3 = area2:index(x, y, z)
        
        local n1 = noisemap1[ni3]
        local n2 = noisemap2[ni3]
        local n3 = noisemap3[ni3]
        
        local threshold = compute_threshold(y)
        local rn = clamp(abs(n1), 0, 1) -- Caverealm noise.
        
        if rn <= threshold then
          local vp = area:index(x, y, z)
          local vu = area:index(x, y+1, z)
          local vd = area:index(x, y-1, z)
          
          local ip = data[vp]
          local iu = data[vu]
          local id = data[vd]
          
          -- If found cave ceiling.
          if ip == c_stone and id == c_air then
            data[vp] = c_cobble -- Plain cobble on roof.
            if abs(n2) < 0.04 then
              data[vd] = c_quartz_block
            elseif abs(n2) < 0.09 then
              data[vd] = c_coal_block
            elseif pr:next(1, 100) == 1 then -- Glow worms.
              glowstrings[#glowstrings+1] = {x=x, y=y-1, z=z}
            elseif pr:next(1, 100) == 1 then -- Icicles
              rooficicles[#rooficicles+1] = {x=x, y=y-1, z=z}
              data[vp] = c_thin_ice -- Override cobble roof.
            end
          end
          
          if rn <= threshold*0.8 then
            -- If found raw cave floor.
            -- We check floor after ceiling in case floor and ceiling
            -- intersect. This way, floor material takes precedence.
            if ip == c_stone and iu == c_air then
              data[vp] = c_cobble -- Plain cobble under floor surface.
              if abs(n2) < 0.05 then
                data[vu] = c_dark_obsidian
              else
                -- Chose floor type to place. Floor type determines biome.
                local bn = abs(n3)
                if bn < 0.1 then
                  data[vu] = c_cobble_moss
                elseif bn < 0.3 then
                  data[vu] = c_cobble_algae
                elseif bn < 0.6 then
                  data[vu] = c_cobble_lichen
                elseif bn < 0.8 then
                  data[vu] = c_cobble_salt
                elseif bn < 0.9 then
                  data[vu] = c_sandy_ice
                else
                  data[vu] = c_thin_ice
                  if bn > 1.0 then
                    data[vp] = c_ice -- Override cobble floor.
                  end
                end
              end
            end
          end
          
          -- Floor & roof types have changed, re-read them.
          ip = data[vp]
          iu = data[vu]
          id = data[vd]
          
          -- If found generated ice cave floor.
          -- Generate position tables for ice biome decorations.
          if ip == c_thin_ice and iu == c_air then
            if pr:next(1, 100) == 1 then
              floorcicles[#floorcicles+1] = {x=x, y=y+1, z=z}
              data[vp] = c_ice
            end
          end
          
          -- If found floor of biome suitable for mushrooms.
          -- Generate position tables for mushrooms.
          if (ip == c_cobble_moss or
              ip == c_cobble_algae or
              ip == c_cobble_lichen) and iu == c_air then
            if pr:next(1, 100) == 1 then
              mycenashrom[#mycenashrom+1] = {x=x, y=y+1, z=z}
              data[vp] = c_mossy_cobble
            elseif pr:next(1, 70) == 1 then
              fungusshrom[#fungusshrom+1] = {x=x, y=y+1, z=z}
              data[vp] = c_mossy_cobble
            end
          end
          
          if ip == c_cobble_salt and iu == c_air then
            if pr:next(1, 100) == 1 then
              saltcrystal[#saltcrystal+1] = {x=x, y=y+1, z=z}
            end
          end
          
          if ip == c_cobble_lichen and iu == c_air then
            if pr:next(1, 200) == 1 then
              moongemspos[#moongemspos+1] = {x=x, y=y+1, z=z}
            end
          end
          
          -- Water wells.
          if pr:next(1, 40) == 1 then
            if iu == c_air and ip == c_cobble_moss then
              swaterwells[#swaterwells+1] = {x=x, y=y, z=z}
            end
          end
          
          -- Chance for spikes is deceptively high.
          -- Most of these locations will be rejected due to ground checks later.
          if pr:next(1, 40) == 1 then
            if iu == c_air then
              if ip == c_cobble_lichen then
                sapphrspike[#sapphrspike+1] = {x=x, y=y+1, z=z}
              end
              
              if ip == c_cobble_moss then
                emraldspike[#emraldspike+1] = {x=x, y=y+1, z=z}
              end
              
              if ip == c_cobble_algae then
                emraldspik2[#emraldspik2+1] = {x=x, y=y+1, z=z}
              end
            end
            
            -- Ceiling spikes.
            if ip == c_cobble and id == c_air then
              local which = pr:next(1, 3)
              if which == 1 then
                mesespikes1[#mesespikes1+1] = {x=x, y=y-1, z=z}
              elseif which == 2 then
                rubyspikes1[#rubyspikes1+1] = {x=x, y=y-1, z=z}
              elseif which == 3 then
                amethystspk[#amethystspk+1] = {x=x, y=y-1, z=z}
              end
            end
          end
          
          -- If found raw stone floor (edges of caverealm biomes).
          -- Generate positions for rock spikes.
          if ip == c_stone and iu == c_air then
            if pr:next(1, 40) == 1 then
              cavespikeps[#cavespikeps+1] = {x=x, y=y+1, z=z}
            end
          end
        end
      end -- For all in Y coordinates.
    end -- For all in X coordinates.
  end -- For all in Z coordinates.
  
  -- Finalize voxel manipulator.
  vm:set_data(data)
  vm:set_lighting({day=0, night=0})
  vm:calc_lighting()
  vm:update_liquids()
  vm:write_to_map()
  
  -- Place glow worms.
  -- Glow worms come in columns of nodes,
  -- so this needs a special algorithm.
  for k, v in ipairs(glowstrings) do
    local len = pr:next(1, pr:next(2, 5))
    for i=0, len, 1 do
      local pos = {x=v.x, y=v.y-i, z=v.z}
      if minetest.get_node(pos).name == "air" then
        minetest.set_node(pos, {name="cavestuff:glow_worm"})
      else
        break
      end
    end
  end
  
  -- Function for quickly placing 1-node sized decorations.
  local place_decorations = function(nn, tt)
    for k, v in ipairs(tt) do
      local pos = {x=v.x, y=v.y, z=v.z}
      if minetest.get_node(pos).name == "air" then
        minetest.set_node(pos, {name=nn})
      end
    end
  end
  
  place_decorations("cavestuff:icicle_down", rooficicles)
  place_decorations("cavestuff:icicle_up", floorcicles)
  place_decorations("cavestuff:mycena", mycenashrom)
  place_decorations("cavestuff:fungus", fungusshrom)
  
  -- Place stone spikes.
  for k, v in ipairs(cavespikeps) do
    local pos = {x=v.x, y=v.y, z=v.z}
    if minetest.get_node(pos).name == "air" then
      minetest.set_node(pos, {name="cavestuff:spike" .. pr:next(1, 4)})
    end
  end
  
  -- Place salt crystals.
  for k, v in ipairs(saltcrystal) do
    local pos = {x=v.x, y=v.y, z=v.z}
    if minetest.get_node(pos).name == "air" then
      minetest.set_node(pos, {name="cavestuff:saltcrystal" .. pr:next(1, 4)})
    end
  end
  
  -- Place moon gems.
  for k, v in ipairs(moongemspos) do
    local pos = {x=v.x, y=v.y, z=v.z}
    if minetest.get_node(pos).name == "air" then
      minetest.set_node(pos, {name="cavestuff:bluecrystal" .. pr:next(1, 4)})
    end
  end
  
  local place_spike_up = function(gname, basename, spikename, postable)
    for k, v in ipairs(postable) do
      -- Check foundation to see if a spike can be placed here.
      local floorcheck = {
        {x=v.x, y=v.y-1, z=v.z},
        {x=v.x-1, y=v.y-1, z=v.z},
        {x=v.x+1, y=v.y-1, z=v.z},
        {x=v.x, y=v.y-1, z=v.z-1},
        {x=v.x, y=v.y-1, z=v.z+1},
      }
      for i, j in ipairs(floorcheck) do
        if minetest.get_node(j).name ~= gname then
          return -- Bad foundation.
        end
      end
      
      -- Foundation is solid.
      -- Build crystaline base.
      local crystalbase = {
        {x=v.x, y=v.y, z=v.z},
        
        {x=v.x-1, y=v.y, z=v.z},
        {x=v.x+1, y=v.y, z=v.z},
        {x=v.x, y=v.y, z=v.z-1},
        {x=v.x, y=v.y, z=v.z+1},
        
        {x=v.x-1, y=v.y, z=v.z-1},
        {x=v.x+1, y=v.y, z=v.z-1},
        {x=v.x-1, y=v.y, z=v.z+1},
        {x=v.x+1, y=v.y, z=v.z+1},
        
        {x=v.x-2, y=v.y, z=v.z},
        {x=v.x+2, y=v.y, z=v.z},
        {x=v.x, y=v.y, z=v.z-2},
        {x=v.x, y=v.y, z=v.z+2},
      }
      for i, j in ipairs(crystalbase) do
        minetest.set_node(j, {name=basename})
      end
      
      -- Build upwards pointing spike.
      local l = pr:next(7, 20)
      local l1 = pr:next(floor(l/3), floor((l/3)*2))
      local l2 = pr:next(floor(l/3), floor((l/3)*2))
      local l3 = pr:next(floor(l/3), floor((l/3)*2))
      local l4 = pr:next(floor(l/3), floor((l/3)*2))
      
      local buildspike = function(pos, len)
        for i=0, len, 1 do
          local p = {x=pos.x, y=pos.y+i, z=pos.z}
          -- Spikes grow through everything,
          -- but quit if at unloaded chunk border.
          if minetest.get_node(p).name == "ignore" then return end
          minetest.set_node(p, {name=spikename})
        end
      end
      
      buildspike({x=v.x, y=v.y+1, z=v.z}, l)
      buildspike({x=v.x-1, y=v.y+1, z=v.z}, l1)
      buildspike({x=v.x+1, y=v.y+1, z=v.z}, l2)
      buildspike({x=v.x, y=v.y+1, z=v.z-1}, l3)
      buildspike({x=v.x, y=v.y+1, z=v.z+1}, l4)
    end
  end
  
  local place_spike_down = function(gname, basename, spikename, postable)
    for k, v in ipairs(postable) do
      -- Check foundation to see if a spike can be placed here.
      local floorcheck = {
        {x=v.x, y=v.y+1, z=v.z},
        {x=v.x-1, y=v.y+1, z=v.z},
        {x=v.x+1, y=v.y+1, z=v.z},
        {x=v.x, y=v.y+1, z=v.z-1},
        {x=v.x, y=v.y+1, z=v.z+1},
      }
      for i, j in ipairs(floorcheck) do
        if minetest.get_node(j).name ~= gname then
          return -- Bad foundation.
        end
      end
      
      -- Foundation is solid.
      -- Build crystaline base.
      local crystalbase = {
        {x=v.x, y=v.y, z=v.z},
        
        {x=v.x-1, y=v.y, z=v.z},
        {x=v.x+1, y=v.y, z=v.z},
        {x=v.x, y=v.y, z=v.z-1},
        {x=v.x, y=v.y, z=v.z+1},
        
        {x=v.x-1, y=v.y, z=v.z-1},
        {x=v.x+1, y=v.y, z=v.z-1},
        {x=v.x-1, y=v.y, z=v.z+1},
        {x=v.x+1, y=v.y, z=v.z+1},
        
        {x=v.x-2, y=v.y, z=v.z},
        {x=v.x+2, y=v.y, z=v.z},
        {x=v.x, y=v.y, z=v.z-2},
        {x=v.x, y=v.y, z=v.z+2},
      }
      for i, j in ipairs(crystalbase) do
        minetest.set_node(j, {name=basename})
      end
      
      -- Build downwards pointing spike.
      local l = pr:next(7, 20)
      local l1 = pr:next(floor(l/3), floor((l/3)*2))
      local l2 = pr:next(floor(l/3), floor((l/3)*2))
      local l3 = pr:next(floor(l/3), floor((l/3)*2))
      local l4 = pr:next(floor(l/3), floor((l/3)*2))
      
      local buildspike = function(pos, len)
        for i=0, len, 1 do
          local p = {x=pos.x, y=pos.y-i, z=pos.z}
          -- Spikes grow through everything,
          -- but quit if at unloaded chunk border.
          if minetest.get_node(p).name == "ignore" then return end
          minetest.set_node(p, {name=spikename})
        end
      end
      
      buildspike({x=v.x, y=v.y-1, z=v.z}, l)
      buildspike({x=v.x-1, y=v.y-1, z=v.z}, l1)
      buildspike({x=v.x+1, y=v.y-1, z=v.z}, l2)
      buildspike({x=v.x, y=v.y-1, z=v.z-1}, l3)
      buildspike({x=v.x, y=v.y-1, z=v.z+1}, l4)
    end
  end
  
  local place_water_well = function(gname, postable)
    for k, v in ipairs(postable) do
      -- Check foundation to see if a spike can be placed here.
      local floorcheck = {
        {x=v.x, y=v.y, z=v.z},
        {x=v.x-1, y=v.y, z=v.z},
        {x=v.x+1, y=v.y, z=v.z},
        {x=v.x, y=v.y, z=v.z-1},
        {x=v.x, y=v.y, z=v.z+1},
      }
      for i, j in ipairs(floorcheck) do
        if minetest.get_node(j).name ~= gname then
          return -- Bad foundation.
        end
      end
      
      local offset = vector.new(-2, 0, -2)
      local pos = vector.add(v, offset)
      
      local path = cavegen.modpath .. "/caverealm_freshwater_well.mts"
      minetest.place_schematic(pos, path, "random", nil, true)
    end
  end
  
  place_spike_up(
    "cavestuff:cobble_with_lichen",
    "cavestuff:glow_sapphire_ore",
    "cavestuff:glow_sapphire",
    sapphrspike)
  
  place_spike_up(
    "cavestuff:cobble_with_moss",
    "cavestuff:glow_emerald_ore",
    "cavestuff:glow_emerald",
    emraldspike)
  
  place_spike_up(
    "cavestuff:cobble_with_algae",
    "cavestuff:glow_emerald_ore",
    "cavestuff:glow_emerald",
    emraldspik2)
  
  place_spike_down(
    "cavestuff:cobble",
    "cavestuff:glow_ruby_ore",
    "cavestuff:glow_ruby",
    rubyspikes1)
  
  place_spike_down(
    "cavestuff:cobble",
    "cavestuff:glow_amethyst_ore",
    "cavestuff:glow_amethyst",
    amethystspk)
  
  place_spike_down(
    "cavestuff:cobble",
    "default:stone_with_mese",
    "cavestuff:glow_mese",
    mesespikes1)
    
  place_water_well(
    "cavestuff:cobble_with_moss",
    swaterwells)
end
