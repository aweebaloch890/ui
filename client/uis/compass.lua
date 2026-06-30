local env = require '@core.modules.env'

local playerState = LocalPlayer.state

local isVisible = false
local lastHeading = 1

---@param visible boolean
local function setCompassVisible(visible)
    SendNUIMessage({ action = 'setCompassVisible', data = visible })
    isVisible = visible
end

exports('setCompassVisible', setCompassVisible)

---@param heading number
local function setCompassHeading(heading)
    SendNUIMessage({ action = 'setCompassHeading', data = heading })
end

exports('setCompassHeading', setCompassHeading)

CreateThread(function()
    while not playerState.uisReady do
        Wait(100)
    end

    while not playerState.isLoaded do
        Wait(100)
    end

    while true do
        local sleep = 500

        if isVisible then
            sleep = 0

            local camRot = GetGameplayCamRot(0)

            local heading = lib.math.round(360.0 - ((camRot.z + 360.0) % 360.0))
            if heading == 360 then heading = 0 end

            if heading ~= lastHeading then
                setCompassHeading(heading)
            end

            lastHeading = heading
        end

        Wait(sleep)
    end
end)

if env.getEnv() ~= 'development' then
    return
end

RegisterCommand('compass', function()
    setCompassVisible(not isVisible)
end, false)