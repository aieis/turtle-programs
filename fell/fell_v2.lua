require("utils")

local stop_block = "minecraft:polished_granite"
local tag_log = "minecraft:logs"
local target_sapling = "minecraft:oak_sapling"
local tag_sapling = "minecraft:saplings"


find_dir = function(stop_block)
   for i=1, 4 do
      b, bl = turtle.inspect()
      if bl.name == stop_block then
         turtle.turnLeft()
         turtle.turnLeft()
         return
      end
      turtle.turnLeft()
   end
end


has_tag = function(dir, tag)
   local dt = {
      [0]=turtle.inspect,
      [1]=turtle.inspectUp,
      [2]=turtle.inspectDown
   }

   local b, item = dt[dir]()
   return b and item.tags[tag] == true
end


forward = function() 
   if has_tag(0, "minecraft:leaves") then
      turtle.dig()
   end
   return turtle.forward()
end


down = function()
   if has_tag(2, "minecraft:leaves") then
      turtle.digDown()
   end
   return turtle.down()
end


plant_sapling = function()
   local res = find_item(target_sapling, 1)
   if res ~= -1 then
      turtle.select(res)
      turtle.placeDown()
   end
end


up_steps = function()
   local lsteps = 0
   while has_tag(1, tag_log) do
      turtle.digUp()
      turtle.up()
      lsteps = lsteps + 1
   end
   
   while lsteps > 0 do
      down()
      lsteps = lsteps - 1
   end
end


fell_column = function()
   local dt = {
      [0]=function() turtle.dig();turtle.forward() end,
      [1]=function() up_steps() end,
      [2]=function() turtle.digDown(); plant_sapling() end
   }

   local work = function()
      for i=0,2 do
         if has_tag(i, tag_log) then dt[i](); return true end
      end
      return false
   end

   local steps = 0
   while work() do steps = steps + 1 end
   forward()
   return steps > 0
end


find_elevation = function(stop_block)
   local res = turtle.up()
   up_steps()
   if res then turtle.down() end
   fell_column()
end


round = function()
   
   local op_map = {
      ["minecraft:polished_granite"]=load_fuel,
      ["minecraft:smooth_stone"]=unload,
      ["minecraft:polished_diorite"]=load_saplings,
      ["minecraft:polished_andesite"]=trash
   }

   local try_left = function()
      turtle.turnLeft()
      if forward() then
         turtle.turnLeft()
         return true
      end
      return false
   end

   local try_right = function()
      turtle.turnRight()
      if forward() then
         turtle.turnRight()
         return true
      end
      return false
   end

   local turn_map = {
      [1] = try_right,
      [-1] = try_left
   }

   local turn_adjust = {
      [1] = turtle.turnRight,
      [-1] = turtle.turnLeft
   }
   
   local dir = 1
   repeat
      repeat
         fell_column()
         b, block = turtle.inspectUp()
      until b and block.name == stop_block

      if b and op_map[block.name] ~= nil then
         op_map[block.name]()
      end

      local adj = not turn_map[dir]()
      dir = dir * (-1)
   until not adj
   turn_adjust[dir * -1]()
end

run = function ()
   find_dir(stop_block)
   find_elevation()
   while true do
      round()
   end
end

run()
