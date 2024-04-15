local methMakers = {}
local maxMistakes = 2
local progressionGain = { -- How much progression you gain after successful minigame.
    min = 13,
    max = 19,
}
local bagAmounts = { -- checks you have at least 30 empty baggies and rewards a quantity between 18-30.
    min = 18,
    max = 30,
}

AddEventHandler('playerDropped', function()
    if methMakers[source] then
        local entity = methMakers[source].vehicle
        Entity(entity).state:set('methSmoke', nil, true)
        methMakers[source] = nil
    end
end)

RegisterNetEvent('randol_methvan:server:beginMaking', function(netId)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)
    local canContinue = false
    local player = GetPlayer(src)

    if methMakers[src] or not DoesEntityExist(entity) or GetEntityModel(entity) ~= `journey` then 
        return 
    end

    local acetone = itemCount(player, 'acetone')
    local lithium = itemCount(player, 'lithium')
    local baggies = itemCount(player, 'empty_weed_bag')
    
    if acetone > 0 and lithium > 0 and baggies >= bagAmounts.max then
        RemoveItem(player, 'acetone', 1)
        RemoveItem(player, 'lithium', 1)
        canContinue = true 
    end

    if canContinue then
        methMakers[src] = { vehicle = entity, progress = 0, mistakes = 0, }
        Entity(entity).state:set('methSmoke', true, true)
        TriggerClientEvent('randol_methvan:client:startProd', src, methMakers[src])
    else
        DoNotification(src, "You are missing ingredients for this.", "error")
    end
end)

lib.callback.register('randol_methvan:server:updateProg', function(source, netId)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)

    if not methMakers[src] then return false end

    if entity ~= methMakers[src].vehicle then return false end
    
    local player = GetPlayer(src)
    local newProg = math.random(progressionGain.min, progressionGain.max)
    methMakers[src].progress += newProg

    if methMakers[src].progress >= 100 then
        methMakers[src] = nil
        local bags = math.random(bagAmounts.min, bagAmounts.max)
        local baggies = itemCount(player, 'empty_weed_bag')
        if baggies and baggies.amount >= bags then
            RemoveItem(player, 'empty_weed_bag', bags)
            AddItem(player, 'meth', bags)
            DoNotification(src, ('You cooked up a batch of %s bags'):format(bags), 'success')
        end
        TriggerClientEvent('randol_methvan:client:finishProd', src)
        Entity(entity).state:set('methSmoke', nil, true)
        return true
    end

    return methMakers[src]
end)

lib.callback.register('randol_methvan:server:updateMistakes', function(source, netId)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)

    if not methMakers[src] then return false end

    if entity ~= methMakers[src].vehicle then return false end
    
    methMakers[src].mistakes += 1
    
    if methMakers[src].mistakes > maxMistakes then
        methMakers[src] = nil
        TriggerClientEvent('randol_methvan:client:explodeFinish', src)
        Entity(entity).state:set('methSmoke', nil, true)
        return true
    end

    return methMakers[src]
end)

lib.callback.register('randol_methvan:server:cancelProduction', function(source)
    local src = source
    if not methMakers[src] then return false end

    local entity = methMakers[src].vehicle
    Entity(entity).state:set('methSmoke', nil, true)
    methMakers[src] = nil
    return true
end)