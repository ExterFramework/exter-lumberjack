if Config.Framework == 'QBCore'then
    exter = exports[Config.FrameworkFolder]:GetCoreObject()
else
    exter = exports[Config.FrameworkFolder]:getSharedObject()
end

function GetPlayer(src)
    if Config.Framework == 'QBCore' then
        return exter.Functions.GetPlayer(src)
    else
        return exter.GetPlayerFromId(src)
    end
end

function Notify(src, msg, typ)
    if Config.Framework == 'QBCore' then
        exter.Functions.Notify(src, msg, typ)
    else
        GetPlayer(src).ShowHelpNotification(msg)
    end
end

function GetItembyName(item, p)
    if Config.Inventory == 'OX' then
        local itemData = exports.ox_inventory:GetItem(p.PlayerData.source, item, nil, true)
        return itemData > 0
    else
        if Config.Inventory == 'qb-inventory' then
            return p.Functions.GetItemByName(item)    
        else
            local hasItem = false 
            for k, v in pairs(exter.PlayerData.inventory) do
                if v.name == item then
                    hasItem = true
                    break
                end
            end
            return hasItem
        end
    end
end

function GetPlayerCID(src)
    if Config.Framework == 'QBCore' then
        return exter.Functions.GetPlayer(src).PlayerData.citizenid
    else
        return exter.GetPlayerFromId(src).identifier
    end
end

function GetPlayerCharName(src)
    local player = GetPlayer(src)
    if Config.Framework == 'QBCore' then
        return player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname
    else
        return player.getName()
    end
end

function RegisterCallback(name, func)
    if Config.Framework == 'QBCore' then
        exter.Functions.CreateCallback(name, func)
    else
        exter.RegisterServerCallback(name, func)
    end
end

function ItemManager(i, a, o, p, info)
    if Config.Framework == 'QBCore' then
        if o == 'remove' then
            p.Functions.RemoveItem(i,a)
        else
            if info then
                p.Functions.AddItem(i,a, nil, info)
            else
                p.Functions.AddItem(i,a)
            end
            
        end
    else
        if o == 'remove' then
            p.removeInventoryItem(i, a)
        else
            p.addInventoryItem(i, a)
        end
    end
end