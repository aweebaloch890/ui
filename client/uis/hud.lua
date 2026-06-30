local utils = require '@core.modules.utils'

local playerState = LocalPlayer.state

local KVP_KEYS = {
    vitalsStyle = 'tmfrz_v5:vitalsStyle',
    showHud = 'tmfrz_v5:showHud',
    hudLocation = 'tmfrz_v5:hudLocation',
    killfeed = 'tmfrz_v5:killfeed',
    healthColor = 'tmfrz_v5:healthColor',
    armorColor = 'tmfrz_v5:armorColor',
    watermark = 'tmfrz_v5:watermark',
    killText = 'tmfrz_v5:killText',
    mic = 'tmfrz_v5:mic',
}

local weaponGroups = {
    [416676503] = 'pistol',
    [970310034] = 'rifle',
    [1159398588] = 'rifle',
    [860033945] = 'rifle',
    [-957766203] = 'rifle',
    [-1212426201] = 'rifle',
    [690389602] = 'pistol',
    [-1569042529] = 'rifle'
}

local isWatermarkEnabled = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.watermark, 'true') == 'true'
local isVitalsEnabled = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.showHud, 'true') == 'true'
local isKillfeedEnabled = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.killfeed, 'true') == 'true'
local hudLocation = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.hudLocation, 'bottom-center')
local healthColor = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.healthColor, '#FC264C')
local armorColor = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.armorColor, '#FFF')
local isMicEnabled = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.mic, 'true') == 'true'
local isKillTextEnabled = utils.safeGetKvp(GetResourceKvpString, KVP_KEYS.killText, 'true') == 'true'
local vitalsStyle = utils.safeGetKvp(GetResourceKvpInt, KVP_KEYS.vitalsStyle, 1)

local wasTalking = false
local lastHealth = nil
local lastArmor = nil

-- Code can show/hide vitals (e.g. loading, transitions). User can disable vitals in settings.
-- Effective = both code and user allow visibility. We only send that to NUI and only run health/armor updates when effective.
local codeVitalsVisible = true

---@return boolean
local function getVitalsEffective()
    return codeVitalsVisible and isVitalsEnabled
end

local function pushVitalsVisible()
    SendNUIMessage({ action = 'setVitalsVisible', data = getVitalsEffective() })
end

---@param value boolean
local function setVitalsVisible(value)
    codeVitalsVisible = value
    pushVitalsVisible()
end

exports('setVitalsVisible', setVitalsVisible)

-- Same two-layer logic as vitals: code can show/hide (e.g. loading), user preference takes priority.
local codeWatermarkMicVisible = true

---@return boolean
local function getWatermarkMicEffective()
    return codeWatermarkMicVisible and (isWatermarkEnabled or isMicEnabled)
end

local function pushWatermarkMicVisible()
    SendNUIMessage({ action = 'setWatermarkMicVisible', data = getWatermarkMicEffective() })
end

---@param value boolean
local function setWatermarkMicVisible(value)
    codeWatermarkMicVisible = value
    pushWatermarkMicVisible()
end

exports('setWatermarkMicVisible', setWatermarkMicVisible)

---@param data table
local function addKillfeed(data)
    if not isKillfeedEnabled then
        return
    end

    SendNUIMessage({ action = 'addKillfeed', data = data })
end

exports('addKillfeed', addKillfeed)
RegisterNetEvent('uis:addKillfeed', addKillfeed)

---@param data table
local function addKillNoti(data)
    if not isKillTextEnabled then
        return
    end

    SendNUIMessage({ action = 'addKillNoti', data = data })
end

exports('addKillNoti', addKillNoti)
RegisterNetEvent('uis:addKillNoti', addKillNoti)

---@param data table
AddEventHandler('core:playerKilled', function(data)
    if GlobalState.disableKillfeed then
        return
    end

    local killer = NetworkGetPlayerIndexFromPed(data.killer)
    local victim = NetworkGetPlayerIndexFromPed(data.victim)

    local killerSrc = GetPlayerServerId(killer)
    local victimSrc = GetPlayerServerId(victim)

    local killerState = Player(killerSrc).state
    local victimState = Player(victimSrc).state

    addKillfeed({
        isHeadshot = data.headshot,
        weaponType = weaponGroups[GetWeapontypeGroup(data.weaponHash)] or 'suicide',
        shouldHighlight = cache.serverId == killerSrc or cache.serverId == victimSrc,
        killer = {
            id = killerState.userId,
            username = killerState.username,
        },
        victim = {
            id = victimState.userId,
            username = victimState.username,
        },
    })

    if cache.serverId == killerSrc then
        addKillNoti({ username = victimState.username })
    end
end)

