local blipsArray = {}
local createdTrees = {}
local closestTree = nil
local hasJob = false
local hasVeh = false

function contains(array, item)
    for _, value in ipairs(array) do
        if value == item then
            return true
        end
    end
    return false
end

function createBlipsFromData(dataList)
    for i, data in ipairs(dataList) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.color)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.label)
        EndTextCommandSetBlipName(blip)
        
        table.insert(blipsArray, blip)
    end
end

function deleteCreatedTrees()
    for _, tree in ipairs(createdTrees) do
        if DoesEntityExist(tree) then
            DeleteObject(tree)
        end
    end
    createdTrees = {}
end

local function deleteBlips()
    for _, blip in ipairs(blipsArray) do
        RemoveBlip(blip)
    end
    blipsArray = {}
end

--NoPixel Logic for tree falling...

function bG(a, b, c)
    local d = math.atan2(a, c) * 57.295779513082
    local e = math.atan2(b, math.sqrt(a * a + c * c)) * 57.295779513082
    return {d, e, 0}
end

function hasTreeFallen(entity)
    local rotation = GetEntityRotation(entity, 2)
    local pitch = rotation.x
    
    local fallenThreshold = 60.0 

    return math.abs(pitch) > fallenThreshold
end

function fallTree(entity, instantFall)
    local model = GetEntityModel(entity)
    local minDim, maxDim = GetModelDimensions(model)
    local rotation = GetEntityRotation(entity, 2)
    local initialPitch = rotation[1]
    local startTime = GetGameTimer()

    if instantFall then
        local groundPos = GetOffsetFromEntityInWorldCoords(entity, 0, -maxDim.z, 0)
        local groundRotation = bG(groundPos.x, groundPos.y, groundPos.z)
        SetEntityRotation(entity, groundRotation.x, rotation.y, rotation.z, 2, true)
    else
        Citizen.CreateThread(function()
            while true do
                local currentTime = GetGameTimer()
                local elapsedTime = currentTime - startTime
                initialPitch = initialPitch + elapsedTime / 500

                local offset = GetOffsetFromEntityInWorldCoords(entity, 0, 0, maxDim.z)
                local found, groundZ = GetGroundZFor_3dCoord(offset.x, offset.y, offset.z, false)

                if not found then
                    return
                end

                local pitchChange = elapsedTime / 5 * (initialPitch / 250)
                initialPitch = initialPitch + pitchChange

                SetEntityRotation(entity, initialPitch, rotation.y, rotation.z, 2, true)
                startTime = currentTime

                Citizen.Wait(0)
            end
        end)
    end
end

------

local function interactWithTree(treeEntity)
    local treeCoords = GetEntityCoords(treeEntity)    
    TriggerServerEvent('exter-lumberjack:interactWithTree', treeCoords)
end

RegisterNetEvent('exter-lumberjack:handleTreeInteraction')
AddEventHandler('exter-lumberjack:handleTreeInteraction', function(treeCoords)
    if not hasJob then
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local closestTree = lib.getClosestObject(treeCoords, 2)
    
    local isFallen = false

    if closestTree then
        if not hasTreeFallen(closestTree) then
            fallTree(closestTree, false)
        end
    end
end)

function makeTrees()
    local model = Config.treeModel
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    for index, item in ipairs(Config.trees) do
        local tree = CreateObject(GetHashKey(model), item.coords.x, item.coords.y, item.coords.z - 1, false, false, false)
        FreezeEntityPosition(tree, true) 
        SetEntityAsMissionEntity(tree, true, true)
        table.insert(createdTrees, tree)

        exports.interact:AddLocalEntityInteraction({
            entity = tree,
            id = 'lumberjack_tree'..index, 
            distance = 20.0,
            interactDst = 0.0,
            ignoreLos = true, 
            offset = vec3(0.0, 0.0, 2.0), 
            options = {
                {
                    label = 'Tree',
                    action = function(entity, coords, args)
                    end,
                },
            }
        })
    end

    SetModelAsNoLongerNeeded(model)

end

local function initJob()

    if not hasJob then
        return
    end

    if #createdTrees > 0 then
        return
    end

    local dataList = {
        {coords = Config.getClean, label = "Lumberjack - Process Logs", sprite = 503, scale = 0.8, color = 17},
        {coords = Config.getCleaned, label = "Lumberjack - Get Cleaned Logs", sprite = 504, scale = 0.8, color = 17},
       --[[  {coords = Config.getPlanks, label = "Lumberjack - Get Planks", sprite = 505, scale = 0.8, color = 17}, ]]
        {coords = Config.sand, label = "Lumberjack - Sand Planks", sprite = 505, scale = 0.8, color = 17},
        {coords = Config.finish, label = "Lumberjack - Apply Wood Finish", sprite = 506, scale = 0.8, color = 17},
    }

    for i, tree in ipairs(Config.trees) do
        table.insert(dataList, {
            coords = tree.coords,
            label = 'Tree',
            sprite = 502,
            scale = 0.3,
            color = 17
        })
    end


    makeTrees()
    exports.interact:AddInteraction({
        coords = Config.getClean,
        distance = 100.0,
        interactDst = 5.0,
        id = 'lumberjack_getClean',
        options = {
             {
                label = 'Process Logs',
                action = function(entity, coords, args)
                    TriggerServerEvent("exter-lumberjack:processAllLogs")
                end,
            },
        }
    })


    exports.interact:AddInteraction({
        coords = Config.getCleaned,
        distance = 100.0,
        interactDst = 5.0,
        id = 'lumberjack_getCleaned',
        options = {
            {
                label = 'Logs to Planks',
                action = function(entity, coords, args)
                    TriggerServerEvent("exter-lumberjack:processAllCleanLogs")
                end,
            },
        }
    })

