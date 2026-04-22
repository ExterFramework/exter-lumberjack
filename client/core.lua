ClientFramework = {
    name = 'standalone',
    obj = nil,
}

Fuel = {
    system = 'none',
}

local function resourceStarted(name)
    return GetResourceState(name) == 'started'
end

local function detectFramework()
    if Config.Framework ~= 'auto' then
        return string.lower(Config.Framework)
    end

    if resourceStarted('qbx_core') then return 'qbox' end
    if resourceStarted('qb-core') then return 'qbcore' end
    if resourceStarted('es_extended') then return 'esx' end
    return 'standalone'
end

local function initFramework()
    ClientFramework.name = detectFramework()

    if ClientFramework.name == 'qbcore' then
        ClientFramework.obj = exports[(Config.FrameworkFolder.qbcore or 'qb-core')]:GetCoreObject()
    elseif ClientFramework.name == 'qbox' then
        ClientFramework.obj = exports[(Config.FrameworkFolder.qbox or 'qbx_core')]:GetCoreObject()
    elseif ClientFramework.name == 'esx' then
        ClientFramework.obj = exports[(Config.FrameworkFolder.esx or 'es_extended')]:getSharedObject()
    end
end

local function detectFuel()
    if Config.FuelSystem ~= 'auto' then
        return string.lower(Config.FuelSystem)
    end

    if resourceStarted('ox_fuel') then return 'ox_fuel' end
    if resourceStarted('LegacyFuel') then return 'legacyfuel' end
    if resourceStarted('cdn-fuel') then return 'cdn-fuel' end
    if resourceStarted('qb-fuel') then return 'qb-fuel' end

    return 'none'
end

local function initFuel()
    Fuel.system = detectFuel()
end

CreateThread(function()
    initFramework()
    initFuel()
end)

function Notify(msg, typ)
    typ = typ or 'inform'

    if ClientFramework.name == 'qbcore' or ClientFramework.name == 'qbox' then
        ClientFramework.obj.Functions.Notify(msg, typ)
    elseif ClientFramework.name == 'esx' then
        TriggerEvent('esx:showNotification', msg)
    else
        TriggerEvent('chat:addMessage', { args = { '^2Lumberjack', msg } })
    end
end

function TriggerCallback(name, cb, ...)
    if ClientFramework.name == 'qbcore' or ClientFramework.name == 'qbox' then
        ClientFramework.obj.Functions.TriggerCallback(name, cb, ...)
    elseif ClientFramework.name == 'esx' then
        ClientFramework.obj.TriggerServerCallback(name, cb, ...)
    else
        cb(nil)
    end
end

function SetVehicleFuel(vehicle, amount)
    amount = amount or 100

    if Fuel.system == 'legacyfuel' then
        exports['LegacyFuel']:SetFuel(vehicle, amount)
    elseif Fuel.system == 'cdn-fuel' then
        exports['cdn-fuel']:SetFuel(vehicle, amount)
    elseif Fuel.system == 'qb-fuel' then
        exports['qb-fuel']:SetFuel(vehicle, amount)
    elseif Fuel.system == 'ox_fuel' then
        Entity(vehicle).state.fuel = amount
    end
end

function SpawnWorkVehicle(modelName, coords, cb)
    local model = joaat(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    if ClientFramework.name == 'qbcore' or ClientFramework.name == 'qbox' then
        ClientFramework.obj.Functions.SpawnVehicle(modelName, function(veh)
            cb(veh)
        end, coords, true)
        return
    end

    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    cb(veh)
end

function ProgBar(name, label, duration, disableOptions, animOptions, onFinish, onCancel)
    if ClientFramework.name == 'qbcore' or ClientFramework.name == 'qbox' then
        ClientFramework.obj.Functions.Progressbar(name, label, duration, false, true, disableOptions, animOptions, {}, {}, onFinish, onCancel)
        return
    end

    if GetResourceState('esx_progressbar') == 'started' then
        exports['esx_progressbar']:Progressbar(name, duration, {
            FreezePlayer = disableOptions.disableMovement,
            animation = {
                type = 'anim',
                dict = animOptions.animDict,
                lib = animOptions.anim
            },
            onFinish = onFinish,
            onCancel = onCancel
        })
        return
    end

    TaskPlayAnim(PlayerPedId(), animOptions.animDict, animOptions.anim, 8.0, -8.0, duration, 1, 0.0, false, false, false)
    Wait(duration)
    onFinish()
end
