local resourceState = GetResourceState

Framework = {
    name = 'standalone',
    obj = nil,
}

Inventory = {
    name = 'standalone',
}

local function dbg(...)
    if Config.Debug then
        print('[exter-lumberjack]', ...)
    end
end

local function detectFramework()
    if Config.Framework ~= 'auto' then
        return string.lower(Config.Framework)
    end

    if resourceState('qbx_core') == 'started' then
        return 'qbox'
    elseif resourceState('qb-core') == 'started' then
        return 'qbcore'
    elseif resourceState('es_extended') == 'started' then
        return 'esx'
    end

    return 'standalone'
end

local function initFramework()
    Framework.name = detectFramework()

    if Framework.name == 'qbcore' then
        Framework.obj = exports[(Config.FrameworkFolder.qbcore or 'qb-core')]:GetCoreObject()
    elseif Framework.name == 'qbox' then
        Framework.obj = exports[(Config.FrameworkFolder.qbox or 'qbx_core')]:GetCoreObject()
    elseif Framework.name == 'esx' then
        Framework.obj = exports[(Config.FrameworkFolder.esx or 'es_extended')]:getSharedObject()
    end

    dbg('Framework detected:', Framework.name)
end

local function detectInventory()
    if Config.Inventory ~= 'auto' then
        return string.lower(Config.Inventory)
    end

    if resourceState('ox_inventory') == 'started' then return 'ox_inventory' end
    if resourceState('qb-inventory') == 'started' then return 'qb-inventory' end
    if resourceState('qs-inventory') == 'started' then return 'qs-inventory' end
    if resourceState('esx_inventoryhud') == 'started' or resourceState('esx_inventory') == 'started' then return 'esx_inventory' end

    if Framework.name == 'qbcore' or Framework.name == 'qbox' then return 'qb-inventory' end
    if Framework.name == 'esx' then return 'esx_inventory' end

    return 'standalone'
end

local function initInventory()
    Inventory.name = detectInventory()
    dbg('Inventory detected:', Inventory.name)
end

CreateThread(function()
    initFramework()
    initInventory()
end)

function GetPlayer(src)
    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        return Framework.obj.Functions.GetPlayer(src)
    elseif Framework.name == 'esx' then
        return Framework.obj.GetPlayerFromId(src)
    end

    return nil
end

function Notify(src, msg, typ)
    typ = typ or 'inform'
    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        TriggerClientEvent('QBCore:Notify', src, msg, typ)
    elseif Framework.name == 'esx' then
        TriggerClientEvent('esx:showNotification', src, msg)
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^2Lumberjack', msg } })
    end
end

function AddMoney(player, amount)
    if not player or amount <= 0 then return false end

    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        return player.Functions.AddMoney('cash', amount)
    elseif Framework.name == 'esx' then
        player.addMoney(amount)
        return true
    end

    return false
end

function GetItemCount(src, item)
    if Inventory.name == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(src, item) or 0
    end

    local player = GetPlayer(src)
    if not player then return 0 end

    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        local itemData = player.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    elseif Framework.name == 'esx' then
        local invItem = player.getInventoryItem(item)
        return invItem and invItem.count or 0
    end

    return 0
end

function CanCarryItem(src, item, amount)
    if amount <= 0 then return true end

    if Inventory.name == 'ox_inventory' then
        return exports.ox_inventory:CanCarryItem(src, item, amount)
    end

    local player = GetPlayer(src)
    if not player then return false end

    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        return true
    elseif Framework.name == 'esx' then
        if player.canCarryItem then
            return player.canCarryItem(item, amount)
        end
        return true
    end

    return false
end

function AddItem(src, item, amount, info)
    if amount <= 0 then return false end

    if Inventory.name == 'ox_inventory' then
        return exports.ox_inventory:AddItem(src, item, amount, info)
    end

    local player = GetPlayer(src)
    if not player then return false end

    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        return player.Functions.AddItem(item, amount, false, info)
    elseif Framework.name == 'esx' then
        player.addInventoryItem(item, amount)
        return true
    end

    return false
end

function RemoveItem(src, item, amount)
    if amount <= 0 then return false end

    if Inventory.name == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    end

    local player = GetPlayer(src)
    if not player then return false end

    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        return player.Functions.RemoveItem(item, amount)
    elseif Framework.name == 'esx' then
        player.removeInventoryItem(item, amount)
        return true
    end

    return false
end

function RegisterUseableItem(itemName, cb)
    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        Framework.obj.Functions.CreateUseableItem(itemName, cb)
    elseif Framework.name == 'esx' then
        Framework.obj.RegisterUsableItem(itemName, cb)
    end
end

function RegisterCallback(name, fn)
    if Framework.name == 'qbcore' or Framework.name == 'qbox' then
        Framework.obj.Functions.CreateCallback(name, fn)
    elseif Framework.name == 'esx' then
        Framework.obj.RegisterServerCallback(name, fn)
    end
end
