local transferOnCraftComplete = function(completedAction)
    if completedAction.pi2ab_timestamp then
        PI2AB.LastMechanicTimestamp = completedAction.pi2ab_timestamp
    end
end

local old_ISVehiclePartMenu_onUninstallPart = ISVehiclePartMenu.onUninstallPart
function ISVehiclePartMenu.onUninstallPart(playerObj, part)
    old_ISVehiclePartMenu_onUninstallPart(playerObj, part)

    if not PI2AB.IsAllowed(playerObj) then
        return
    end

    if playerObj and part then
        local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue
        if queue then
            local action = PI2ABUtil.GetUninstallVehiclePartAction(queue)
            if action then
                action:setOnComplete(transferOnCraftComplete, action)

                local timestamp = os.time()
                action.pi2ab_timestamp = timestamp
                PI2ABComparer.create(timestamp, playerObj:getInventory():getItems())
            end
        end
    end
end
