local locations = require '@core.data.locations'

local core = exports.core

local playerState = LocalPlayer.state

local changeHandlers = {}
local isVisible = false

function IsMenuVisible()
    return isVisible
end

local function openMenu()
    if isVisible then
        return
    end

    TriggerScreenblurFadeIn(200)

    SendNUIMessage({ action = 'setMenuVisible', data = true })
    SetNuiFocus(true, true)

    isVisible = true
end

local function closeMenu()
    if not isVisible then
        return
    end

    TriggerScreenblurFadeOut(200)

    SendNUIMessage({ action = 'setMenuVisible', data = false })
    SetNuiFocus(false, false)

    isVisible = false
end

local keybind = lib.addKeybind({
    name = 'menu',
    description = 'Open Menu',
    defaultKey = 'K',
    onPressed = function()
        openMenu()
    end
})

local function disableMenu()
    closeMenu()

    if keybind.disabled then
        return
    end

    keybind:disable(true)
end

exports('disableMenu', disableMenu)

exports('closeMenu', closeMenu)

local function enableMenu()
    if not keybind.disabled then
        return
    end

    keybind:disable(false)
end

exports('enableMenu', enableMenu)

RegisterNUICallback('hideMenu', function(_, cb)
    cb(1)

    closeMenu()
end)

---@param mapId string
RegisterNUICallback('useGlobalTeleport', function(mapId, cb)
    cb(1)

    local location = locations[mapId]

    if not location then
        lib.print.error(('Unable to find location: %s'):format(mapId))
        return
    end

    disableMenu()
    core:TeleportToCoords(location.coords, true)
    enableMenu()
end)

---@param mapId string
RegisterNUICallback('spectateGlobalTeleport', function(mapId, cb)
    cb(1)

    local location = locations[mapId]

    if not location then
        lib.print.error(('Unable to find location: %s'):format(mapId))
        return
    end

    disableMenu()
    DoScreenFadeOut(0)
    Wait(500)

    local coords = location.coords

    local camHeight = 80.0 -- how high above the target
    local camDistance = 40.0 -- how far back (for angled view)

    local heading = coords.w or 0.0
    local offsetX = camDistance * math.sin(math.rad(heading))
    local offsetY = camDistance * math.cos(math.rad(heading))

    local camCoords = vec3(
        coords.x - offsetX,
        coords.y - offsetY,
        coords.z + camHeight
    )

    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(cam, coords.x, coords.y, coords.z)
    RenderScriptCams(true, false, 0, true, false)

    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

    exports.ui:setVitalsVisible(false)
    exports.ui:setWatermarkMicVisible(false)
    exports.ui:setTextUI({ title = 'SPECTATING', subtitle = 'CLICK BACKSPACE TO STOP' })

    DoScreenFadeIn(500)

    -- keybind to stop spectating, make player invisible? and invincible?
    CreateThread(function()
        while not playerState.isDead do
            Wait(0)

            DisableAllControlActions(0)

            if IsDisabledControlJustPressed(0, 194) then
                break
            end
        end

        DoScreenFadeOut(500)
        Wait(500)

        DestroyCam(cam, false)
        ClearFocus()
        RenderScriptCams(false, false, 0, true, false)

        exports.ui:setVitalsVisible(true)
        exports.ui:setWatermarkMicVisible(true)
        exports.ui:hideTextUI()

        DoScreenFadeIn(500)
        enableMenu()
    end)
end)

---@param data { mapId: string; isFavorite: boolean }
RegisterNUICallback('favoriteGlobalTeleport', function(data, cb)
    local location = locations[data.mapId]

    if not location then
        lib.print.error(('Unable to find location: %s'):format(data.mapId))
        return cb(false)
    end

    local key = ('tmfrz:teleport_favorited:%s'):format(data.mapId)

    if data.isFavorite then
        SetResourceKvpInt(key, 1)
    else
        DeleteResourceKvp(key)
    end

    cb(true)
end)

---@param gamemode string
RegisterNUICallback('selectGamemode', function(gamemode, cb)
    cb(1)

    if gamemode == 'shooting_scenes_1' then
        exports.ui:notify({ type = 'error', text = 'Gamemode coming soon!' })
        return
    end

    closeMenu()

    exports.gamemodes:enterMode(gamemode)
end)

---@param name string
RegisterNUICallback('spawnGlobalWeapon', function(name, cb)
    cb(1)

    TriggerServerEvent('uis:server:spawnGlobalWeapon', name)
end)

---@param name string
RegisterNUICallback('removeGlobalWeapon', function(name, cb)
    cb(1)

    TriggerServerEvent('uis:server:removeGlobalWeapon', name)
end)

RegisterNUICallback('removeAllGlobalWeapons', function(_, cb)
    cb(1)

    TriggerServerEvent('uis:server:removeAllGlobalWeapons')
end)

---@param weaponHash string
RegisterNetEvent('core:onGiveWeapon', function(weaponHash)
    SendNUIMessage({ action = 'onGiveWeapon', data = weaponHash })
end)

---@param weaponHash string
RegisterNetEvent('core:onRemoveWeapon', function(weaponHash)
    SendNUIMessage({ action = 'onRemoveWeapon', data = weaponHash })
end)

RegisterNetEvent('core:onRemoveAllWeapons', function()
    SendNUIMessage({ action = 'onRemoveAllWeapons', data = {} })
end)

---@param weapons string[]
RegisterNetEvent('core:setWeaponWhitelist', function(weapons)
    SendNUIMessage({ action = 'setWeaponsWhitelist', data = weapons })
end)

RegisterNetEvent('core:resetWeaponWhitelist', function()
    SendNUIMessage({ action = 'resetWeaponsWhitelist', data = {} })
end)

---@param resource string
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then
        return
    end

    for i = 1, #changeHandlers do
        RemoveStateBagChangeHandler(changeHandlers[i])
    end
end)

for k in pairs(locations) do
    local cookie = AddStateBagChangeHandler(('teleport:%s'):format(k), 'global', function(_, _, value)
        SendNUIMessage({
            action = 'setTeleportPlayerCount',
            data = { mapId = k, value = value }
        })
    end)

    changeHandlers[#changeHandlers + 1] = cookie
end

---@param value table<string, number | { playerCount: integer, playerLimit?: integer }>?
---@return table<string, { playerCount: integer, playerLimit?: integer }>
local function normalizeGamemodePortalCounts(value)
    local result = {}

    for id, entry in pairs(value or {}) do
        if type(entry) == 'table' then
            result[id] = {
                playerCount = entry.playerCount or 0,
                playerLimit = entry.playerLimit,
            }
        elseif type(entry) == 'number' then
            result[id] = { playerCount = entry }
        end
    end

    return result
end

local function syncGamemodePlayerCounts(value)
    SendNUIMessage({
        action = 'setGamemodePlayerCounts',
        data = normalizeGamemodePortalCounts(value),
    })
end

changeHandlers[#changeHandlers + 1] = AddStateBagChangeHandler('gamemodePortalCounts', 'global', function(_, _, value)
    syncGamemodePlayerCounts(value)
end)

AddEventHandler('uis:onReady', function()
    syncGamemodePlayerCounts(GlobalState.gamemodePortalCounts)
end)