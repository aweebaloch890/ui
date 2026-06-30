local shop = exports.shop
local appearance = exports.appearance

local playerState = LocalPlayer.state

local cachedOutfits = {}

---@param cb function
---@return boolean
local function isSafeCallback(cb)
    if IsPauseMenuVisible() or IsRankedMenuVisible() then
        return true
    end

    cb(false)

    return false
end

---@param data table
---@param cb function
RegisterNUICallback('createOutfit', function(data, cb)
    if not isSafeCallback(cb) then
        return
    end

    local outfit = {
        model = appearance:getPedModel(cache.ped),
        components = appearance:getPedComponents(cache.ped),
        props = appearance:getPedProps(cache.ped),
    }

    local outfitData, err = lib.callback.await('pausemenu:server:createOutfit', false, data.label, outfit)
    if not outfitData then
        exports.ui:notify({ type = 'error', text = err or 'Something went wrong' })
        return cb(false)
    end

    table.insert(cachedOutfits, outfitData)

    cb(outfitData)
end)

---@param outfitId number
---@param cb function
RegisterNUICallback('equipOutfitId', function(outfitId, cb)
    if not isSafeCallback(cb) then
        return
    end

    local outfit, err = lib.callback.await('pausemenu:server:equipOutfitId', false, outfitId)
    if not outfit then
        exports.ui:notify({ type = 'error', text = err or 'Something went wrong' })
        return cb(false)
    end

    shop:setPreviewPedAppearance(outfit)

    appearance:setPedComponents(cache.ped, outfit.components)
    appearance:setPedProps(cache.ped, outfit.props)

    local appearanceTable = appearance:getPedAppearance(cache.ped)
    TriggerServerEvent('core:server:updateUserAppearance', appearanceTable)

    cb(true)
end)

---@param outfitId number
---@param cb function
RegisterNUICallback('deleteOutfitId', function(outfitId, cb)
    if not isSafeCallback(cb) then
        return
    end

    local deleted, err = lib.callback.await('pausemenu:server:deleteOutfitId', false, outfitId)
    if not deleted then
        exports.ui:notify({ type = 'error', text = err or 'Something went wrong' })
    else
        for index, outfit in pairs(cachedOutfits) do
            if outfit.outfitId == outfitId then
                table.remove(cachedOutfits, index)
                break
            end
        end
    end

    cb(deleted)
end)

local function sendOutfitsForCurrentModel(ped)
    local pedModel = appearance:getPedModel(ped)

    local outfits = {}

    for _, outfit in pairs(cachedOutfits) do
        if not outfit.model or outfit.model == pedModel then
            table.insert(outfits, outfit)
        end
    end

    SendNUIMessage({ action = 'setUserOutfits', data = outfits })
end

lib.onCache('ped', sendOutfitsForCurrentModel)

CreateThread(function()
    while not playerState.uisReady do
        Wait(0)
    end

    while not playerState.isLoaded do
        Wait(0)
    end

    local outfits, maxOutfits = lib.callback.await('pausemenu:server:fetchOutfits', false)
    cachedOutfits = outfits

    sendOutfitsForCurrentModel(cache.ped)
    SendNUIMessage({ action = 'setMaxOutfits', data = maxOutfits })
end)