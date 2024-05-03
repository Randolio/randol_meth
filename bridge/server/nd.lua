if not lib.checkDependency('ND_Core', '2.0.0') then return end

local NDCore = exports['ND_Core']

function GetPlayer(id)
    return NDCore:getPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('ox_lib:notify', src, { type = nType, description = text })
end

function GetPlyIdentifier(player)
    return player?.id
end

function GetSourceFromIdentifier(cid)
    local players = NDCore:getPlayers()
    for _, info in pairs(players) do
        if info.id == cid then
            return info.source
        end
    end
    return false
end

function GetCharacterName(player)
    return player?.fullname
end

function AddItem(player, item, amount)
    exports.ox_inventory:AddItem(player.source, item, amount)
end

function RemoveItem(player, item, amount)
    exports.ox_inventory:RemoveItem(player.source, item, amount)
end

function AddMoney(player, moneyType, amount)
    player.addMoney(moneyType, amount)
end

function itemCount(player, item)
    local count = exports.ox_inventory:GetItemCount(player.source, item)
    return count
end

function itemLabel(item)
    return exports.ox_inventory:Items(item).label
end