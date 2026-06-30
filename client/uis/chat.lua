local playerState = LocalPlayer.state

---@param isVisible boolean
local function setChatInputVisible(isVisible)
    SendNUIMessage({ action = 'setChatInputVisible', data = isVisible })

    if isVisible then
        SetNuiFocus(true, true)
    elseif not IsRankedMenuVisible() then
        SetNuiFocus(false, false)
    end
end

exports('setChatInputVisible', setChatInputVisible)

---@param message GameChatMessage
local function addChatMessage(message)
    SendNUIMessage({ action = 'addChatMessage', data = message })
end

exports('addChatMessage', addChatMessage)

---@param data { mode: ChatVisibilityMode, fromUserInteraction: boolean }
local function setChatMessagesMode(data)
    SendNUIMessage({ action = 'setChatMessagesMode', data = data })
end

exports('setChatMessagesMode', setChatMessagesMode)

---@param data GameChatSuggestion
local function addChatSuggestion(data)
    while not playerState.uisReady do
        Wait(100)
    end

    SendNUIMessage({ action = 'addChatSuggestion', data = data })
end

exports('addChatSuggestion', addChatSuggestion)

---@param data GameChatSuggestion[]
local function addChatSuggestions(data)
    while not playerState.uisReady do
        Wait(100)
    end

    SendNUIMessage({ action = 'addChatSuggestions', data = data })
end

exports('addChatSuggestions', addChatSuggestions)

---@param name string
local function removeChatSuggestion(name)
    while not playerState.uisReady do
        Wait(100)
    end

    SendNUIMessage({ action = 'removeChatSuggestion', data = name })
end

exports('removeChatSuggestion', removeChatSuggestion)

local function clearChatMessages()
    SendNUIMessage({ action = 'clearChatMessages', data = {} })
end

exports('clearChatMessages', clearChatMessages)

---@param modes GameChatMode[]
local function setChatModes(modes)
    SendNuiMessage(json.encode({
        action = 'setChatModes',
        data = modes
    }, { sort_keys = true }))
end

exports('setChatModes', setChatModes)

---@param mode GameChatMode
local function addChatMode(mode)
    SendNUIMessage({ action = 'addChatMode', data = mode })
end

exports('addChatMode', addChatMode)

---@param name string
local function removeChatMode(name)
    SendNUIMessage({ action = 'removeChatMode', data = name })
end

exports('removeChatMode', removeChatMode)

local function clearChatModes()
    SendNUIMessage({ action = 'clearChatModes', data = {} })
end

exports('clearChatModes', clearChatModes)

---@param mode string
local function setCurrentChatMode(mode)
    SendNUIMessage({ action = 'setCurrentChatMode', data = mode })
end

exports('setCurrentChatMode', setCurrentChatMode)

RegisterNUICallback('hideChatInput', function(_, cb)
    setChatInputVisible(false)

    cb(1)
end)

local function usePreSecurityBehavior()
    -- use `setr sysresource_chat_disableOriginSecurityChecks true` on the server to allow non secure execution
    -- of commands and events, `setr` will also disallow clients to change it
    return GetConvar('sysresource_chat_disableOriginSecurityChecks', 'true') == 'true'
end

---@param requestData table
---@param cb function
RegisterRawNuiCallback('sendChatMessage', function(requestData, cb)
    local resource = requestData.resource
    local securityDisabled = usePreSecurityBehavior()

    -- only allow actual resources to call in here
    if resource == nil and not securityDisabled then
        return
    end

    setChatInputVisible(false)

    local data = json.decode(requestData.body)

    if data.text:sub(1, 1) == '/' then
        -- Only this resource's NUI page can execute commands
        if resource == cache.resource or securityDisabled then
            ExecuteCommand(data.text:sub(2))
        end
    else
        TriggerServerEvent('gamechat:server:messageRequest', data)
    end

    cb({ body = json.encode({ success = true }) })
end)