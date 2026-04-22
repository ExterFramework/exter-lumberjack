if Config.Framework == 'QBCore'then
    exter = exports[Config.FrameworkFolder]:GetCoreObject()
else
    exter = exports[Config.FrameworkFolder]:getSharedObject()
end

RegisterNetEvent('exter-lumberjack:interactWithTree')
AddEventHandler('exter-lumberjack:interactWithTree', function(treeCoords)
    TriggerClientEvent('exter-lumberjack:handleTreeInteraction', -1, treeCoords)
end)

RegisterNetEvent('exter-lumberjack:chop', function()
    local src = source
    local Player = exter.Functions.GetPlayer(src)

    if Player.Functions.AddItem('log', Config.logPerChop) then
        TriggerClientEvent('QBCore:Notify', source, 'You received a log!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Your inventory is full!', 'error')
    end
end)

local function processAllItems(player, itemName, newItemName, multiplier)
    multiplier = multiplier or 1
    local totalAmount = 0
    local inventory = player.PlayerData.items

    for _, item in pairs(inventory) do
        if item and item.name == itemName then
            totalAmount = totalAmount + item.amount
        end
    end

    if totalAmount > 0 then
        local removed = 0
        for _, item in pairs(inventory) do
            if item and item.name == itemName then
                if player.Functions.RemoveItem(itemName, item.amount) then
                    removed = removed + item.amount
                else
                    break
                end
            end
        end

        if removed == totalAmount then
            local newItemsAmount = totalAmount * multiplier

            if player.Functions.AddItem(newItemName, newItemsAmount) then
                TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'All ' .. itemName .. ' processed into ' .. newItemName .. '.', 'success')
            else
                player.Functions.AddItem(itemName, removed)
                TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'Your inventory is full!', 'error')
            end
        else
            if removed > 0 then
                player.Functions.AddItem(itemName, removed)
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'You do not have any ' .. itemName .. ' to process!', 'error')
    end
end

RegisterNetEvent('exter-lumberjack:processAllLogs', function()
    local src = source
    local Player = exter.Functions.GetPlayer(src)
    processAllItems(Player, 'log', 'cleanlog')
end)

RegisterNetEvent('exter-lumberjack:processAllCleanLogs', function()
    local src = source
    local Player = exter.Functions.GetPlayer(src)
    processAllItems(Player, 'cleanlog', 'rawplank', Config.planksPerLog)
end)

RegisterNetEvent('exter-lumberjack:processAllRawPlanks', function()
    local src = source
    local Player = exter.Functions.GetPlayer(src)
    processAllItems(Player, 'rawplank', 'sandedplank')
end)

RegisterNetEvent('exter-lumberjack:processAllSandedPlanks', function()
    local src = source
    local Player = exter.Functions.GetPlayer(src)
    processAllItems(Player, 'sandedplank', 'finishwood')
end)

RegisterNetEvent('exter-lumberjack:sellWood', function()
    local src = source
    local Player = exter.Functions.GetPlayer(src)
    local woodPrice = Config.woodPrice
    local totalWood = 0
    local inventory = Player.PlayerData.items 

    for _, item in pairs(inventory) do
        if item and item.name == 'finishwood' then
            totalWood = totalWood + item.amount
        end
    end

    if totalWood > 0 then
        local totalMoney = totalWood * woodPrice
        local removed = 0

        for _, item in pairs(inventory) do
            if item and item.name == 'finishwood' then
                if Player.Functions.RemoveItem('finishwood', item.amount) then
                    removed = removed + item.amount
                else
                    break
                end
            end
        end

        if removed == totalWood then
            Player.Functions.AddMoney('cash', totalMoney)

            local amountOfRep = (totalWood / 100) * 0.5
            TriggerEvent("exter-contacts:modifyRepS", src, "Lumberjack", amountOfRep)

            TriggerClientEvent('QBCore:Notify', src, 'Sold all finish wood for $' .. totalMoney, 'success')
        else
            if removed > 0 then
                Player.Functions.AddItem('finishwood', removed)
                TriggerClientEvent('QBCore:Notify', src, 'Something went wrong! Returned your wood.', 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have any finish wood to sell!', 'error')
    end
end)


if Config.Framework == 'QBCore' then
    exter.Functions.CreateUseableItem('axe', function(source)
        TriggerClientEvent('exter-lumberjack:useAxe', source)
    end)
else
    exter.RegisterUsableItem('axe', function(source)
        TriggerClientEvent('exter-lumberjack:useAxe', source)
    end)
end