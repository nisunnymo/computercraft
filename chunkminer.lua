-- set to 5 for bedrock level (5 + 63 for pre 1.18)

MINIMUM_Y = 4
CONTROLLER_ID = 10
STORAGE_CHEST = "dimstorage:dimensional_chest"


function block()
    receiveprotocol = "blocker"
    sendprotocol = "enderturtle"

    local function waitBlock()
        rednet.send(CONTROLLER_ID, "isBlocked", sendprotocol)
        senderId, message = rednet.receive(receiveprotocol, 20)
        print("blocked state: ", message)
        return message
    end

    local function enableBlock()
        if not waitBlock() then
            rednet.send(CONTROLLER_ID, "block", sendprotocol)
        end
    end

    while waitBlock() == true do
        print("waiting 5 sec because waitblock is:", waitBlock())
        sleep(5)
    end

    enableBlock()

end

function unblock()
    sendprotocol = "enderturtle"

    local function disableBlock()
        rednet.send(CONTROLLER_ID, "unblock", sendprotocol)
    end
    disableBlock()
end

function fuel()
    local error = false
    if turtle.getFuelLevel() > 1000 then
        return false
    end

    print("trying to refuel")
    rednet.open("right")
    block()
    rednet.send(CONTROLLER_ID, "fuel", "enderturtle")
    local i = 1
    local chestPlaced = false
    for i = 1, 16, 1 do
        if chestPlaced == false then
            turtle.select(i)
            print("fuel debug 1", i)
            item = turtle.getItemDetail()
            if (turtle.getItemCount(i) ~= 0) and (item["name"] == STORAGE_CHEST) then
                turtle.placeUp()
                chestPlaced = true
            end
            if (i == 16 and chestPlaced == false) then
                error = true
            end
        end
    end
    item, inspect = turtle.inspectUp()
    if (chestPlaced == true) and (inspect["name"] == STORAGE_CHEST) then
        while turtle.getFuelLevel() < 95000 do
            turtle.suckUp(64)
            turtle.refuel(64)
        end
    end
    if chestPlaced == true then
        turtle.drop(64)
        turtle.digUp()
    end
    print("Fuel:", turtle.getFuelLevel())
    unblock()
    rednet.close()
end

function export()
    if turtle.getItemSpace(16) == 64 then
        return false
    end
    print("trying to export")
    rednet.open("right")
    block()
    rednet.send(CONTROLLER_ID, "export", "enderturtle")
    local chestPlaced = false
    for i = 1, 16, 1 do
        if chestPlaced == false then
            turtle.select(i)
            print("export debug 1", i)
            item = turtle.getItemDetail()
            if (turtle.getItemCount(i) ~= 0) and (item["name"] == STORAGE_CHEST) then
                turtle.placeUp()
                chestPlaced = true
            end
            if (i == 16 and chestPlaced == false) then
                error = true
            end
        end
    end
    item, inspect = turtle.inspectUp()
    if (chestPlaced == true) and (inspect["name"] == STORAGE_CHEST) then
        for i = 1, 16, 1 do
            print("exporting!", i)
            turtle.select(i)
            turtle.dropUp()
        end
    end
    if chestPlaced == true then
        turtle.select(1)
        turtle.dropUp()
        turtle.digUp()
    end
    print("Export done!")
    unblock()
    rednet.close()
end

function getLocation()
    local loc = vector.new(gps.locate(5))
    return loc
end

function isNegative(value)
    if value<0 then
        return true
    else
        return false
    end
end

function getChunkAlignment(x,z)
    local current_position = getLocation()
    local target_position = vector.new(0,0,0)

    -- get chunk lowest value by using math.floor function
    -- from minecraft perspective, this is always the most north west corner of the chunk
    target_position.x = math.floor(current_position.x/16)*16
    target_position.z = math.floor(current_position.z/16)*16

    local position_difference = vector.new(0, 0, 0)

    -- calculate the difference between the current position and the target position
    -- these will always be zero or negative
    position_difference.x = current_position.x - target_position.x
    position_difference.z = current_position.z - target_position.z

    -- convert negative values to positive
    if position_difference.x < 0 then
        position_difference.x = position_difference.x * -1
    end

    if position_difference.z < 0 then
        position_difference.z = position_difference.z * -1
    end

    print("to align: x: ", position_difference.x, " z: ", position_difference.z)
    return position_difference
