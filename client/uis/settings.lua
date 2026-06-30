local playerState = LocalPlayer.state

local gamechat = exports.gamechat

local KVP_KEYS = {
    fps_booster = 'tmfrz:fps_booster_enabled',
    weather = 'tmfrz:pref_weather',
    hour = 'tmfrz:pref_hour',
    music_volume = 'tmfrz:pref_music_volume',
}

---@type number
local MAX_MUSIC_VOLUME = 0.2
---@type number
local DEFAULT_MUSIC_VOLUME = 0.2

---@type string
local FPS_BOOSTER_MODIFIER = 'yell_tunnel_nodirect'
---@type string
local DEFAULT_WEATHER = 'CLEAR'
---@type number
local preferredHour = 8
---@type string
local preferredWeather = DEFAULT_WEATHER
---@type boolean
local fpsBoosterEnabled = false
---@type number
local musicVolume = DEFAULT_MUSIC_VOLUME

---@param value number
---@return number
local function clampMusicVolume(value)
    if value < 0 then return 0 end
    if value > MAX_MUSIC_VOLUME then return MAX_MUSIC_VOLUME end
    return value
end

---@return number
local function loadMusicVolumeFromKvp()
    local str = GetResourceKvpString(KVP_KEYS.music_volume)
    if str and str ~= '' then
        local v = tonumber(str)
        if v then
            return clampMusicVolume(v)
        end
    end
    return DEFAULT_MUSIC_VOLUME
end

---@return number
local function getMusicVolume()
    return musicVolume
end

exports('getMusicVolume', getMusicVolume)

---@return number hour
local function loadPreferredHourFromKvp()
    local str = GetResourceKvpString(KVP_KEYS.hour)

    if str and str ~= '' then
        local h = tonumber(str)

        if h and h >= 0 and h <= 23 then
            return math.floor(h)
        end
    end

    return 8
end

---@param hour number
local function applyTime(hour)
    if hour < 0 or hour > 23 then
        return
    end

    NetworkOverrideClockTime(hour, 0, 0)
end

---@param weather string
local function applyWeather(weather)
    SetWeatherTypeNow(weather)
	SetWeatherTypePersist(weather)
	SetWeatherTypeNowPersist(weather)
end

--- Temporary / external override — does not write KVP or change preferred values.
---@param hour number
local function setTime(hour)
    applyTime(hour)
end

exports('setTime', setTime)

--- Temporary / external override — does not write KVP or change preferred values.
---@param weather string
local function setWeather(weather)
    applyWeather(weather)
end

exports('setWeather', setWeather)

local function resetWeather()
    applyWeather(preferredWeather)
end

exports('resetWeather', resetWeather)

local function resetTime()
    applyTime(preferredHour)
end

exports('resetTime', resetTime)

---@param weather string
RegisterNUICallback('changeWeather', function(weather, cb)
    preferredWeather = weather
	SetResourceKvp(KVP_KEYS.weather, weather)
    applyWeather(weather)

    cb(true)
end)

---@param hour number
RegisterNUICallback('changeHour', function(hour, cb)
    if hour < 0 or hour > 23 then
        cb(false)
        return
    end

    preferredHour = hour
	SetResourceKvp(KVP_KEYS.hour, tostring(hour))
    applyTime(hour)

    cb(true)
end)

---@param index string
RegisterNUICallback('changeKillEffect', function(index, cb)
    local success = exports.misc:setKillEffect(tonumber(index))

    cb(success)
end)

---@param color string
RegisterNUICallback('changeNameColor', function(color, cb)
    local success = lib.callback.await('ui:server:setNameColor', false, color)

    cb(success)
end)

---@param value boolean
RegisterNUICallback('toggleFpsBooster', function(value, cb)
    if value then
        SetExtraTimecycleModifier(FPS_BOOSTER_MODIFIER)
    else
        ClearExtraTimecycleModifier()
    end

    SetResourceKvpInt(KVP_KEYS.fps_booster, value and 1 or 0)
    fpsBoosterEnabled = value

    cb(true)
end)

