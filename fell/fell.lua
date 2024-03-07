require("utils")

local max_saplings = 64 * 3 - 30

local stop_block = "minecraft:polished_granite"

local tag_log = "minecraft:logs"

Dir = {F = 0, T = 1, B = 2}

local logs = {
   ["minecraft:oak_log"] = 1
}

local coals = {
   ["minecraft:charcoal"] = 2
}

local saplings = {
   ["minecraft:oak_sapling"] = 3
}


local accept = table_cat({logs, coals, saplings})

local function load_saplings()
   restack()
   local b = true
   while b and count_total_items(saplings) < max_saplings do
      b = turtle.suckDown()
   end
   restack()
end


local function trash()
   local prev_ind = 1

   while prev_ind < 17 do
      local ind = find_items(accept, prev_ind)
      if ind == -1 then
         ind = 17
      end

      for i = prev_ind, ind-1 do
         turtle.select(i)
         turtle.dropDown()
      end
      prev_ind = ind+1
   end
end

local function is_log(dir)
   local amap = {
      [Dir.F] = function () return turtle.inspect end,
      [Dir.T] = function () return turtle.inspectUp() end,
      [Dir.B] = function () return turtle.inspectDown() end,
   }

   if amap[dir] then
      local b, item = amap[dir]()
      if b and item and item.tags[tag_log] then return true end
   end
   return false
end


local function forward()
   local b, block = turtle.inspect()
   if b and block.tags["minecraft:leaves"] == true then
      turtle.dig()
   end
   turtle.forward()
end


local function down()
   local b, block = turtle.inspectDown()
   if b and block.tags["minecraft:leaves"] then
      turtle.digDown()
   end
   turtle.down()
end

local function up_steps()
   local lsteps = 0
   while is_log(Dir.T) do
      turtle.digUp()
      turtle.up()
      lsteps = lsteps + 1
   end
   while lsteps > 0 do
      down()
      lsteps = lsteps - 1
   end
end

local function plant_sapling()
   local ind = find_items(saplings, 1)
   if ind ~= -1 then
      turtle.placeDown()
   end
end

local function find_dir()
    for _=1, 4 do
       local _, bl = turtle.inspect()
       if bl.name == stop_block then
          turtle.turnLeft()
          turtle.turnLeft()
          return
       end
       turtle.turnLeft()
    end
end


local function fell_column()
   local operations = {
      [Dir.F] = function () turtle.dig() turtle.forward() end,
      [Dir.T] = up_steps,
      [Dir.B] = function() turtle.digDown() plant_sapling() end,
   }

   repeat
      local cond = false
      for dir, op in ipairs(operations) do
         cond = is_log(dir)
         if cond then op() break end
      end
      if not cond then forward() end
      local b, block = turtle.inspect()
   until b and block.name == stop_block
end

local function block_operations()
   local top_blocks = {
      ["minecraft:polished_granite"] = load_fuel,
      ["minecraft:smooth_stone"] = unload,
      ["minecraft:polished_diorite"] = load_saplings,
      ["minecraft:polished_andesite"] = trash
   }

   local b, block = turtle.inspectUp()

   if b and block and top_blocks[block.name] then
      top_blocks[block.name]()
      return true
   end
   return false
end

local function do_round()
   local left = true
   repeat
      fell_column()

      local uturn = left and turtle.turnLeft or turtle.turnRight

      uturn()
      forward()
      uturn()

      left = not left
      local res = block_operations()
   until res
end

local function find_elevation()
   plant_sapling()
   up_steps()
   for _=1,3 do
      plant_sapling()
      turtle.down()
   end

   fell_column()
end

local function run()
   find_dir()
   find_elevation()
   while 1 do
      do_round()
      os.sleep(2)
   end
end

run()
