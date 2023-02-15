function init (monitorPeripheralSide, integratorPeripheralSide)
    monitor = peripheral.wrap(monitorPeripheralSide) -- monitor
    ci = peripheral.wrap(integratorPeripheralSide) -- colony integrator
    return monitor, ci
end


function getFirstOrder (colonyIntegrator)
    ci = colonyIntegrator
    workOrders = ci.getWorkOrders()
    if table.getn(workOrders) > 0 then
        orderTable = workOrders[1]
        orderResourcesTable = ci.getWorkOrderResources(order.orderTable["id"])
        builderResources = ci.getBuilderResources(orderTable["builder"]["x"], orderTable["builder"]["y"], orderTable["builder"]["z"])
    end
    return orderTable, orderResourcesTable, builderResources
end

function monitorWrite (monitor, orderTable, orderResourcesTable, builderResources)
    mo = monitor
    mo.clear()
    mo.setCursorPos(0, 0)
    mo.write("Type:", orderTable["workOrderType"], "Name:", orderTable["buildingName"], "Type:", orderTable["type"], "Level:", orderTable["targetLevel"])
    mo.write("Name                " + "Needed", "Delivered")
    for k,v in ipairs(orderResourcesTable) do
        mo.write(orderResourcesTable["displayName"], orderResourcesTable["needed"])
    end
end

mo, ci = init("left", "right")

while true do
    monitorWrite(mo, getFirstOrder())
    sleep(1)
end