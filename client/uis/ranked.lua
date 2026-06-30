local playerState = LocalPlayer.state

local shop = exports.shop
local ranked = exports.ranked

local isVisible = false

local function refreshRankedMenuData()
    TriggerEvent('ui:rankedMenuOpened')
    TriggerServerEvent('ranked:server:fetchInitialData')
end

function IsRankedMenuVisible()
    return isVisible
end

exports('isRankedMenuVisible', IsRankedMenuVisible)

local function openRankedMenu()
    if isVisible then
        refreshRankedMenuData()
        return
    end

    SendNUIMessage({ action = 'setRankedMenuVisible', data = true })
    SendNUIMessage({ action = 'setEmotesKeyBind', data = GetEmotesKeybind() })
    SendNUIMessage({ action = 'setCancelEmotesKeyBind', data = shop:GetEmoteCancelKeyBind() })

    SetNuiFocus(true, true)
    refreshRankedMenuData()

    isVisible = true
end

exports('openRankedMenu', openRankedMenu)

local function closeRankedMenu()
    if not isVisible then
        return
    end

    exports.shop:stopPreview(false)

    SendNUIMessage({ action = 'setRankedMenuVisible', data = false })
    SetNuiFocus(false, false)

    isVisible = false
end

exports('closeRankedMenu', closeRankedMenu)

---@param visible boolean
local function setRankedUpVisible(visible)
    SendNUIMessage({ action = 'setRankedUpVisible', data = visible })
end

exports('setRankedUpVisible', setRankedUpVisible)

---@param data table
local function setRankedUpData(data)
    SendNUIMessage({ action = 'setRankedUpData', data = data })
end

exports('setRankedUpData', setRankedUpData)

---@param data FriendData[]
local function setFriends(data)
    SendNUIMessage({ action = 'setFriends', data = data})
end

exports('setFriends', setFriends)

---@param data FriendData[]
local function setRecentlyPlayed(data)
    SendNUIMessage({ action = 'setRecentlyPlayed', data = data})
end

exports('setRecentlyPlayed', setRecentlyPlayed)

---@param data FriendData[]
local function setIncomingFriendRequests(data)
    SendNUIMessage({ action = 'setIncomingFriendRequests', data = data })
end

exports('setIncomingFriendRequests', setIncomingFriendRequests)

---@param data FriendData[]
local function setOutgoingFriendRequests(data)
    SendNUIMessage({ action = 'setOutgoingFriendRequests', data = data })
end

exports('setOutgoingFriendRequests', setOutgoingFriendRequests)

---@param data FriendData
local function addOutgoingFriendRequest(data)
    SendNUIMessage({ action = 'addOutgoingFriendRequest', data = data })
end

exports('addOutgoingFriendRequest', addOutgoingFriendRequest)

---@param data FriendData
local function addIncomingFriendRequest(data)
    SendNUIMessage({ action = 'addIncomingFriendRequest', data = data })
end

exports('addIncomingFriendRequest', addIncomingFriendRequest)

---@param data table
local function setOutboundFriendAccepted(data)
    SendNUIMessage({ action = 'setOutboundFriendAccepted', data = data })
end

exports('setOutboundFriendAccepted', setOutboundFriendAccepted)

---@param data table
local function setInboundFriendAccepted(data)
    SendNUIMessage({ action = 'setInboundFriendAccepted', data = data })
end

exports('setInboundFriendAccepted', setInboundFriendAccepted)

---@param userId number
local function removeOutgoingFriendRequest(userId)
    SendNUIMessage({ action = 'removeOutgoingFriendRequest', data = userId })
end

exports('removeOutgoingFriendRequest', removeOutgoingFriendRequest)

---@param userId number
local function removeIncomingFriendRequest(userId)
    SendNUIMessage({ action = 'removeIncomingFriendRequest', data = userId })
end

exports('removeIncomingFriendRequest', removeIncomingFriendRequest)

---@param userId number
local function removeFriend(userId)
    SendNUIMessage({ action = 'removeFriend', data = userId })
end

exports('removeFriend', removeFriend)

---@param userId number
local function setFriendOffline(userId)
    SendNUIMessage({ action = 'setFriendOffline', data = userId })
end

exports('setFriendOffline', setFriendOffline)

---@param userId number
local function setFriendOnline(userId)
    SendNUIMessage({ action = 'setFriendOnline', data = userId })
