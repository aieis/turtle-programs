inv_max = 16

str = textutils.serialize

find_item = function(target_name, start)
   for i = start, inv_max do
      b = turtle.getItemDetail(i)
      if b and b.name == target_name then
         turtle.select(i)
         return i
      end
   end
   return -1
end


find_items = function(target_names, start)
   for i = start, inv_max do
      b = turtle.getItemDetail(i)
      if b and target_names[b.name] then
         print(b.name)
         turtle.select(i)
         return i
      end
   end
   return -1
end

count_total_items = function(target_names)
   total = 0
   ind = find_items(target_names, 1)
   while ind ~= -1 do
      total = total + turtle.getItemCount(ind)
      ind = find_items(target_names, ind + 1)
   end
   return total
end


unload = function(items)
   local ind = find_items(items, 1)
   while ind ~= -1 do
      res, reas = turtle.dropDown()

      if not res then
         return false
      end
      
      ind = find_items(items, ind + 1)
   end
   return true
end


restack = function()
   empty = {}
   for i=1,16 do
      b = turtle.getItemCount(i)
      if b ~= 0 and b ~= 64 then
         table.insert(empty, #empty+1, i)
      end
   end

   for i = 1, #empty do
      print(empty[i])
   end

   for i = 1, #empty do
      sx = empty[i]
      if turtle.getItemDetail(empty[i]) ~= 64 then    
         turtle.select(sx)
         for y = i+1, #empty do
            sy = empty[y]
            if turtle.getItemDetail(sy) ~= 64 then
               turtle.transferTo(sy)
               if turtle.getItemCount(sx) == 0 then
                  break
               end
            end
         end
      end
   end
end

table_cat = function(tables)
   combined = {}
   for _, t in ipairs(tables) do
      for k, v in pairs(t) do
         combined[k] = v
      end
   end
   return combined
end


function refuel()
   turtle.refuel()
   local l = turtle.getFuelLevel()
   print(l)
end


function load_fuel()
   if turtle.getFuelLevel() > 4000 then
      return true
   end

   turtle.suckDown()
   coals = { ["minecraft:charcoal"] = 0}
   local ind = find_items(coals, 1)
   while ind ~= -1 do
      refuel()
      ind = find_items(coals, ind + 1)
   end
end

