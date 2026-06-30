local locations = require '@core.data.locations'
local hopoutsConfig = require '@hopouts.config.shared'

local core = exports.core
local ui = exports.ui

local playerState = LocalPlayer.state

local metadata = {}

---@param name string
---@return string
local function normalizeMapName(name)
    return string.lower(string.gsub(name, '[%s_%-]', ''))
end

---@param a string
---@param b string
---@return boolean
local function mapNamesMatch(a, b)
    local na = normalizeMapName(a)
    local nb = normalizeMapName(b)
    return na == nb
        or string.find(na, nb, 1, true) ~= nil
        or string.find(nb, na, 1, true) ~= nil
end

---@param image? string
---@return string
local function formatLobbyMapImage(image)
    if type(image) ~= 'string' then
        return 'unknown.webp'
    end

    return string.gsub(image, '^locations/', '')
end

---@param label string
---@return boolean
local function hasLobbyLocation(label)
    for locId, locData in pairs(locations) do
        if not locData.disableLobbyUsage and (
            locId == label
            or locData.label == label
            or mapNamesMatch(label, locData.label)
            or mapNamesMatch(label, locId)
        ) then
            return true
        end
    end

    return false
end

---@param key string
---@param value boolean
local function setMetadata(key, value)
    metadata[key] = value
end

---@param key? string
local function clearMetadata(key)
    if key then
        metadata[key] = nil
        return
    end

    metadata = {}
end

local function applyHeadshotState()
    if next(metadata) then
        playerState.criticalHits = not not metadata.headshots
        playerState.useNativeHeadDamage = false
    else
        playerState.criticalHits = true
        playerState.useNativeHeadDamage = false
    end
end

---@param coords vector4
local function teleportIntoLobby(coords)
    if not coords then return end
    ui:disableMenu()
    core:TeleportToCoords(coords, true)
    ui:enableMenu()
end

RegisterNUICallback('getGamemodeMaps', function(data, cb)
    local result = lib.callback.await('uis:server:getGamemodeMaps', false, {
        gamemode = data.gamemode,
        slots = data.slots,
    })
    cb(result or {})
end)

RegisterNUICallback('getFfaMaps', function(_, cb)
    local result = lib.callback.await('uis:server:getFfaMaps', false)
    cb(result or {})
end)

---@param data table
RegisterNUICallback('createLobby', function(data, cb)
    local lobbyMetadata = {
        headshots = data.headshots,
        qPeak = data.qPeak,
    }

    local result, err = lib.callback.await('uis:server:createLobby', false, {
        password = data.password,
        slots = data.slots,
        mapId = data.mapId,
        gamemode = data.gamemode or 'freeroam',
        metadata = lobbyMetadata,
        ffaLocationIndex = data.ffaLocationIndex
    })

    if not result then
        lib.print.error('Unable to create lobby:', err)

        return cb({ success = false, error = err })
    end

    cb({ success = true })

    SendNUIMessage({
        action = 'setMyLobbyId',
        data = result.lobbyId
    })

    SendNUIMessage({
        action = 'setLobbyConfig',
        data = {
            password = data.password or '',
            mapId = data.mapId,
            gamemode = data.gamemode or 'freeroam',
            slots = data.slots,
            metadata = lobbyMetadata,
            isOwner = true,
            ffaLocationIndex = data.ffaLocationIndex,
        }
    })

    SendNUIMessage({ action = 'setSelectedPage', data = 'lobbies-members' })

    for k, v in pairs(lobbyMetadata) do
        setMetadata(k, v)
    end

    applyHeadshotState()
    teleportIntoLobby(result.coords)
end)

RegisterNUICallback('getAllLobbies', function(_, cb)
    local lobbies = lib.callback.await('uis:server:getAllLobbies', false)

    cb(lobbies)
end)

---@param data { password: string, lobbyId: integer }
RegisterNUICallback('joinLobby', function(data, cb)
    local result, err = lib.callback.await('uis:server:joinLobby', false, data.lobbyId, data.password)

    if not result then
        lib.print.error('Unable to join lobby:', err)

        return cb({ success = false, error = err })
    end

    cb({ success = true })

    SendNUIMessage({
        action = 'setMyLobbyId',
        data = result.lobbyId
    })

    SendNUIMessage({ action = 'setSelectedPage', data = 'lobbies-members' })

    for k, v in pairs(result.metadata or {}) do
        setMetadata(k, v)
    end

    applyHeadshotState()
    teleportIntoLobby(result.coords)
end)

RegisterNUICallback('deleteMyLobby', function(_, cb)
    local success, err = lib.callback.await('uis:server:deleteMyLobby', false)

    if not success then
        lib.print.error('Unable to delete lobby:', err)

        return cb({ success = false, error = err })
    end

    cb({ success = true })
end)

RegisterNUICallback('leaveLobby', function(_, cb)
    local success, err = lib.callback.await('uis:server:leaveLobby', false)

    if not success then
        lib.print.error('Unable to leave lobby:', err)

        return cb({ success = false, error = err })
    end

    cb({ success = true })

    clearMetadata()
    applyHeadshotState()
    TriggerEvent('core:client:teleportToSpawn')
end)

RegisterNetEvent('uis:forceRefreshLobbies', function()
    SendNUIMessage({ action = 'forceRefreshLobbies' })
end)

