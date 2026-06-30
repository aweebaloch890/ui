local playerState = LocalPlayer.state

---@param data table
local function setLeaderboardData(data)
    SendNUIMessage({ action = 'setLeaderboardData', data = data })
end

---@param data table
RegisterNetEvent('uis:setInitialLeaderboardData', function(data)
    setLeaderboardData(data)
end)

---@param data table
RegisterNUICallback('getLeaderboardPlayers', function(data, cb)
    local result = lib.callback.await('uis:server:getLeaderboardPlayers', false, data)

    cb(result)
end)

---@param data table
RegisterNUICallback('getLeaderboardGangs', function(data, cb)
    local result = lib.callback.await('uis:server:getLeaderboardGangs', false, data)

    cb(result)
end)

CreateThread(function()
    while not playerState.uisReady do
        Wait(100)
    end

    TriggerServerEvent('uis:server:getInitialLeaderboardData')
end)