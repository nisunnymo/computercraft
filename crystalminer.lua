function ins()
    s, t = turtle.inspect()
    return t.name 
end
   
function retItems()
    for i=1,3 do
        turtle.select(i)
        turtle.dropDown()
    end
end
   
function doirun()
    if redstone.getAnalogInput("back") > 14 then
        return true
    else
        return false
    end
end
      
while true do 
    turtle.select(1)
    if (ins() == "ae2:quartz_cluster" and doirun()) then
        print("digging ", t.name)
        turtle.dig()
        retItems() 
    else
        print("sleeping")
        sleep(1)
    end
end