---@param lobbyId integer
---@param playerCount integer
RegisterNetEvent('uis:lobbyPlayerCountUpdated', function(lobbyId, playerCount)
    SendNUIMessage({
        action = 'lobbyPlayerCountUpdated',
        data = { lobbyId = lobbyId, playerCount = playerCount },
    })
end)

RegisterNetEvent('uis:leftLobby', function()
    SendNUIMessage({ action = 'setMyLobbyId', data = nil })
    clearMetadata()
    applyHeadshotState()
end)

---@param players table
RegisterNetEvent('uis:setLobbyPlayers', function(players)
    SendNUIMessage({ action = 'setLobbyPlayers', data = players })
end)

---@param config table
RegisterNetEvent('uis:setLobbyConfig', function(config)
    clearMetadata()

    if type(config.metadata) == 'table' then
        for k, v in pairs(config.metadata) do
            setMetadata(k, v)
        end
    end

    applyHeadshotState()
    SendNUIMessage({ action = 'setLobbyConfig', data = config })
end)

RegisterNetEvent('uis:teleportLobbyPlayers', function(coords)
    teleportIntoLobby(coords)
end)

---@param page string
RegisterNetEvent('uis:setSelectedPage', function(page)
    SendNUIMessage({ action = 'setSelectedPage', data = page })
end)

RegisterNUICallback('lobbiesBrowseMounted', function(_, cb)
    TriggerServerEvent('uis:server:lobbiesBrowseOpened')

    cb(1)
end)

RegisterNUICallback('lobbiesBrowseUnmounted', function(_, cb)
    TriggerServerEvent('uis:server:lobbiesBrowseClosed')

    cb(1)
end)

RegisterNUICallback('getLobbyPlayers', function(_, cb)
    local players = lib.callback.await('uis:server:getLobbyPlayers', false)
    cb(players or {})
end)

---@param data { userId: integer }
RegisterNUICallback('kickLobbyPlayer', function(data, cb)
    local success, err = lib.callback.await('uis:server:kickLobbyPlayer', false, data)
    if not success then
        lib.print.error('kickLobbyPlayer failed:', err)
        return cb({ success = false, error = err })
    end
    cb({ success = true })
end)

---@param data { userId: integer, team: string|nil }
RegisterNUICallback('setPlayerTeam', function(data, cb)
    local success, err = lib.callback.await('uis:server:setPlayerTeam', false, data)
    if not success then
        lib.print.error('setPlayerTeam failed:', err)
        return cb({ success = false, error = err })
    end
    cb({ success = true })
end)

---@param newSlots integer
RegisterNUICallback('setLobbySlots', function(newSlots, cb)
    local success, err = lib.callback.await('uis:server:setLobbySlots', false, newSlots)
    if not success then
        lib.print.error('setLobbySlots failed:', err)
        return cb({ success = false, error = err })
    end
    cb({ success = true })
end)

---@param data { password?: string, slots: integer, mapId: string, gamemode?: string, headshots?: boolean, qPeak?: boolean }
RegisterNUICallback('updateLobbyConfig', function(data, cb)
    local success, err = lib.callback.await('uis:server:updateLobbyConfig', false, {
        password = data.password,
        slots = data.slots,
        mapId = data.mapId,
        gamemode = data.gamemode,
        metadata = {
            headshots = not not data.headshots,
            qPeak = not not data.qPeak,
        },
        ffaLocationIndex = data.ffaLocationIndex
    })

    if not success then
        lib.print.error('updateLobbyConfig failed:', err)
        return cb({ success = false, error = err })
    end

    cb({ success = true })
end)

---@param data { teamA: integer[], teamB: integer[] }
RegisterNUICallback('startLobbyGame', function(data, cb)
    local success, err = lib.callback.await('uis:server:startLobbyGame', false, data)
    if not success and err then
        lib.print.error('startLobbyGame failed:', err)
        return cb({ success = false, error = err })
    end
    cb({ success = success or false })
end)

---@param ownerSource Source
RegisterNetEvent('uis:lobbyDisbanded', function(ownerSource)
    TriggerEvent('core:client:teleportToSpawn')
    clearMetadata()
    applyHeadshotState()

    SendNUIMessage({ action = 'setMyLobbyId', data = nil })

    if ownerSource ~= cache.serverId then
        ui:notify({ type = 'error', text = 'The owner disbanded the lobby' })
        SendNUIMessage({ action = 'lobbyDisbanded' })
    end
end)

CreateThread(function()
    while true do
        if next(metadata) and not metadata.qPeak then
            DisableControlAction(0, 44, true)
        end

        Wait(0)
    end
end)

CreateThread(function()
    while not playerState.uisReady do
        Wait(100)
    end

    local maps = {}

    for k, v in pairs(locations) do
        if not v.disableLobbyUsage then
            maps[#maps + 1] = {
                desc = v.description,
                label = v.label,
                image = v.image,
                id = k
            }
        end
    end

    for mapName, mapData in pairs(hopoutsConfig.maps) do
        if not hasLobbyLocation(mapName) then
            maps[#maps + 1] = {
                desc = ('Ranked map: %s'):format(mapName),
                label = mapName,
                image = formatLobbyMapImage(mapData.image),
                id = mapName,
            }
        end
    end

    SendNUIMessage({
        action = 'setLobbyMaps',
        data = maps
    })
end)