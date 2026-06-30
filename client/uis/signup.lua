local core = exports.core

local function displaySignup()
    SendNUIMessage({ action = 'setSignupVisible', data = true })
    SetNuiFocus(true, true)
end

exports('displaySignup', displaySignup)

RegisterNUICallback('closeSignup', function(_, cb)
    cb(1)

    SendNUIMessage({ action = 'setSignupVisible', data = false })
    SetNuiFocus(false, false)
end)

RegisterNUICallback('submitSignup', function(username, cb)
    local data, err = lib.callback.await('core:server:createUser', false, username)

    if not data then
        return cb({ success = false, error = err })
    end

    core:SyncPlayerDataFromServer(data)

    cb({ success = true })

    core:loadPlayer(data)
end)