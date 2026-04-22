local ITEM = Config.Items

local function processAllItems(src, fromItem, toItem, multiplier)
    multiplier = multiplier or 1

    local totalAmount = GetItemCount(src, fromItem)
    if totalAmount <= 0 then
        Notify(src, ('You do not have any %s to process.'):format(fromItem), 'error')
        return
    end

    local receiveAmount = totalAmount * multiplier
    if not CanCarryItem(src, toItem, receiveAmount) then
        Notify(src, 'Your inventory is full.', 'error')
        return
    end

    if not RemoveItem(src, fromItem, totalAmount) then
        Notify(src, 'Failed to remove required items.', 'error')
        return
    end

    if not AddItem(src, toItem, receiveAmount) then
        AddItem(src, fromItem, totalAmount)
        Notify(src, 'Could not add processed item. Items have been returned.', 'error')
        return
    end

    Notify(src, ('Processed %sx %s into %sx %s.'):format(totalAmount, fromItem, receiveAmount, toItem), 'success')
end

RegisterNetEvent('exter-lumberjack:interactWithTree', function(treeCoords)
    TriggerClientEvent('exter-lumberjack:handleTreeInteraction', -1, treeCoords)
end)

RegisterNetEvent('exter-lumberjack:chop', function()
    local src = source
    if not CanCarryItem(src, ITEM.log, Config.logPerChop) then
        Notify(src, 'Your inventory is full.', 'error')
        return
    end

    if AddItem(src, ITEM.log, Config.logPerChop) then
        Notify(src, 'You received logs.', 'success')
    else
        Notify(src, 'Failed to add logs.', 'error')
    end
end)

RegisterNetEvent('exter-lumberjack:processAllLogs', function()
    processAllItems(source, ITEM.log, ITEM.cleanlog, 1)
end)

RegisterNetEvent('exter-lumberjack:processAllCleanLogs', function()
    processAllItems(source, ITEM.cleanlog, ITEM.rawplank, Config.planksPerLog)
end)

RegisterNetEvent('exter-lumberjack:processAllRawPlanks', function()
    processAllItems(source, ITEM.rawplank, ITEM.sandedplank, 1)
end)

RegisterNetEvent('exter-lumberjack:processAllSandedPlanks', function()
    processAllItems(source, ITEM.sandedplank, ITEM.finishwood, 1)
end)

RegisterNetEvent('exter-lumberjack:sellWood', function()
    local src = source
    local totalWood = GetItemCount(src, ITEM.finishwood)

    if totalWood <= 0 then
        Notify(src, 'You do not have any finish wood to sell.', 'error')
        return
    end

    local totalMoney = totalWood * Config.woodPrice

    if not RemoveItem(src, ITEM.finishwood, totalWood) then
        Notify(src, 'Failed to remove finish wood.', 'error')
        return
    end

    if not AddMoney(GetPlayer(src), totalMoney) then
        AddItem(src, ITEM.finishwood, totalWood)
        Notify(src, 'Failed to pay you. Your items were returned.', 'error')
        return
    end

    if GetResourceState('exter-contacts') == 'started' then
        local amountOfRep = (totalWood / 100) * 0.5
        TriggerEvent('exter-contacts:modifyRepS', src, 'Lumberjack', amountOfRep)
    end

    Notify(src, ('Sold %sx wood for $%s.'):format(totalWood, totalMoney), 'success')
end)

RegisterUseableItem(ITEM.axe, function(src)
    TriggerClientEvent('exter-lumberjack:useAxe', src)
end)
