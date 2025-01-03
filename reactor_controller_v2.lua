local pretty = require("cc.pretty")

local TEMPERATURE_THRESHOLD = 800 --kelvin 
local WASTE_FILLED_PERCENTAGE_THRESHOLD = 50 --percentage
local DAMAGE_PERCENTAGE_THRESHOLD = 80 --percentage
local COOLANT_FILLED_PERCENTAGE_THRESHOLD = 50 --percentage
local HEATED_COOLANT_FILLED_PERCENTAGE_THRESHOLD = 50 --percentage

function reactor_peripheral_wrapper()
    local reactor = peripheral.wrap("back")
    while not reactor.isFormed() do
        sleep(0.2)
        reactor = peripheral.wrap("back")
    end
    return reactor
end

function check_reactor_availability(reactor)
    -- most reactor peripheral functions will error if the reactor is not available
    if reactor.isFormed() then 
        
        return true else return false end
end

function temperature_failsafe_check(reactor)
    local temperature = reactor.getTemperature()
    if temperature > TEMPERATURE_THRESHOLD then
        print(string.format("Temperature is %.0fK! (threshold: %.0fK)", temperature, TEMPERATURE_THRESHOLD))
        return false
    else
        return true
    end
end

function waste_level_failsafe_check(reactor)
    local waste_percentage = reactor.getWasteFilledPercentage() * 100
    if waste_percentage > WASTE_FILLED_PERCENTAGE_THRESHOLD then
        print(string.format("Waste level is %.0f%%! (threshold: %.0f%%)", waste_percentage, WASTE_FILLED_PERCENTAGE_THRESHOLD))
        return false
    else
        return true
    end
end

function damage_failsafe_check(reactor)
    local damage_percentage = reactor.getDamagePercent()
    if damage_percentage > DAMAGE_PERCENTAGE_THRESHOLD then
        print(string.format("Damage is %.0f%%! (threshold: %.0f%%)", damage_percentage, DAMAGE_PERCENTAGE_THRESHOLD))
        return false
    else
        return true
    end
end

function coolant_level_failsafe_check(reactor)
    local coolant_percentage = reactor.getCoolantFilledPercentage() * 100
    if coolant_percentage < COOLANT_FILLED_PERCENTAGE_THRESHOLD then
        print(string.format("Coolant fill level is %.0f%%! (threshold: %.0f%%)", coolant_percentage, COOLANT_FILLED_PERCENTAGE_THRESHOLD))
        return false
    else
        return true
    end
end

function heated_coolant_level_failsafe_check(reactor)
    local heated_coolant_percentage = reactor.getHeatedCoolantFilledPercentage() * 100
    if heated_coolant_percentage > HEATED_COOLANT_FILLED_PERCENTAGE_THRESHOLD then
        print(string.format("Heated coolant level is %.0f%%! (threshold: %.0f%%)", heated_coolant_percentage, HEATED_COOLANT_FILLED_PERCENTAGE_THRESHOLD))
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

function activate_reactor(reactor)
    if not reactor.getStatus() then
        print("Enabling reactor!")
        reactor.activate()
    end
end

function deactivate_reactor(reactor)
    if reactor.getStatus() then
        print("Disabling reactor!")
        reactor.scram()
    end
end

function run_reactor()
    local reactor = reactor_peripheral_wrapper()
    if not check_enable_switch() then
        deactivate_reactor(reactor)
    else
        if failsafe_checks(reactor) then
            activate_reactor(reactor)
        else
            deactivate_reactor(reactor)
        end
    end
end

function main()
    while true do
        run_reactor()
        sleep(0) --we need to make sure we yield some time
    end
end

main()