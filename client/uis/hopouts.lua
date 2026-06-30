local hopouts = exports.hopouts

---@param leftVisible boolean
---@param rightVisible boolean
local function setHopoutsTeammatesVisible(leftVisible, rightVisible)
    SendNUIMessage({
        action = 'setHopoutsTeammatesVisible',
        data = {
            left = leftVisible,
            right = rightVisible,
        }
    })
end

exports('setHopoutsTeammatesVisible', setHopoutsTeammatesVisible)

---@param leftData table
---@param rightData table
local function setHopoutsTeammatesData(leftData, rightData)
    SendNUIMessage({
        action = 'setHopoutsTeammatesData',
        data = {
            left = leftData or {},
            right = rightData or {},
        }
    })
end

exports('setHopoutsTeammatesData', setHopoutsTeammatesData)

---@param isVisible boolean
local function setHopoutsGameStatsVisible(isVisible)
    SendNUIMessage({ action = 'setHopoutsGameStatsVisible', data = isVisible })
end

exports('setHopoutsGameStatsVisible', setHopoutsGameStatsVisible)

---@param isVisible boolean
local function setHopoutsGameStatsTimeFrozen(isVisible)
    SendNUIMessage({ action = 'setHopoutsGameStatsTimeFrozen', data = isVisible })
end

exports('setHopoutsGameStatsTimeFrozen', setHopoutsGameStatsTimeFrozen)

---@param data table
local function setHopoutsGameStatsData(data)
    SendNUIMessage({ action = 'setHopoutsGameStatsData', data = data })
end

exports('setHopoutsGameStatsData', setHopoutsGameStatsData)

---@param isVisible boolean
local function setHopoutsHotbarVisible(isVisible)
    SendNUIMessage({ action = 'setHopoutsHotbarVisible', data = isVisible })
end

exports('setHopoutsHotbarVisible', setHopoutsHotbarVisible)

---@param data table
local function setHopoutsHotbarData(data)
    SendNUIMessage({ action = 'setHopoutsHotbarData', data = data })
end

exports('setHopoutsHotbarData', setHopoutsHotbarData)

---@param isVisible boolean
local function setRifleFfaHotbarVisible(isVisible)
    SendNUIMessage({ action = 'setRifleFfaHotbarVisible', data = isVisible })
end

exports('setRifleFfaHotbarVisible', setRifleFfaHotbarVisible)

---@param data table
local function setRifleFfaHotbarData(data)
    SendNUIMessage({ action = 'setRifleFfaHotbarData', data = data })
end

exports('setRifleFfaHotbarData', setRifleFfaHotbarData)

---@param isVisible boolean
local function setGasMovingVisible(isVisible)
    SendNUIMessage({ action = 'setGasMovingVisible', data = isVisible })
end

exports('setGasMovingVisible', setGasMovingVisible)

---@param isVisible boolean
local function setSpectateVisible(isVisible)
    SendNUIMessage({ action = 'setSpectateVisible', data = isVisible })
end

exports('setSpectateVisible', setSpectateVisible)

---@param data table
local function setSpectateData(data)
    SendNUIMessage({ action = 'setSpectateData', data = data })
end

exports('setSpectateData', setSpectateData)

local scoreboardVisible = false
local hasScoreboardThread = false

---@param isVisible boolean
---@param isWinner boolean
---@param keepControls boolean?
local function setHopoutScoreboardVisible(isVisible, isWinner, keepControls)
    SendNUIMessage({
        action = 'setHopoutScoreboardVisible',
        data = {
            isVisible = isVisible,
            isWinner = isWinner,
        }
    })

    SetNuiFocus(isVisible, isVisible)
    if keepControls then
        SetNuiFocusKeepInput(isVisible)
    end

    if isVisible then
        TriggerScreenblurFadeIn(250)
    else
        if IsScreenblurFadeRunning() then
            DisableScreenblurFade()
        else
            TriggerScreenblurFadeOut(250)
        end
    end

    scoreboardVisible = isVisible

    if scoreboardVisible and not hasScoreboardThread then
        hasScoreboardThread = true
        Citizen.CreateThreadNow(function()
            while scoreboardVisible do
                for i = 1, 6 do
                    DisableControlAction(0, i, true)
                end

                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 257, true)

                Wait(0)
            end

            hasScoreboardThread = false
        end)
    end
end

exports('setHopoutScoreboardVisible', setHopoutScoreboardVisible)

local function setHopoutScoreboardData(data)
    SendNUIMessage({ action = 'setHopoutScoreboardData', data = data})
end

exports('setHopoutScoreboardData', setHopoutScoreboardData)

---@param isVisible boolean
local function setRoundMvpVisible(isVisible)
    SendNUIMessage({ action = 'setRoundMvpVisible', data = isVisible })
end

exports('setRoundMvpVisible', setRoundMvpVisible)

---@param data table
local function setRoundMvpData(data)
    SendNUIMessage({ action = 'setRoundMvpData', data = data })
end

exports('setRoundMvpData', setRoundMvpData)

---@param isVisible boolean
local function setSwitchSizesVisible(isVisible)
    SendNUIMessage({ action = 'setSwitchSizesVisible', data = isVisible })
end

exports('setSwitchSizesVisible', setSwitchSizesVisible)

---@param data table
local function setSwitchSidesData(data)
    SendNUIMessage({ action = 'setSwitchSidesData', data = data })
end

exports('setSwitchSidesData', setSwitchSidesData)

RegisterNUICallback('voteToKick', function(targetUserId, cb)
    TriggerEvent('ui:voteToKickRequested', targetUserId)
    cb(true)
end)

RegisterNUICallback('togglePlayerMute', function(targetUserId, cb)
    local isMuted = hopouts:togglePlayerMute(targetUserId)
    cb(isMuted)
end)

---@param isVisible boolean
local function setCombatReportVisible(isVisible)
    SendNUIMessage({ action = 'setCombatReportVisible', data = isVisible })
end

exports('setCombatReportVisible', setCombatReportVisible)

---@param data table
local function setCombatReportData(data)
    SendNUIMessage({ action = 'setCombatReportData', data = data })
end

exports('setCombatReportData', setCombatReportData)

---@param isVisible boolean
local function setMatchWinnerVisible(isVisible)
    SendNUIMessage({ action = 'setMatchWinnerVisible', data = isVisible })
end

exports('setMatchWinnerVisible', setMatchWinnerVisible)

---@param data table
local function setMatchWinnerData(data)
    SendNUIMessage({ action = 'setMatchWinnerData', data = data })
end

exports('setMatchWinnerData', setMatchWinnerData)

---@param positions table
local function setMatchWinnerPositions(positions)
    SendNUIMessage({ action = 'setMatchWinnerPositions', data = positions })
end

exports('setMatchWinnerPositions', setMatchWinnerPositions)