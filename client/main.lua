local peds = {}
local camactive

local function RotateVector(vector, angle)
    angle = math.rad(angle)
    local newx = (math.cos(angle) * vector.x) - (math.sin(angle) * vector.y)
    local newy = (math.sin(angle) * vector.x) + (math.cos(angle) * vector.y)
    return vec2(newx, newy)
end

local function PointRotation(point, center, angle)
    local vector = point - center
    vector = RotateVector(vector, angle)
    return (center + vector)
end

local function TurnOffCamera()
    camactive = nil
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    RenderScriptCams(false, false, 1, true, true)
end

local function SelectCharacter()
    
    SetNuiFocus(true, true)
    DisplayRadar(false)
    
    local SelectPoint = Config.CharSelectPoints[math.random(1,#Config.CharSelectPoints)]
    SetEntityCoords(PlayerPedId(), SelectPoint.center.x, SelectPoint.center.y, SelectPoint.z)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", SelectPoint.point.x, SelectPoint.point.y, SelectPoint.z, 0.0 ,0.0, SelectPoint.w, 55.0, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)

    local chars = lib.callback.await('pb-charselector:getCharacters', false)

    peds = {}
    for i, char in pairs(chars) do
        local coords = SelectPoint.charcoords[i]

        if not char.model then goto continue end

        RequestModel(char.model)
        while not HasModelLoaded(char.model) do
            Wait(0)
        end
        SetModelAsNoLongerNeeded(char.model)
        peds[i] = CreatePed(4, GetHashKey(char.model), coords.x, coords.y, coords.z, false, true)
        SetEntityHeading(peds[i], coords.w)
        
        exports['illenium-appearance']:setPedAppearance(peds[i], json.decode(char.skin))
        char.mug = exports["MugShotBase64"]:GetMugShotBase64(peds[i], true)
        
        if not SelectPoint.animations[i][4] then
            while (not HasAnimDictLoaded(SelectPoint.animations[i][1])) do RequestAnimDict(SelectPoint.animations[i][1]) Wait(0) end
            TaskPlayAnim(peds[i], SelectPoint.animations[i][1], SelectPoint.animations[i][2], 8.0, -8, -1, SelectPoint.animations[i][3] or 1, 0, 0, 0, 0)
        else
            TaskStartScenarioInPlace(peds[i], 'WORLD_HUMAN_STAND_MOBILE', 0, false)
        end
        ::continue::
    end

    SendNUIMessage({
        procedure = 'init',
        limit = 5,
        chars = chars
    })
    
    SetTimecycleModifier('default')
    camactive = true
    local center = SelectPoint.center
    local point = SelectPoint.point
    local w = SelectPoint.w
    while camactive do
        Wait(50)
        point = PointRotation(point, center, 0.05)
        SetCamCoord(cam, point.x, point.y, SelectPoint.z)
        w = w + 0.05
        SetCamRot(cam, 0.0, 0.0, w)
    end
end

Citizen.CreateThread(function()
    while not LocalPlayer.state.IsLoggedIn do Wait(0) end

    DoScreenFadeIn(1000)

    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)

    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false, 0)
    SelectCharacter()
end)

RegisterNUICallback('selectchar', function(char)
    if not lib.callback.await('pb-charselector:selectCharacter', false, char.cid) then return end
    DoScreenFadeOut(0)
    TurnOffCamera()
    for _, ped in pairs(peds) do
        DeleteEntity(ped)
    end
    peds = nil
    SetNuiFocus(false, false)
    SendNUIMessage({
        procedure = "close"
    })
    local PlayerInfo = exports['pb-core']:GetPlayerInfo()
    local ped = PlayerPedId()

    local model = `mp_m_freemode_01`
    if IsModelInCdimage(model) and IsModelValid(model) then
    RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end

    exports['illenium-appearance']:setPlayerModel(char.model)
    ped = PlayerPedId()
    Wait(1000)
    exports['illenium-appearance']:setPedAppearance(ped, json.decode(char.skin))

    SetEntityVisible(ped, true, 0)
    SetEntityCoords(ped, PlayerInfo.position.x, PlayerInfo.position.y, PlayerInfo.position.z)
    SetEntityHeading(ped, PlayerInfo.position.w)
    TriggerEvent('pb:client:OnLogin')
    FreezeEntityPosition(ped, false)
    
    DoScreenFadeIn(500)
    DisplayRadar(true)
end)

RegisterNUICallback('createNewChar', function(_)
    DoScreenFadeOut(1000)
    Wait(2000)

    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)

    SendNUIMessage({
        procedure = "createChar",
    })
    DoScreenFadeIn(1000)
end)

RegisterNUICallback('cancelCreateChar', function(_)
    DoScreenFadeOut(1000)
    Wait(2000)

    SetTimecycleModifier('default')

    SendNUIMessage({
        procedure = "init"
    })
    DoScreenFadeIn(1000)
end)


RegisterNUICallback('CreateChar', function(data)
    DoScreenFadeOut(1000)
    Wait(2000)

    SetTimecycleModifier('default')

    if (data.gender == "male") then data.gender = 0 
    else data.gender = 1 end

    if lib.callback.await('pb-charselector:createCharacter', false, data) then
        DoScreenFadeOut(0)
        TurnOffCamera()
        for _, ped in pairs(peds) do
            DeleteEntity(ped)
        end
        peds = nil
        SetNuiFocus(false, false)
        SendNUIMessage({
            procedure = "close"
        })

        local ped = PlayerPedId()

        FreezeEntityPosition(ped, false)
        SetEntityCoords(ped, Config.CreatePed.x, Config.CreatePed.y, Config.CreatePed.z)
        SetEntityHeading(ped, Config.CreatePed.w)
        SetEntityVisible(ped, true, 0)
        exports['illenium-appearance']:InitializeCharacter(data.gender, function()
            DoScreenFadeOut(1000)
            Wait(2000)

            ped = PlayerPedId()

            FreezeEntityPosition(ped, false)
            SetEntityCoords(ped, Config.SpawnPed.x, Config.SpawnPed.y, Config.SpawnPed.z)
            SetEntityHeading(ped, Config.SpawnPed.w)
            TriggerEvent('pb:client:OnLogin')

            DoScreenFadeIn(1000)
        end)
    end

    DoScreenFadeIn(1000)
    Wait(1000)
    DisplayRadar(true)
    FreezeEntityPosition(ped, true)
end)


RegisterNetEvent('pb:client:OnLogout', function()
    DoScreenFadeIn(1000)

    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)

    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false, 0)

    SelectCharacter()
end)