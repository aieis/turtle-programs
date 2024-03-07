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
        prune = {}        
        for y = i+1, #empty do
            sy = empty[y]
            if turtle.getItemDetail(sy) == 64 then
                prune[#prune+1] = y
            else            
                turtle.transferTo(sy)
                if turtle.getItemCount(sx) == 0 then
                    break
                end
            end
        end
        
        for i,v in ipairs(prune) do
            print("Pruning ", v)
        end
    end
end
