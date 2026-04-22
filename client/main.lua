local blipsArray = {}
local createdTrees = {}
local interactionIds = {}

local hasJob = false
local hasVeh = false

local function registerInteractionId(id)
    interactionIds[#interactionIds + 1] = id
end

local function clearInteractions()
    for _, id in ipairs(interactionIds) do
        exports.interact:RemoveInteraction(id)
    end
    interactionIds = {}
end

local function createBlipsFromData(dataList)
    for _, data in ipairs(dataList) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(data.label)
        EndTextCommandSetBlipName(blip)
        blipsArray[#blipsArray + 1] = blip
    end
end

local function deleteBlips()
    for _, blip in ipairs(blipsArray) do
        RemoveBlip(blip)
    end
    blipsArray = {}
end

local function deleteCreatedTrees()
    for _, tree in ipairs(createdTrees) do
        if DoesEntityExist(tree) then
            DeleteObject(tree)
        end
    end
    createdTrees = {}
end

local function hasTreeFallen(entity)
    local pitch = GetEntityRotation(entity, 2).x
    return math.abs(pitch) > (Config.TreeFallThreshold or 60.0)
end

local function fallTree(entity)
    CreateThread(function()
        local maxTicks = 250
        local tick = 0

        while DoesEntityExist(entity) and tick < maxTicks and not hasTreeFallen(entity) do
            local rot = GetEntityRotation(entity, 2)
            SetEntityRotation(entity, rot.x + 0.8, rot.y, rot.z, 2, true)
            Wait(10)
            tick = tick + 1
        end
    end)
end

RegisterNetEvent('exter-lumberjack:handleTreeInteraction', function(treeCoords)
    if not hasJob then return end

    local treeEntity = lib.getClosestObject(treeCoords, 2.5)
    if treeEntity and not hasTreeFallen(treeEntity) then
        fallTree(treeEntity)
    end
end)

local function makeTrees()
    local model = Config.treeModel
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    for index, item in ipairs(Config.trees) do
        local tree = CreateObject(GetHashKey(model), item.coords.x, item.coords.y, item.coords.z - 1, false, false, false)
        FreezeEntityPosition(tree, true)
        SetEntityAsMissionEntity(tree, true, true)
        createdTrees[#createdTrees + 1] = tree

        exports.interact:AddLocalEntityInteraction({
            entity = tree,
            id = ('lumberjack_tree%s'):format(index),
            distance = 20.0,
            interactDst = 0.0,
            ignoreLos = true,
            offset = vec3(0.0, 0.0, 2.0),
            options = {
                {
                    label = 'Tree',
                    action = function() end,
                }
            }
        })
    end

    SetModelAsNoLongerNeeded(model)
end

local function addInteraction(args)
    exports.interact:AddInteraction(args)
    registerInteractionId(args.id)
end

local function initJob()
    if not hasJob or #createdTrees > 0 then return end

    makeTrees()

    addInteraction({
        coords = Config.getClean,
        distance = 100.0,
        interactDst = 5.0,
        id = 'lumberjack_getClean',
        options = {{ label = 'Process Logs', action = function() TriggerServerEvent('exter-lumberjack:processAllLogs') end }}
    })

    addInteraction({
        coords = Config.getCleaned,
        distance = 100.0,
        interactDst = 5.0,
        id = 'lumberjack_getCleaned',
        options = {{ label = 'Logs to Planks', action = function() TriggerServerEvent('exter-lumberjack:processAllCleanLogs') end }}
    })

    addInteraction({
        coords = Config.sand,
        distance = 130.0,
        interactDst = 5.0,
        id = 'lumberjack_sand',
        options = {{ label = 'Get Sanded Planks', action = function() TriggerServerEvent('exter-lumberjack:processAllRawPlanks') end }}
    })

    addInteraction({
        coords = Config.finish,
        distance = 30.0,
        interactDst = 5.0,
        id = 'lumberjack_finish',
        options = {{ label = 'Apply Wood Finish', action = function() TriggerServerEvent('exter-lumberjack:processAllSandedPlanks') end }}
    })

    local blips = {
        {coords = Config.getClean, label = 'Lumberjack - Process Logs', sprite = 503, scale = 0.8, color = 17},
        {coords = Config.getCleaned, label = 'Lumberjack - Get Cleaned Logs', sprite = 504, scale = 0.8, color = 17},
        {coords = Config.sand, label = 'Lumberjack - Sand Planks', sprite = 505, scale = 0.8, color = 17},
        {coords = Config.finish, label = 'Lumberjack - Apply Wood Finish', sprite = 506, scale = 0.8, color = 17}
    }

    for _, tree in ipairs(Config.trees) do
        blips[#blips + 1] = {coords = tree.coords, label = 'Tree', sprite = 502, scale = 0.3, color = 17}
    end

    createBlipsFromData(blips)
end

RegisterNetEvent('exter-lumberjack:Sign', function()
    hasJob = not hasJob

    if hasJob then
        Notify("You're now signed in!", 'success')
        initJob()
        return
    end

    Notify("You're now signed out!", 'error')
    deleteCreatedTrees()
    deleteBlips()
    clearInteractions()
    hasVeh = false
end)

RegisterNetEvent('exter-lumberjack:rentBison', function()
    if not hasJob then return end

    if hasVeh then
        Notify('You already took a work vehicle today!', 'error')
        return
    end

    local spawnPoint = Config.VehCoords
    if IsAnyVehicleNearPoint(spawnPoint.x, spawnPoint.y, spawnPoint.z, 2.0) then
        Notify('Vehicle Spawn Occupied!', 'error')
        return
    end

    SpawnWorkVehicle(Config.VehicleModel or 'bison', spawnPoint, function(veh)
        SetEntityHeading(veh, spawnPoint.w)
        SetVehicleEngineOn(veh, false, false)
        SetVehicleOnGroundProperly(veh)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetVehicleDoorsLocked(veh, 1)

        if GetResourceState('vehiclekeys') == 'started' then
            TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
        end

        SetVehicleFuel(veh, Config.StartFuel or 100)
        hasVeh = true
    end)
end)

RegisterNetEvent('exter-lumberjack:useAxe', function()
    if not hasJob then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestObject = lib.getClosestObject(playerCoords, 3.0)

    if not closestObject then return end

    local validTree = false
    for _, tree in ipairs(createdTrees) do
        if tree == closestObject then
            validTree = true
            break
        end
    end

    if not validTree then return end

    local isFallen = hasTreeFallen(closestObject)
    local objectCoords = GetEntityCoords(closestObject)
    local heading = GetHeadingFromVector_2d(objectCoords.x - playerCoords.x, objectCoords.y - playerCoords.y)

    local animDict = isFallen and 'melee@large_wpn@streamed_core' or 'lumberjack@anims'
    local animName = isFallen and 'ground_attack_on_spot' or 'axe_swing'

    if not isFallen then
        SetEntityHeading(playerPed, heading)
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    local axeModel = joaat('w_me_hatchet')
    RequestModel(axeModel)
    while not HasModelLoaded(axeModel) do Wait(10) end

    local axe = CreateObject(axeModel, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    AttachEntityToEntity(axe, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0.0, 0.0, 90.0, 180.0, 180.0, true, true, false, true, 1, true)

    ProgBar('choppingtree', 'Chopping tree', Config.ChopDurationMs or 15000, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = animDict,
        anim = animName
    }, function()
        TriggerServerEvent('exter-lumberjack:interactWithTree', GetEntityCoords(closestObject))
        DetachEntity(axe, true, false)
        DeleteObject(axe)
        ClearPedTasks(playerPed)

        if isFallen then
            TriggerServerEvent('exter-lumberjack:chop')
        end
    end, function()
        DetachEntity(axe, true, false)
        DeleteObject(axe)
        ClearPedTasks(playerPed)
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    deleteCreatedTrees()
    deleteBlips()
    clearInteractions()
end)
