function failsafe_check(side, name)
    sensor = peripheral.wrap(side)
    if sensor.getAnalogInput("back") > 0 then
        print(name + " failsafe triggered!")
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

temperature = "left"
waste = "top"
damage = "right"

while true do
    temp_sensor = failsafe_check(temperature, "temperature")
    waste_sensor = failsafe_check(waste, "temperature")
    damage_sensor = failsafe_check(damage, "temperature")

    if temp_sensor or waste_sensor or damage_sensor then
        disable_reactor()
    else
        enable_reactor()
    end
end