---@param style number
RegisterNUICallback('changeVitalsStyle', function(style, cb)
    if type(style) == 'number' then
        SetResourceKvpInt(KVP_KEYS.vitalsStyle, style)
        vitalsStyle = style
    end

    cb(true)
end)

---@param value boolean
RegisterNUICallback('toggleHud', function(value, cb)
    SetResourceKvp(KVP_KEYS.showHud, value and 'true' or 'false')

    isVitalsEnabled = value
    pushVitalsVisible()

    cb(true)
end)

---@param value boolean
RegisterNUICallback('toggleKillfeed', function(value, cb)
    SetResourceKvp(KVP_KEYS.killfeed, value and 'true' or 'false')
    isKillfeedEnabled = value

    cb(true)
end)

---@param location string
RegisterNUICallback('changeHudLocation', function(location, cb)
    if type(location) == 'string' then
        SetResourceKvp(KVP_KEYS.hudLocation, location)
    end

    cb(true)
end)

---@param hex string
RegisterNUICallback('changeHealthColor', function(hex, cb)
    if type(hex) == 'string' then
        SetResourceKvp(KVP_KEYS.healthColor, hex)
    end

    cb(true)
end)

---@param hex string
RegisterNUICallback('changeArmorColor', function(hex, cb)
    if type(hex) == 'string' then
        SetResourceKvp(KVP_KEYS.armorColor, hex)
    end

    cb(true)
end)

---@param value boolean
RegisterNUICallback('toggleWatermark', function(value, cb)
    SetResourceKvp(KVP_KEYS.watermark, value and 'true' or 'false')

    isWatermarkEnabled = value
    pushWatermarkMicVisible()

    cb(true)
end)

---@param value boolean
RegisterNUICallback('toggleMicIndicator', function(value, cb)
    SetResourceKvp(KVP_KEYS.mic, value and 'true' or 'false')

    isMicEnabled = value
    pushWatermarkMicVisible()

    cb(true)
end)

---@param value boolean
RegisterNUICallback('toggleKillText', function(value, cb)
    SetResourceKvp(KVP_KEYS.killText, value and 'true' or 'false')
    isKillTextEnabled = value

    cb(true)
end)

RegisterNUICallback('startVitalsPositionCustomize', function(_, cb)
    SetNuiFocus(true, true)

    cb(true)
end)

---@param data table
RegisterNUICallback('endVitalsPositionCustomize', function(data, cb)
    SetNuiFocus(false, false)

    cb(true)
end)

CreateThread(function()
    while not playerState.uisReady do
        Wait(100)
    end

    SendNUIMessage({ action = 'setVitalsStyle', data = math.clamp(vitalsStyle, 1, 6) })

    SendNUIMessage({
        action = 'setHudSettings',
        data = {
            showHud = isVitalsEnabled,
            hudLocation = hudLocation,
            killfeed = isKillfeedEnabled,
            watermark = isWatermarkEnabled,
            mic = isMicEnabled,
            killText = isKillTextEnabled,
            healthColor = healthColor,
            armorColor = armorColor,
        }
    })

    while not playerState.isLoaded do
        Wait(100)
    end

    Wait(1000)

    pushVitalsVisible()
    pushWatermarkMicVisible()

    while true do
        local isTalking = NetworkIsPlayerTalking(cache.playerId)

        if isTalking ~= wasTalking then
            TriggerEvent('ui:onLocalPlayerTalk', isTalking)

            if getWatermarkMicEffective() then
                SendNUIMessage({ action = 'setIsTalking', data = isTalking })
            end

            wasTalking = isTalking
        end

        if getVitalsEffective() then
            local health = lib.math.clamp(GetEntityHealth(cache.ped) - 100, 0, 100)

            if lastHealth ~= health then
                SendNUIMessage({ action = 'setVitalsHealth', data = health })
                lastHealth = health
            end

            local armor = lib.math.clamp(GetPedArmour(cache.ped), 0, 100)

            if lastArmor ~= armor then
                SendNUIMessage({ action = 'setVitalsArmor', data = armor })
                lastArmor = armor
            end
        end

        Wait(100)
    end
end)