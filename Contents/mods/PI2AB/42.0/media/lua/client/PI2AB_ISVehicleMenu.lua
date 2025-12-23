local old_ISVehicleMenu_onRemoveBurntVehicle = ISVehicleMenu.onRemoveBurntVehicle
function ISVehicleMenu.onRemoveBurntVehicle(player, vehicle)
    old_ISVehicleMenu_onRemoveBurntVehicle(player, vehicle)

    if not PI2ABUtil.IsAllowed(player) then
        return
    end

    if player and vehicle then
        local square = vehicle:getSquare()
        local queue = ISTimedActionQueue.getTimedActionQueue(player).queue
        if queue then
            local action = PI2ABUtil.GetRemoveBurntVehicleAction(queue)
            if action then
                local beforeItems = PI2ABUtil.GetObjectsOnAndAroundSquare(square)
                action:setOnComplete(PI2ABCore.PutInBagFromGround, action, player, square)

                local pi2ab_timestamp = os.time()
                action.pi2ab_timestamp = pi2ab_timestamp
                PI2ABComparer.create(pi2ab_timestamp, beforeItems)
            end
        end
    end
end