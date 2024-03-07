function find_tag(tag, start)
    for i = start, 16 do
        b = turtle.getItemDetail(i)
        if b and b.tags and b.tags[tag] == true then
            turtle.select(i)
            return i
        end
    end
end

b = turtle.getItemDetail(1)
print(textutils.serialise(b))
     

                                    
