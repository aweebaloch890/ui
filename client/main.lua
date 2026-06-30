local locations = require '@core.data.locations'
local locationCategories = require '@core.data.location-categories'

local core = exports.core

local playerState = LocalPlayer.state

playerState:set('uisReady', false, false)

local function fetchAndSetGlobalWeapons()
    ---@type table<string, boolean>
    local allowedAceWeaponNames = lib.callback.await('ui:server:getWhitelistedWeapons', false)

    ---@type table[]
    local list = {}

    for weaponName, weapon in pairs(core:GetWeapons()) do
        if not weapon.ace or allowedAceWeaponNames[weaponName] then
            list[#list + 1] = {
                name = weaponName,
                label = weapon.label,
                type = weapon.type,
                hasAce = not not weapon.ace,
            }
        end
    end

    SendNUIMessage({ action = 'setGlobalWeapons', data = list })
end

RegisterNUICallback('init', function(_, cb)
    cb(1)

    if playerState.uisReady then
        return
    end

    playerState.uisReady = true
    TriggerEvent('uis:onReady')

    lib.print.info('UI initialized')
end)

---@param data table
RegisterNetEvent('core:onCoinsChange', function(data)
    SendNUIMessage({ action = 'setUserCoins', data = data.newAmount })
end)

---@param data table
RegisterNetEvent('ui:addGlobalWeapon', function(data)
    SendNUIMessage({ action = 'addGlobalWeapon', data = data })
end)

RegisterNetEvent('ui:forceRefreshGlobalWeapons', function()
    fetchAndSetGlobalWeapons()
end)

CreateThread(function()
    while not playerState.uisReady do
        Wait(100)
    end

    local teleportsData = {}
    for k, v in pairs(locations) do
        teleportsData[#teleportsData + 1] = {
            isFavorite = GetResourceKvpInt(('tmfrz:teleport_favorited:%s'):format(k)) == 1,
            players = GlobalState[('teleport:%s'):format(k)] or 0,
            description = v.description,
            category = v.category,
            label = v.label,
            image = v.image,
            id = k
        }
    end

    SendNUIMessage({ action = 'setGlobalTeleportCategories', data = locationCategories })
    SendNUIMessage({ action = 'setGlobalTeleports', data = teleportsData })

    fetchAndSetGlobalWeapons()

    while not playerState.isLoaded do
        Wait(100)
    end

    SendNUIMessage({
        action = 'setUserData',
        data = {
            username = PlayerData.username,
            avatar = PlayerData.avatar,
            userId = PlayerData.userId
        }
    })

    SendNUIMessage({ action = 'setUserCoins', data = PlayerData.coins })

    SendNUIMessage({ action = 'setPlayerLoaded', data = true })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        playerState:set('uisReady', false, false)
    end
end)