local old_ISVehicleMenu_onRemoveBurntVehicle = ISVehicleMenu.onRemoveBurntVehicle
function ISVehicleMenu.onRemoveBurntVehicle(player, vehicle)
    old_ISVehicleMenu_onRemoveBurntVehicle(player, vehicle)

    if not PI2AB.IsAllowed(player) then
        return
    end

    if player and vehicle then
        local square = vehicle:getSquare()
        local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
        if queue then
            local action = PI2ABUtil.GetRemoveBurntVehicleAction(queue)
            if action then
                local beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
                -- action:setOnComplete(transferFromGroundOnCraftComplete, action, player, square)
                action:setOnComplete(PI2ABCore.PutInBagFromGround, action, player, square)

                local timestamp = os.time()
                action.pi2ab_timestamp = timestamp
                PI2ABComparer.create(timestamp, beforeItems)
            end
        end
    end
end