end

exports('setFriendOnline', setFriendOnline)

---@param data FriendPresenceUpdateData[]
local function updateFriendsPresence(data)
    SendNUIMessage({ action = 'updateFriendsPresence', data = data })
end

exports('updateFriendsPresence', updateFriendsPresence)

---@param status 'online' | 'invisible' | 'dnd'
local function setRankedPresenceStatus(status)
    SendNUIMessage({ action = 'setRankedPresenceStatus', data = status })
end

exports('setRankedPresenceStatus', setRankedPresenceStatus)

---@param data FriendData[]
local function setBlockedUsers(data)
    SendNUIMessage({ action = 'setBlockedUsers', data = data })
end

exports('setBlockedUsers', setBlockedUsers)

---@param data table
local function blockedByUser(data)
    SendNUIMessage({ action = 'blockedByUser', data = data })
end

exports('blockedByUser', blockedByUser)

---@param data table
local function setRankedPartyData(data)
    SendNUIMessage({ action = 'setRankedPartyData', data = data })
end

exports('setRankedPartyData', setRankedPartyData)

---@param gameModes GameModeData[]
local function setRankedGameModes(gameModes)
    SendNUIMessage({ action = 'setRankedGameModes', data = gameModes })
end

exports('setRankedGameModes', setRankedGameModes)

---@param visible boolean
local function setMatchFoundVisible(visible)
    SendNUIMessage({ action = 'setMatchFoundVisible', data = visible })
end

exports('setMatchFoundVisible', setMatchFoundVisible)

---@param data table
local function setMatchFoundData(data)
    SendNUIMessage({ action = 'setMatchFoundData', data = data })
end

exports('setMatchFoundData', setMatchFoundData)

---@param visible boolean
local function setMatchAcceptVisible(visible)
    SendNUIMessage({ action = 'setMatchAcceptVisible', data = visible })
end

exports('setMatchAcceptVisible', setMatchAcceptVisible)

---@param data table
local function setMatchAcceptData(data)
    SendNUIMessage({ action = 'setMatchAcceptData', data = data })
end

exports('setMatchAcceptData', setMatchAcceptData)

---@param visible boolean
local function setMapBanVisible(visible)
    SendNUIMessage({ action = 'setMapBanVisible', data = visible })
end

exports('setMapBanVisible', setMapBanVisible)

---@param data table
local function setMapBanData(data)
    SendNUIMessage({ action = 'setMapBanData', data = data })
end

exports('setMapBanData', setMapBanData)

---@param data table
local function setPartyPositions(data)
    SendNUIMessage({ action = 'setPartyPositions', data = data })
end

exports('setPartyPositions', setPartyPositions)

---@param data table
local function setPartyInvite(data)
    if data then
        SendNUIMessage({ action = 'setPartyInviteVisible', data = true})
        SendNUIMessage({ action = 'setPartyInviteData', data = data})
    else
        SendNUIMessage({ action = 'setPartyInviteVisible', data = false})
    end
end

exports('setPartyInvite', setPartyInvite)

---@param data table
local function setFriendInviteStatus(data)
    SendNUIMessage({ action = 'setFriendInviteStatus', data = data })
end

exports('setFriendInviteStatus', setFriendInviteStatus)

RegisterNUICallback('acceptRankedMatch', function(_, cb)
    if not isVisible then
        cb(false)
        return
    end

    TriggerServerEvent('ranked:server:acceptMatch')

    cb(true)
end)

---@param data { userId?: number, username?: string }
RegisterNUICallback('sendFriendRequest', function(data, cb)
    if not isVisible then
        cb(false)
        return
    end

    local result, err = lib.callback.await('ranked:server:sendFriendRequest', false, data)

    if not result then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = result == 'sent' and 'Friend request sent' or 'Friend request accepted' })
    end

    cb(result and true or false)
end)

---@param userId number
RegisterNUICallback('acceptFriendRequest', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local data, err = lib.callback.await('ranked:server:acceptFriendRequest', false, userId)

    if not data then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'Friend request accepted' })
    end

    cb(data)
end)

---@param userId number
RegisterNUICallback('denyFriendRequest', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:denyFriendRequest', false, userId)

    if not success then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'Friend request denied' })
    end

    cb(success)
end)

---@param userId number
RegisterNUICallback('removeFriend', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:removeFriend', false, userId)

    if not success then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'Friend removed' })
    end

    cb(success)
