local pretty = require("cc.pretty")

local TEMPERATURE_THRESHOLD = 800 --kelvin 
local WASTE_FILLED_PERCENTAGE_THRESHOLD = 90 --percentage
local DAMAGE_PERCENTAGE_THRESHOLD = 50 --percentage
local COOLANT_FILLED_PERCENTAGE_THRESHOLD = 10 --percentage
local HEATED_COOLANT_FILLED_PERCENTAGE_THRESHOLD = 90 --percentage


function temperature_failsafe_check(reactor)
    local temperature = reactor.getTemperature()
    if temperature > TEMPERATURE_THRESHOLD then
        print("Temperature is over ", TEMPERATURE_THRESHOLD, "K!")
        return false
    else
        return true
    end
end

function waste_level_failsafe_check(reactor)
    local waste_percentage = reactor.getWasteFilledPercentage()
    if waste_percentage > WASTE_FILLED_PERCENTAGE_THRESHOLD then
        print("Waste level is over ", WASTE_FILLED_PERCENTAGE_THRESHOLD, "%!")
        return false
    else
        return true
    end
end

function damage_failsafe_check(reactor)
    local damage_percentage = reactor.getDamagePercent()
    if damage_percentage > DAMAGE_PERCENTAGE_THRESHOLD then
        print("Damage is over ", DAMAGE_PERCENTAGE_THRESHOLD, "%!")
        return false
    else
        return true
    end
end

function coolant_level_failsafe_check(reactor)
    local coolant_percentage = reactor.getCoolantFilledPercentage()
    if coolant_percentage < COOLANT_FILLED_PERCENTAGE_THRESHOLD then
        print("Coolant fill level is below ", COOLANT_FILLED_PERCENTAGE_THRESHOLD, "%!")
        return false
    else
        return true
    end
end

function heated_coolant_level_failsafe_check(reactor)
    local heated_coolant_percentage = reactor.getHeatedCoolantFilledPercentage()
    if heated_coolant_percentage > HEATED_COOLANT_FILLED_PERCENTAGE_THRESHOLD then
        print("Heated coolant level is over ", HEATED_COOLANT_FILLED_PERCENTAGE_THRESHOLD, "%!")
        return false
    else
        return true
    end
end

-- failsafe checks, passed if TRUE, failed if FALSE
function failsafe_checks(reactor)
    local temperature_failsafe_passed = temperature_failsafe_check(reactor)
    local waste_failsafe_passed = waste_level_failsafe_check(reactor)
    local damage_failsafe_passed = damage_failsafe_check(reactor)
    local coolant_failsafe_passed = coolant_level_failsafe_check(reactor)
    local heated_coolant_failsafe_passed = heated_coolant_level_failsafe_check(reactor)
    if temperature_failsafe_passed and waste_failsafe_passed and damage_failsafe_passed and coolant_failsafe_passed and heated_coolant_failsafe_passed then
        return true
    else
        return false
    end
end



function check_enable_switch()
    if redstone.getAnalogInput("front") > 0 then
        return true
    else
        return false
    end
end

function main(reactor)
    if not check_enable_switch() then
        reactor.scram()
    else
        if failsafe_checks(reactor) then
            reactor.activate()
        else
            reactor.scram()
        end
end

local reactor = peripheral.wrap("back")

while true do
    main(reactor)
    sleep(0) --we need to make sure we yield some time
end
