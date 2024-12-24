receiveprotocol = "blocker"
sendprotocol = "enderturtle"
blocker_id = 16

function printComputerID()
    print("Computer ID: ", os.getComputerID())
end

printComputerID()
peripheral.find("modem", rednet.open)

local blocked = false
local whoBlockedMe = 0

while true do
    protocol = "enderturtle"
    senderId, message = rednet.receive(receiveprotocol)
    print(message)
    if message == "isBlocked" then
        sleep(2)
        rednet.send(senderId, blocked, "blocker")
    end

    if message == "block" then
        blocked = true
        whoBlockedMe = senderId
    end

    if message == "unblock" then
        blocked = false
        whoBlockedMe = 0
    end

    if message == "enableCoal" then
        redstone.setOutput("right", true)
    end
    if message == "disableCoal" then
        redstone.setOutput("right", false)
    end
    if message == "enableExport" then
        redstone.setOutput("left", true)
    end
    if message == "disableExport" then
        redstone.setOutput("left", false)
    end
    if message == "fuel" then
        redstone.setOutput("left", false)
        redstone.setOutput("right", true)
    end
    if message == "export" then
        redstone.setOutput("left", true)
        redstone.setOutput("right", false)
    end
end