end)

---@param userId number
RegisterNUICallback('revokeFriendRequest', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:revokeFriendRequest', false, userId)

    if not success then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'Friend request revoked' })
    end

    cb(success)
end)

---@param userId number
RegisterNUICallback('unblockUser', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:unblockUser', false, userId)

    if not success then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'User unblocked' })
    end

    cb(success)
end)

---@param userId number
RegisterNUICallback('blockUser', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local data, err = lib.callback.await('ranked:server:blockUser', false, userId)

    if not data then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'User blocked' })
    end

    cb(data)
end)

---@param isLeaveParty boolean
RegisterNUICallback('leaveParty', function(isLeaveParty, cb)
    if not isVisible then
        cb(false)
        return
    end

    TriggerServerEvent('ranked:server:leaveParty', isLeaveParty)

    cb(true)
end)

---@param formation RankedFormation
RegisterNUICallback('setPartyFormation', function(formation, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success = lib.callback.await('ranked:server:setPartyFormation', false, formation)

    cb(success)
end)

---@param mode RankedModeType
RegisterNUICallback('setPartyMode', function(mode, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success = lib.callback.await('ranked:server:setPartyMode', false, mode)

    cb(success)
end)

RegisterNUICallback('toggleQueue', function(_, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:togglePartyQueue', false)

    if not success and err then
        exports.ui:notify({ type = 'error', text = err })
    end

    cb(success)
end)

RegisterNUICallback('startLobby', function(_, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:startLobby', false)

    if not success and err then
        exports.ui:notify({ type = 'error', text = err })
    end

    cb(success)
end)

---@param userId number
RegisterNUICallback('kickPartyPlayer', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    TriggerServerEvent('ranked:server:kickPartyPlayer', userId)

    cb(true)
end)

---@param userId number
RegisterNUICallback('promotePartyPlayer', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    TriggerServerEvent('ranked:server:promotePartyPlayer', userId)

    cb(true)
end)

---@param userId number
RegisterNUICallback('sendPartyInvite', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:sendPartyInvite', false, userId)

    if not success then
        exports.ui:notify({ type = 'error', text = err })
    end

    cb(success)
end)

---@param userId number
RegisterNUICallback('requestPartyJoin', function(userId, cb)
    if not isVisible then
        cb(false)
        return
    end

    local success, err = lib.callback.await('ranked:server:requestPartyJoin', false, userId)

    if not success then
        exports.ui:notify({ type = 'error', text = err })
    else
        exports.ui:notify({ type = 'success', text = 'Lobby request sent' })
    end

    cb(success)
end)

---@param status 'online' | 'invisible' | 'dnd'
RegisterNUICallback('setRankedPresenceStatus', function(status, cb)
    if status ~= 'online' and status ~= 'invisible' and status ~= 'dnd' then
        cb(false)
        return
    end

    local success = lib.callback.await('ranked:server:setPresenceStatus', false, status)
    if success then
        setRankedPresenceStatus(status)
    else
        exports.ui:notify({ type = 'error', text = 'Unable to update status' })
    end

    cb(success == true)
end)

RegisterNUICallback('acceptPartyInvite', function(_, cb)
    if not isVisible then
        cb(false)
        return
    end

    TriggerServerEvent('ranked:server:acceptPartyInvite')

    cb(true)
end)

RegisterNUICallback('rejectPartyInvite', function(_, cb)
    TriggerServerEvent('ranked:server:rejectPartyInvite')

    cb(true)
end)

RegisterNUICallback('acceptRankedPartyJoinRequest', function(_, cb)
    TriggerServerEvent('ranked:server:acceptPartyJoinRequest')

    cb(true)
end)

RegisterNUICallback('rejectRankedPartyJoinRequest', function(_, cb)
    TriggerServerEvent('ranked:server:rejectPartyJoinRequest')

    cb(true)
end)

---@param visible boolean
local function setRankedWarningBannerVisible(visible)
    SendNUIMessage({ action = 'setRankedWarningBannerVisible', data = visible })
end

---@param data table
local function setRankedWarningBannerData(data)
    SendNUIMessage({ action = 'setRankedWarningBannerData', data = data })
end

---@param accepted boolean
RegisterNUICallback('reconnectToMatch', function(accepted, cb)
    cb(1)
    setRankedWarningBannerVisible(false)
    if isVisible then
        TriggerServerEvent('ranked:server:reconnectToMatch', accepted)
    end
end)

RegisterNetEvent('ranked:notifyReconnect', function()
    setRankedWarningBannerData({
        title = 'RECONNECT TO MATCH',
        description = 'You have left the previous game and must return otherwise a timeout will be issued on your account.',
        accept = 'RECONNECT',
        cancel = 'CANCEL',
    })
    setRankedWarningBannerVisible(true)
end)

---@param value any
---@param phrase any
---@return string
local function pluralTime(value, phrase)
    return ('%s %s%s'):format(value, phrase, value ~= 1 and 's' or '')
end

---@param duration integer
local function formatTimeLeftAsText(duration)
    local secondsTotal = duration % 60
    local minutesTotal = math.floor(duration / 60)
    local secondsText = secondsTotal > 0 and pluralTime(secondsTotal, 'second') or nil

    if minutesTotal == 0 then
        return secondsText
    end

    local minutes = minutesTotal % 60
    local minutesText = minutes > 0 and pluralTime(minutes, 'minute') or nil

    if minutesTotal < 60 then
        if minutesText and secondsText then
            return ('%s and %s'):format(minutesText, secondsText)
        end
        return minutesText or secondsText
    end

    local hoursTotal = math.floor(minutesTotal / 60)
    local hours = hoursTotal % 24
    local hoursText = hours > 0 and pluralTime(hours, 'hour') or nil

    if hoursTotal < 24 then
        if hoursText and minutesText then
            return ('%s and %s'):format(hoursText, minutesText)
        end
        return hoursText or minutesText or secondsText
    end

    local days = math.floor(hoursTotal / 24)
    local daysText = days > 0 and pluralTime(days, 'day') or nil

    if daysText and hoursText then
        return ('%s and %s'):format(daysText, hoursText)
    end

    return daysText or hoursText or minutesText or secondsText
end

---@param secondsLeft integer
RegisterNetEvent('ranked:displayTimeoutWarning', function(secondsLeft)
    local formattedTimeLeft = formatTimeLeftAsText(secondsLeft)
    setRankedWarningBannerData({
        title = 'ACTIVE TIMEOUT',
        description = ('Unable to start game whilst you have an active timeout on your account.\nYou will be able to play in %s.'):format(formattedTimeLeft),
        accept = 'OK',
        cancel = 'CANCEL',
    })
    setRankedWarningBannerVisible(true)
end)

CreateThread(function()
    while not playerState.uisReady do
        Wait(0)
    end

    while not playerState.isLoaded do
        Wait(0)
    end

    TriggerServerEvent('ranked:server:fetchGameModes')
end)

RegisterNUICallback('voteForMapBan', function(mapId, cb)
    local success = lib.callback.await('ranked:server:voteForMapBan', nil, mapId)
    cb(success)
end)

RegisterNUICallback('skipMapBanVote', function(_, cb)
    local success = lib.callback.await('ranked:server:voteForMapSkip', nil)
    cb(success)
end)

---@param visible boolean
local function setMatchEndedVisible(visible)
    SendNUIMessage({ action = 'setMatchEndedVisible', data = visible })
end

exports('setMatchEndedVisible', setMatchEndedVisible)

---@param data table
local function setMatchEndedData(data)
    SendNUIMessage({ action = 'setMatchEndedData', data = data })
end

exports('setMatchEndedData', setMatchEndedData)

RegisterNUICallback('stopLobbyEmote', function(_, cb)
    ranked:stopEmote()
    cb(true)
end)

---@param visible boolean
local function setContinueLobbyVisible(visible)
    SendNUIMessage({ action = 'setContinueLobbyVisible', data = visible })
    if visible then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
end

exports('setContinueLobbyVisible', setContinueLobbyVisible)

---@param data table
local function setContinueLobbyData(data)
    SendNUIMessage({ action = 'setContinueLobbyData', data = data })
end

exports('setContinueLobbyData', setContinueLobbyData)

---@param title string
local function setContinueLobbyTitle(title)
    SendNUIMessage({ action = 'setContinueLobbyTitle', data = title })
end

exports('setContinueLobbyTitle', setContinueLobbyTitle)

RegisterNUICallback('continueLobbyResult', function(continue, cb)
    TriggerServerEvent('ranked:server:setContinueLobbyResult', continue)
    cb(true)
end)