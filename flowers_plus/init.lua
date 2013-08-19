-- This file supplies a few additional plants and some related crafts
-- for the plantlife modpack.  Last revision:  2013-04-24

local SPAWN_DELAY = 1000
local SPAWN_CHANCE = 200
local flowers_seed_diff = 329

-- register the various rotations of waterlilies

local lilies_list = {
	{ nil, nil },
	{ "225", "22.5" },
	{ "45" , "45"   },
	{ "675", "67.5" },
}

for i in ipairs(lilies_list) do
	local deg1 = ""
	local deg2 = ""
	local lily_groups = {snappy = 3,flammable=2,flower=1}

	if lilies_list[i][1] ~= nil then
		deg1 = "_"..lilies_list[i][1]
		deg2 = "_"..lilies_list[i][2]
		lily_groups = { snappy = 3,flammable=2,flower=1, not_in_creative_inventory=1 }
	end

	minetest.register_node(":flowers:waterlily"..deg1, {
		description = "Waterlily",
		drawtype = "nodebox",
		tiles = { "flowers_waterlily"..deg2..".png" },
		inventory_image = "flowers_waterlily.png",
		wield_image  = "flowers_waterlily.png",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		walkable = false,
		groups = lily_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -0.4, -0.5, -0.4, 0.4, -0.45, 0.4 },
		},
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.49, -0.5, 0.5, -0.49, 0.5 },
		},
		buildable_to = true,

		liquids_pointable = true,
		drop = "flowers:waterlily",
		on_place = function(itemstack, placer, pointed_thing)
			local keys=placer:get_player_control()
			local pt = pointed_thing

			local place_pos = nil
			local top_pos = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
			local under_node = minetest.get_node(pt.under)
			local above_node = minetest.get_node(pt.above)
			local top_node   = minetest.get_node(top_pos)

			if plantslib:get_nodedef_field(under_node.name, "buildable_to") then
				if under_node.name ~= "default:water_source" then
					place_pos = pt.under
				elseif top_node.name ~= "default:water_source" 
				       and plantslib:get_nodedef_field(top_node.name, "buildable_to") then
					place_pos = top_pos
				else
					return
				end
			elseif plantslib:get_nodedef_field(above_node.name, "buildable_to") then
				place_pos = pt.above
			end

			if not plantslib:node_is_owned(place_pos, placer) then

			local nodename = "default:cobble" -- if this block appears, something went....wrong :-)

				if not keys["sneak"] then
					local node = minetest.env:get_node(pt.under)
					local waterlily = math.random(1,4)
					if waterlily == 1 then
						nodename = "flowers:waterlily"
					elseif waterlily == 2 then
						nodename = "flowers:waterlily_225"
					elseif waterlily == 3 then
						nodename = "flowers:waterlily_45"
					elseif waterlily == 4 then
						nodename = "flowers:waterlily_675"
					end
					minetest.add_node(place_pos, {name = nodename, param2 = math.random(0,3) })
				else
					local fdir = minetest.dir_to_facedir(placer:get_look_dir())
					minetest.add_node(place_pos, {name = "flowers:waterlily", param2 = fdir})
				end

				if not plantslib.expect_infinite_stacks then
					itemstack:take_item()
				end
				return itemstack
			end
		end,
	})
end

minetest.register_node(":flowers:seaweed", {
	description = "Seaweed",
	drawtype = "signlike",
	tiles = { "flowers_seaweed.png" },
	inventory_image = "flowers_seaweed.png",
	wield_image  = "flowers_seaweed.png",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	groups = { snappy = 3,flammable=2,flower=1 },
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, -0.4, 0.5 },
	},	
	buildable_to = true,
})

-- register all potted plant nodes, crafts, and most backward-compat aliases

local flowers_list = {
	{ "Rose",		"rose"},
	{ "Tulip",		"tulip"},
	{ "Yellow Dandelion",	"dandelion_yellow"},
	{ "White Dandelion",	"dandelion_white"},
	{ "Blue Geranium",	"geranium"},
	{ "Viola",		"viola"},
}

