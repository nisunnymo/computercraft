local spawner = peripheral.wrap("redstone_relay_2")
-- slaughter_factory is left of the computer - no relay required
local crusher = peripheral.wrap("redstone_relay_3")
local slaugher_factory_switch = peripheral.wrap("redstone_relay_6")
local crusher_switch = peripheral.wrap("right")
local spawner_switch = peripheral.wrap("redstone_relay_5")

if not spawner or not crusher or not slaugher_factory_switch or not crusher_switch or not spawner_switch then
    error("One of the peripherals is not connected. Please check the wiring.")
    print("Peripherals connected:")
    for _, name in ipairs(peripheral.getNames()) do
        print(name)
    end
else
    print("All peripherals are connected successfully.")
end

while true do
    if redstone.getAnalogInput("front") > 0 then
        print("enabling spawner from ae2 input")
        -- enabling spawner from ae2 redstone input
        spawner.setEnabled("top", true)
        redstone.setAnalogOutput("left", 15)
        crusher.setEnabled("right", false)
    elseif slaugher_factory_switch.getInput("front") then
        -- enabling slaughter factory from manual input
        print("enabling crusher from manual input")
        spawner.setEnabled("top", true)
        redstone.setAnalogOutput("left", 15)
        crusher.setEnabled("right", false)
    elseif crusher_switch.getInput("front") then
        -- enabling crusher from manual input
        print("enabling crusher from manual input")
        spawner.setEnabled("top", true)
        crusher.setEnabled("right", true)
        redstone.setAnalogOutput("left", 0)
    elseif spawner_switch.getInput("front") then
        -- enabling spawner only from manual input
        print("enabling spawner only from manual input")
        spawner.setEnabled("top", true)
        redstone.setAnalogOutput("left", 0)
        crusher.setEnabled("right", false)
    else
        -- disabling everything
        spawner.setEnabled("top", false)
        redstone.setAnalogOutput("left", 0)
        crusher.setEnabled("right", false)
    end
    sleep(0.5) -- wait for 0.5 second before checking again
end