---@param value number
RegisterNUICallback('changeMusicVolume', function(value, cb)
    local volume = clampMusicVolume(tonumber(value) or DEFAULT_MUSIC_VOLUME)
    musicVolume = volume
    SetResourceKvp(KVP_KEYS.music_volume, tostring(volume))
    cb(true)
end)

---@param value boolean
RegisterNUICallback('changeTextChatMode', function(value, cb)
    gamechat:setChatState(value, true)

    cb(true)
end)

---@param mode HitMarkerSoundMode
RegisterNUICallback('changeAttackSoundMode', function(mode, cb)
    local success = exports.misc:changeAttackSoundMode(mode)
    cb(success)
end)

---@param volume number
RegisterNUICallback('changeAttackSoundVolume', function(volume, cb)
    local success = exports.misc:changeAttackSoundVolume(volume)
    cb(success)
end)

---@param mode HitMarkerSoundMode
RegisterNUICallback('changeVictimSoundMode', function(mode, cb)
    local success = exports.misc:changeVictimSoundMode(mode)
    cb(success)
end)

---@param volume number
RegisterNUICallback('changeVictimSoundVolume', function(volume, cb)
    local success = exports.misc:changeVictimSoundVolume(volume)
    cb(success)
end)

---@param type HitMarkerDamageType
RegisterNUICallback('changeMarkerDamageType', function(type, cb)
    local success = exports.misc:changeMarkerDamageType(type)
    cb(success)
end)

---@return table[] nameColors
---@return string nameColorForUi
local function fetchNameColors()
    local nameColors, nameColorForUi = lib.callback.await('ui:server:getNameColors', false)
    return nameColors, nameColorForUi
end

RegisterNetEvent('ui:forceRefreshNameColors', function()
    local nameColors = fetchNameColors()
    SendNUIMessage({ action = 'setNameColors', data = nameColors })
end)

CreateThread(function()
    fpsBoosterEnabled = GetResourceKvpInt(KVP_KEYS.fps_booster) == 1

    if fpsBoosterEnabled then
        SetExtraTimecycleModifier(FPS_BOOSTER_MODIFIER)
    end

    preferredWeather = GetResourceKvpString(KVP_KEYS.weather) or DEFAULT_WEATHER
    preferredHour = loadPreferredHourFromKvp()
    musicVolume = loadMusicVolumeFromKvp()

    applyWeather(preferredWeather)
    applyTime(preferredHour)

    while not playerState.uisReady do
        Wait(100)
    end

    local textChatMode = gamechat:getChatStatePreference()

    local nameColors, nameColorForUi = fetchNameColors()
    SendNUIMessage({ action = 'setNameColors', data = nameColors })

    local killEffectOptions = exports.misc:getKillEffectOptions()
    SendNUIMessage({ action = 'setKillEffects', data = killEffectOptions })

    local killEffect = exports.misc:getKillEffect()
    local hitMarkerSettings = exports.misc:getHitMarkerSettings()

    SendNUIMessage({
        action = 'setUserSettings',
        data = {
            streamerMode = false,
            killEffects = tostring(killEffect),
            weather = preferredWeather,
            time = preferredHour,
            fpsBooster = fpsBoosterEnabled,
            nameColor = nameColorForUi,
            textChatMode = textChatMode,
            musicVolume = musicVolume,
            attackHitSoundMode = hitMarkerSettings.attackHitSoundMode,
            attackHitVolume = hitMarkerSettings.attackHitVolume,
            victimHitSoundMode = hitMarkerSettings.victimHitSoundMode,
            victimHitVolume = hitMarkerSettings.victimHitVolume,
            markerDamageType = hitMarkerSettings.markerDamageType,
        }
    })
end)

NetworkOverrideClockMillisecondsPerGameMinute(99999999)