for i in ipairs(flowers_list) do
	local flowerdesc = flowers_list[i][1]
	local flower     = flowers_list[i][2]
	
	minetest.register_node(":flowers:potted_"..flower, {
		description = "Potted "..flowerdesc,
		drawtype = "plantlike",
		tiles = { "flowers_potted_"..flower..".png" },
		inventory_image = "flowers_potted_"..flower..".png",
		wield_image = "flowers_potted_"..flower..".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		groups = { snappy = 3,flammable=2 },
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
		},	
	})

	minetest.register_craft( {
		type = "shapeless",
		output = "flowers:potted_"..flower,
		recipe = {
			"flowers:flower_pot",
			"flowers:"..flower
		}
	})

	minetest.register_alias("flowers:flower_"..flower.."_pot", "flowers:potted_"..flower)
end

local extra_aliases = {
	"waterlily",
	"waterlily_225",
	"waterlily_45",
	"waterlily_675",
	"seaweed"
}

for i in ipairs(extra_aliases) do
	flower = extra_aliases[i]
	minetest.register_alias("flowers:flower_"..flower, "flowers:"..flower)
end

-- spawn ABM registrations

plantslib:spawn_on_surfaces({
	spawn_delay = SPAWN_DELAY/2,
	spawn_plants = {
		"flowers:waterlily",
		"flowers:waterlily_225",
		"flowers:waterlily_45",
		"flowers:waterlily_675"
	},
	avoid_radius = 2.5,
	spawn_chance = SPAWN_CHANCE*4,
	spawn_surfaces = {"default:water_source"},
	avoid_nodes = {"group:flower", "group:flora" },
	seed_diff = flowers_seed_diff,
	light_min = 9,
	depth_max = 2,
	random_facedir = {0,3}
})

plantslib:spawn_on_surfaces({
	spawn_delay = SPAWN_DELAY*2,
	spawn_plants = {"flowers:seaweed"},
	spawn_chance = SPAWN_CHANCE*2,
	spawn_surfaces = {"default:water_source"},
	avoid_nodes = {"group:flower", "group:flora"},
	seed_diff = flowers_seed_diff,
	light_min = 4,
	light_max = 10,
	neighbors = {"default:dirt_with_grass"},
	facedir = 1
})

plantslib:spawn_on_surfaces({
	spawn_delay = SPAWN_DELAY*2,
	spawn_plants = {"flowers:seaweed"},
	spawn_chance = SPAWN_CHANCE*2,
	spawn_surfaces = {"default:dirt_with_grass"},
	avoid_nodes = {"group:flower", "group:flora" },
	seed_diff = flowers_seed_diff,
	light_min = 4,
	light_max = 10,
	neighbors = {"default:water_source"},
	ncount = 1,
	facedir = 1
})

plantslib:spawn_on_surfaces({
	spawn_delay = SPAWN_DELAY*2,
	spawn_plants = {"flowers:seaweed"},
	spawn_chance = SPAWN_CHANCE*2,
	spawn_surfaces = {"default:stone"},
	avoid_nodes = {"group:flower", "group:flora" },
	seed_diff = flowers_seed_diff,
	light_min = 4,
	light_max = 10,
	neighbors = {"default:water_source"},
	ncount = 6,
	facedir = 1
})

-- crafting recipes!

minetest.register_craftitem(":flowers:flower_pot", {
	description = "Flower Pot",
	inventory_image = "flowers_flowerpot.png",
})

minetest.register_craft( {
	output = "flowers:flower_pot",
	recipe = {
	        { "default:clay_brick", "", "default:clay_brick" },
	        { "", "default:clay_brick", "" }
	},
})

-- Cotton plants are now provided by the default "farming" mod.
-- old cotton plants -> farming cotton stage 8
-- cotton wads -> string (can be crafted into wool blocks)
-- potted cotton plants -> potted white dandelions

minetest.register_alias("flowers:cotton_plant", "farming:cotton_8") 
minetest.register_alias("flowers:flower_cotton", "farming:cotton_8")
minetest.register_alias("flowers:flower_cotton_pot", "flowers:potted_dandelion_white")
minetest.register_alias("flowers:potted_cotton_plant", "flowers:potted_dandelion_white")
minetest.register_alias("flowers:cotton", "farming:string")
minetest.register_alias("flowers:cotton_wad", "farming:string")

print("[Flowers] Loaded.")
