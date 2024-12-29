function failsafe_check(side, name)
    -- sensor = peripheral.wrap(side)
    if redstone.getAnalogInput(side) > 0 then
        print(name, " failsafe triggered!")
        return true
    end
end

function enable_reactor()
    if not get_reactor_switch_state() then
        print("enabling reactor!")
        redstone.setAnalogOutput("back", 15)
    end
end

function disable_reactor()
    if get_reactor_switch_state() then
        print("disabling reactor!")
        redstone.setAnalogOutput("back", 0)
    end
end

function get_reactor_switch_state()
    if (redstone.getAnalogOutput("back") > 0) then
        return true
    end
end

while true do
    temp_sensor = failsafe_check("left", "temperature")
    waste_sensor = failsafe_check("top", "waste")
    damage_sensor = failsafe_check("right", "damage")

    if redstone.getAnalogInput("front") > 0 and not (temp_sensor or waste_sensor or damage_sensor) then
        enable_reactor()
    else
        disable_reactor()
    end
    sleep(0) --we need to make sure we yield some time
end
