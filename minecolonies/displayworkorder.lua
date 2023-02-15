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
        orderResourcesTable = ci.getWorkOrderResources(orderTable["id"])
        builderResources = ci.getBuilderResources(orderTable["builder"])
    end
    return orderTable, orderResourcesTable, builderResources
end

function monitorWrite (monitor, orderTable, orderResourcesTable, builderResources)
    function newline (monitor)
        mo = monitor
        cx, cy = mo.getCursorPos()
        mo.setCursorPos(1, cy + 1)
    end
    mo = monitor
    mo.clear()
    mo.setCursorPos(1, 1)
    mo.write("Type: ".. orderTable["workOrderType"].. " Name: ".. orderTable["buildingName"].. " Type: ".. orderTable["type"].. " Level: ".. orderTable["targetLevel"])
    newline(mo)
    mo.write("Name                ".. "Needed    ".. "Delivered")
    for k,v in ipairs(orderResourcesTable) do
        newline(mo)
        mo.write(v["displayName"].. "    ".. v["needed"])
    end
end

mo, ci = init("left", "right")

while true do
    monitorWrite(mo, getFirstOrder(ci))
    sleep(1)
end