--[[     exports.interact:AddInteraction({
        coords = Config.getPlanks,
        distance = 130.0,
        interactDst = 5.0,
        id = 'lumberjack_getPlanks',
        options = {
             {
                label = 'Get Planks',
                action = function(entity, coords, args)
                end,
            },
        }
    }) ]]

    exports.interact:AddInteraction({
        coords = Config.sand,
        distance = 130.0,
        interactDst = 5.0,
        id = 'lumberjack_sand', 
        options = {
            {
                label = 'Get Sanded Planks',
                action = function(entity, coords, args)
                    TriggerServerEvent("exter-lumberjack:processAllRawPlanks")
                end,
            },
        }
    })

    exports.interact:AddInteraction({
        coords = Config.finish,
        distance = 30.0,
        interactDst = 5.0,
        id = 'lumberjack_finish',
        options = {
            {
                label = 'Apply Wood Finish',
                action = function(entity, coords, args)
                    TriggerServerEvent("exter-lumberjack:processAllSandedPlanks")
                end,
            },
        }
    })

    createBlipsFromData(dataList)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteCreatedTrees()
    end
end)

RegisterNetEvent("exter-lumberjack:Sign", function()
    hasJob = not hasJob
    if hasJob then
        Notify("You're now signed in!", "success")
        initJob()
    else
        Notify("You're now signed out!", "error")
        deleteCreatedTrees()
        deleteBlips()
        exports.interact:RemoveInteraction("lumberjack_finish")
        exports.interact:RemoveInteraction("lumberjack_sand")
        exports.interact:RemoveInteraction("lumberjack_getPlanks")
        exports.interact:RemoveInteraction("lumberjack_getCleaned")
        exports.interact:RemoveInteraction("lumberjack_getClean")
    end
end)

RegisterNetEvent("exter-lumberjack:rentBison", function()
    if not hasJob then
        return
    end

    if hasVeh then
        Notify("You already took a work vehicle today!", "error")
        return
    end

    local spawnPoint = Config.VehCoords
    local m = "Bison"
    if IsAnyVehicleNearPoint(spawnPoint.x, spawnPoint.y,spawnPoint.z, 2.0) then
        Notify("Vehicle Spawn Occupied!", "error")
    else
        exter.Functions.SpawnVehicle(m, function(veh)  
            SetEntityHeading(veh, spawnPoint.w)
            SetVehicleEngineOn(veh, false, false)
            SetVehicleOnGroundProperly(veh)
            SetVehicleNeedsToBeHotwired(veh, false)
                
            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
            SetVehicleDoorsLocked(veh, 1)

            exports["cdn-fuel"]:SetFuel(veh, 100)
            hasVeh = true

        end, spawnPoint, true)
    end
end)

RegisterNetEvent("exter-lumberjack:useAxe", function()

    if not hasJob then
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local closestObject = lib.getClosestObject(playerCoords, 3)
      
    if closestObject ~= nil and contains(createdTrees, closestObject) then

        local isFallen = hasTreeFallen(closestObject)

        local objectCoords = GetEntityCoords(closestObject)
        local heading = GetHeadingFromVector_2d(objectCoords.x - playerCoords.x, objectCoords.y - playerCoords.y)
       

        local animDict = nil
        local animName = nil

        if not isFallen then
            SetEntityHeading(playerPed, heading)
            animDict = "lumberjack@anims";
            animName = "axe_swing";
        else
            animDict = "melee@large_wpn@streamed_core"
            animName = "ground_attack_on_spot"
        end

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(1)
        end

        local axeModel = GetHashKey("w_me_hatchet")
        RequestModel(axeModel)
        while not HasModelLoaded(axeModel) do
            Citizen.Wait(1)
        end

        local axe = CreateObject(axeModel, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        AttachEntityToEntity(axe, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0.0, 0.0, 90.0, 180.0, 180.0, true, true, false, true, 1, true)

        ProgBar("choppingtree", "Chopping tree", 15000, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {animDict = animDict, anim = animName}, function()
            interactWithTree(closestObject)  
            DetachEntity(axe, true, false)
            DeleteObject(axe)
            ClearPedTasks(playerPed)

            if isFallen then
                TriggerServerEvent("exter-lumberjack:chop")
            end
        end, function()
            DetachEntity(axe, true, false)
            DeleteObject(axe)
            ClearPedTasks(playerPed)
        end)
    end
end)
