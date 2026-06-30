local appearance = exports.appearance

---@param toggle boolean
exports('setAppearanceVisible', function(toggle)
    SendNUIMessage({ action = 'setAppearanceVisible', data = toggle })
    SetNuiFocus(toggle, toggle)
end)

RegisterNUICallback('hideAppearance', function(_, cb)
    cb({})

    appearance:hideMenu()
end)

RegisterNUICallback('apprGetSettingsAndData', function(_, cb)
    local data = appearance:getSettingsAndData()

    cb(data)
end)

---@param camera string
RegisterNUICallback('apprSetCamera', function(camera, cb)
    appearance:setCamera(camera)

    cb({})
end)

RegisterNUICallback('apprTurnAround', function(_, cb)
    appearance:turnAround()

    cb({})
end)

---@param direction 'left' | 'right'
RegisterNUICallback('apprRotateCamera', function(direction, cb)
    appearance:rotateCamera(direction)

    cb({})
end)

---@param model string
RegisterNUICallback('apprChangeModel', function(model, cb)
    local data = appearance:changeModel(model)

    cb(data)
end)

---@param component table
RegisterNUICallback('apprChangeComponent', function(component, cb)
    local data = appearance:changeComponent(component, true)

    cb(data)
end)

---@param prop table
RegisterNUICallback('apprChangeProp', function(prop, cb)
    local data = appearance:changeProp(prop, true)

    cb(data)
end)

---@param headBlend table
RegisterNUICallback('apprChangeHeadBlend', function(headBlend, cb)
    appearance:changeHeadBlend(headBlend)

    cb({})
end)

---@param faceFeatures table
RegisterNUICallback('apprChangeFaceFeature', function(faceFeatures, cb)
    appearance:changeFaceFeature(faceFeatures)

    cb({})
end)

---@param headOverlays table
RegisterNUICallback('apprChangeHeadOverlay', function(headOverlays, cb)
    appearance:changeHeadOverlay(headOverlays)

    cb({})
end)

---@param hair table
RegisterNUICallback('apprChangeHair', function(hair, cb)
    local data = appearance:changeHair(hair)

    cb(data)
end)

---@param eyeColor number
RegisterNUICallback('apprChangeEyeColor', function(eyeColor, cb)
    appearance:changeEyeColor(eyeColor)

    cb({})
end)

---@param data table
RegisterNUICallback('apprApplyTattoo', function(data, cb)
    appearance:applyTattoo(data)

    cb({})
end)

---@param previewTattoo table
RegisterNUICallback('apprPreviewTattoo', function(previewTattoo, cb)
    appearance:previewTattoo(previewTattoo)

    cb({})
end)

---@param data table
RegisterNUICallback('apprDeleteTattoo', function(data, cb)
    appearance:deleteTattoo(data)

    cb({})
end)

---@param dataWearClothes table
RegisterNUICallback('apprWearClothes', function(dataWearClothes, cb)
    appearance:wearClothes(dataWearClothes)

    cb({})
end)

---@param clothes string
RegisterNUICallback('apprRemoveClothes', function(clothes, cb)
    appearance:removeClothes(clothes)

    cb({})
end)

RegisterNUICallback('resetAppearance', function(_, cb)
    local data = appearance:resetAppearance()

    cb(data)
end)

---@param appearanceData table
RegisterNUICallback('saveAppearance', function(appearanceData, cb)
    appearance:saveAppearance(appearanceData)

    cb({})
end)