end


function getHeading()
    local loc = getLocation()
    forward()
    local locnew = getLocation()
    turtle.back()

    if locnew.z < loc.z then
        heading = "N"
    elseif locnew.z > loc.z then
        heading = "S"
    elseif locnew.x < loc.x then
        heading = "W"
    elseif locnew.x > loc.x then
        heading = "E"
    end

    print("heading:", heading)
    return heading
end

function setHeading(currentheading, desiredheading)
    if currentheading ~= "N" and currentheading ~= "S" and currentheading ~= "W" and currentheading ~= "E" then
        return false
    elseif desiredheading ~= "N" and desiredheading ~= "S" and desiredheading ~= "W" and desiredheading ~= "E" then
        return false
    end
    while currentheading ~= desiredheading do
        turtle.turnLeft()
        currentheading = getHeading()
    end
    return true
end

function goCorner()
    local heading = getHeading()
    local toalign = getChunkAlignment()
    local loc = getLocation()

    local isznegative = isNegative(loc.z)
    local isxnegative = isNegative(loc.x)

    -- first go SOUTH

    if toalign.z > 0 then
        setHeading(heading, "S")
        print("moving", toalign.z, "blocks", getHeading())
        for i = 1, toalign.z, 1 do
            forward()
        end
    end

    -- now go WEST
    
    if toalign.x > 0 then
        setHeading(getHeading(), "W")
        print("moving", toalign.x, "blocks", getHeading())
        for i = 1, toalign.x, 1 do
            forward()
        end
    end
    setHeading(getHeading(), "N")
    local checkalign = getChunkAlignment()
    if toalign.z == 0 and toalign.x == 0 then
        return true
    else
        return false
    end
end


function forward()
    -- item, inspect = turtle.inspect()
    itemup, inspectup = turtle.inspectUp()
    if (itemup and inspectup["name"] == "minecraft:water") or (itemup and inspectup["name"] == "minecraft:lava") then
        turtle.placeUp()
        turtle.digUp()
    end
    fuel()
    export()
    while not turtle.forward() and turtle.getFuelLevel()>0 do
        turtle.dig()
    end
end
function down()
    item, inspect = turtle.inspectDown()
        if (item and inspect["name"] == "minecraft:water") or (item and inspect["name"] == "minecraft:lava") then
            turtle.placeDown()
        end
    while not turtle.down() and turtle.getFuelLevel()>0 do
        turtle.digDown()
    end
end
-- bedrock up to Y=5 so always substract 5 to get absolute zero at above bedrock level

goCorner()
local loc = getLocation()

remainingy = (loc.y + 63 - y) 

excavatedy = 0
while remainingy>0 do
    print("Y left to excavate: ", remainingy)
    if excavatedy>0 then
        down()
    end
    if (getChunkAlignment().x == 0 and getChunkAlignment().z == 0) then
        setHeading(getHeading(), "N")
        for outer=1,3 do
            for i=1,15 do 
                forward()
            end
            turtle.turnRight()
        end
        for inner=14,1,-1 do
            for i=1,2 do
                for j=inner,1,-1 do
                    forward()
                end
                turtle.turnRight()
            end
        end
    else
        setHeading(getHeading(), "N")
        for inner=1,14,1 do
            for i=1,2 do
                for j=inner,1,-1 do
                    forward()
                end
                turtle.turnLeft()
            end
        end
        for outer=1,3 do
            for i=1,15 do 
                forward()
            end
            turtle.turnLeft()
        end
    end
    excavatedy = excavatedy + 1
    remainingy = remainingy - 1
end
print("excavating finished")-- bedrock up to Y=5 so always substract 5 to get absolute zero at above bedrock level