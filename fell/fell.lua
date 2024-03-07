require("utils")

local inv_max = 16
local max_saplings = 64 * 3 - 30

local stop_block = "minecraft:polished_granite"
local target_sapling = "minecraft:oak_sapling"

local tag_log = "minecraft:logs"
local tag_sapling = "minecraft:saplings"

local logs = {
   ["minecraft:oak_log"] = 1
}

local coals = {
   ["minecraft:charcoal"] = 2
}

local saplings = {
   ["minecraft:oak_sapling"] = 3
}

local top_blocks = {
   ["minecraft:polished_granite"]=1,
   ["minecraft:smooth_stone"]=2,
   ["minecraft:polished_diorite"]=3,
   ["minecraft:polished_andesite"]=4
}


local accept = table_cat({logs, coals, saplings})

function load_saplings()
   restack()
   b = true
   while b and count_total_items(saplings) < max_saplings do
      b, reas = turtle.suckDown()
   end
end


function trash()
   local prev_ind = 1
   local ind = find_items(accept, prev_ind)

   while prev_ind < 17 do
      if ind == -1 then
         ind = 16
      end

      if prev_ind + 1 > ind -1 then
         break
      end
      
      for i = prev_ind + 1, ind-1 do
         turtle.select(i)
         turtle.dropDown()
      end
      prev_ind = ind+1
   end
end


function is_log(dir)
   local item = 0
   if dir == 0 then
      b, item = turtle.inspect()
   elseif dir == 1 then
      b, item = turtle.inspectUp()
   elseif dir == 2 then
      b, item = turtle.inspectDown()
   end
   return b and item.tags[tag_log] == true
end


function forward() 
   b, block = turtle.inspect()
   if b and block.tags["minecraft:leaves"] == true then
      turtle.dig()
   end
   turtle.forward()
end


function down()
    b, block = turtle.inspectDown()
    if b and block.tags["minecraft:leaves"] then
        turtle.digDown()
    end
    turtle.down()
end

function up_steps()
   local lsteps = 0
   while is_log(1) do
      turtle.digUp()
      turtle.up()
      lsteps = lsteps + 1
   end
   while lsteps > 0 do
      down()
      lsteps = lsteps - 1
   end
end

function plant_sapling()
   for i = 1, 16 do
      b = turtle.getItemDetail(i)
      if b and b.name == target_sapling then
         turtle.select(i)
         break
      end
   end
   bi = turtle.getSelectedSlot()
   b = turtle.getItemDetail(bi)
   if b and b.name == target_sapling then
      turtle.placeDown()
   end
end

function find_dir()
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
    

function fell_column()
   local steps = 0
   
   repeat
      if is_log(0) then
         turtle.dig()
         turtle.forward()
      elseif is_log(1) then
         up_steps()
      elseif is_log(2) then
         turtle.inspectDown()
         turtle.digDown()
         plant_sapling()
      else
         forward()            
      end
      b, block = turtle.inspect()
   until b and block.name == stop_block    
end

function check_op()
   b, block = turtle.inspectUp()
   if not b then
      return nil
   end

   res = top_blocks[block.name]
   if not res then
      return nil
   end
   
   if res == 1 then
      print("Loading Fuel")
      load_fuel()
   elseif res == 2 then
      print("Unloading")
      unload(logs)
   elseif res == 3 then
      print("Loading Saplings")
      load_saplings()
      print("Loaded Saplings")
   elseif res == 4 then
      print("Trashing")
      trash()
   end

   return res
end

function do_round(gdir)
   local dir = gdir
   repeat
      fell_column()
      res = check_op()
      if dir == 1 then
         turtle.turnLeft()
         forward()
         turtle.turnLeft()
         dir = -1
         
      elseif dir == -1 then
         turtle.turnRight()
         forward()
         turtle.turnRight()
         dir = 1
      end
      res = check_op()
      b, block = turtle.inspect()
      if b and blocklname == stop_block then
         dir = dir * -1
         turtle.turnRight(); turtle.turnRight();
      end
   until res
end

find_elevation = function(stop_block)
   up_steps()
   for i=1,3 do
      plant_sapling()
      turtle.down()
   end
   
   fell_column()
end


function run()
   find_dir()
   find_elevation()
   local gdir = 1
   while 1 do
      local res = do_round(gdir)
      gdir = gdir * -1
   end
end

run()        
