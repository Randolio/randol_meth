local Config = lib.require('shared')
local cacheProd = {}
local ptfx = {}
local makingMeth = false
local cam
local minigame = exports.bl_ui

local function updateTextUI(bool)
    if bool then
        local text = ('**Progress**: %s%s  \n**Mistakes**: %s'):format(cacheProd.progress, '%', cacheProd.mistakes)
        lib.showTextUI(text, { position = 'left-center', } )
    else
        lib.hideTextUI()
    end
end

local function getScale(num)
    local percentage = math.max(num, 10)
    local nearestThreshold
    local minDifference = math.huge

    for threshold, _ in pairs(Config.Minigames) do
        local difference = math.abs(percentage - threshold)
        if difference < minDifference then
            nearestThreshold = threshold
            minDifference = difference
        end
    end

    return Config.Minigames[nearestThreshold].circles, Config.Minigames[nearestThreshold].speed
end

local function handleMinigame()
    local circles, speed = getScale(cacheProd.progress)
    local success = minigame:CircleProgress(circles, speed)
    if success then
        local newData = lib.callback.await('randol_methvan:server:updateProg', false, NetworkGetNetworkIdFromEntity(cache.vehicle))
        if type(newData) == 'table' then
            cacheProd = newData
            updateTextUI(true)
        end
    else
        local newData = lib.callback.await('randol_methvan:server:updateMistakes', false, NetworkGetNetworkIdFromEntity(cache.vehicle))
        if type(newData) == 'table' then
            cacheProd = newData
            updateTextUI(true)
        end
    end
end

local function toggleCam(bool)
    if bool then
        local coords = GetEntityCoords(cache.ped)
        local x, y, z = coords.x + GetEntityForwardX(cache.ped) * 0.9, coords.y + GetEntityForwardY(cache.ped) * 0.9, coords.z + 0.92
        local rot = GetEntityRotation(cache.ped, 2)
        local camRotation = rot + vec3(0.0, 0.0, 175.0)
        cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', x, y, z, camRotation, 70.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, 1, 1)
    else
        if cam then
            RenderScriptCams(false, true, 0, true, false)
            DestroyCam(cam, false)
            cam = nil
        end
    end
end

local function startProd()
    makingMeth = true
    toggleCam(true)
    updateTextUI(true)
    while makingMeth do
        Wait(Config.ProductionInterval)
        if makingMeth then
            handleMinigame()
        end
    end
end

local function cancelProd()
    toggleCam(false)
    makingMeth = false
    table.wipe(cacheProd)
    updateTextUI(false)
end

local function listenForAction()
    if GetEntityModel(cache.vehicle) ~= `journey` then return end

    lib.showTextUI('Press **E** to Make Meth', { position = 'left-center', } )
    Wait(500)
    CreateThread(function()
        while cache.seat == 1 do
            if IsControlJustReleased(0, 38) and not makingMeth then
                TriggerServerEvent('randol_methvan:server:beginMaking', NetworkGetNetworkIdFromEntity(cache.vehicle))
            end
            Wait(0)
        end
        lib.hideTextUI()
    end)
end

local function listenForSeatSwitch()
    if not makingMeth then return end

    local success = lib.callback.await('randol_methvan:server:cancelProduction', false)
    if success then
        cancelProd()
        DoNotification('Production was stopped.', 'error')
    end
end

RegisterNetEvent('randol_methvan:client:startProd', function(data)
    if GetInvokingResource() then return end
    cacheProd = data
    startProd()
end)

RegisterNetEvent('randol_methvan:client:finishProd', function()
    if GetInvokingResource() then return end
    cancelProd()
end)

RegisterNetEvent('randol_methvan:client:explodeFinish', function()
    if GetInvokingResource() then return end
    cancelProd()
    Wait(100)
    DoNotification('Production was stopped.', 'error')
    local vehicle = cache.vehicle
    SetEntityVelocity(vehicle, 0.0, 0.0, 5.0)
    NetworkExplodeVehicle(vehicle, true, false)
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
        if not IsPedAPlayer(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == cache.playerId and (IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim)) and LocalPlayer.state.heistActive then
            if makingMeth then
                local success = lib.callback.await('randol_methvan:server:cancelProduction', false)
                if success then
                    cancelProd()
                    DoNotification('Production was stopped.', 'error')
                end
            end
        end
    end
end)

lib.onCache('seat', function(seat)
    if seat == 1 then
        listenForAction()
    else
        listenForSeatSwitch()
    end
end)

AddStateBagChangeHandler('methSmoke', nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if not entity or not DoesEntityExist(entity) then return end

    if ptfx[entity] then
        RemoveParticleFxFromEntity(entity)
        ptfx[entity] = nil
    end

    if value then
        lib.requestNamedPtfxAsset('core', 5000)
        UseParticleFxAsset('core')
        ptfx[entity] = StartParticleFxLoopedOnEntityBone('exp_grd_bzgas_smoke', entity, 0.0, 0.13, 1.3, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(entity, 'chassis'), 3.0, false, false, false)
        SetParticleFxLoopedAlpha(ptfx[entity], 10.0)
        RemoveNamedPtfxAsset('core')
    end
end)