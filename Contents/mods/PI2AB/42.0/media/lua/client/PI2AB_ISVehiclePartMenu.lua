
local old_ISVehiclePartMenu_onUninstallPart = ISVehiclePartMenu.onUninstallPart
function ISVehiclePartMenu.onUninstallPart(playerObj, part)
    old_ISVehiclePartMenu_onUninstallPart(playerObj, part)
    if PI2AB.Enabled then
        if not PI2ABUtil.IsAllowed(playerObj) then
            return
        end

        if playerObj and part then
            local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
            if queue then
                local action = PI2ABUtil.GetUninstallVehiclePartAction(queue)
                if action then
                    -- action:setOnComplete(transferOnCraftComplete, action, playerObj,part:getVehicle():getSquare())
                    action:setOnComplete(PI2ABCore.PutInBagFromInventory, action, playerObj, part:getVehicle():getSquare())

                    local pi2ab_timestamp = os.time()
                    action.pi2ab_timestamp = pi2ab_timestamp
                    PI2ABComparer.create(pi2ab_timestamp, playerObj:getInventory():getItems())
                end
            end
        end
    end
end
