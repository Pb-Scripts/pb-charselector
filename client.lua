local QBCore = exports['qb-core']:GetCoreObject()
local cam

pb.locales()

local function SetCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, 0.0 ,0.0, Config.CamCoords.w, 55.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

local peds = {}

local function CharMenu()
    lib.callback('pb-charselector:GetChars', false, function(numberOfChars, charsinfo, identifier)
        SetNuiFocus(true, true)
        SetCam(true)
        for i, player in pairs(charsinfo) do
            local spawn = Config.PedSpawns[i]
            RequestModel(player.skin.model)
            while not HasModelLoaded(player.skin.model) do
                Wait(10)
            end
            local ped = CreatePed(4, GetHashKey(player.skin.model), spawn.coords.x, spawn.coords.y, spawn.coords.z, spawn.coords.w, false, false)
            exports['illenium-appearance']:setPedAppearance(ped, json.decode(player.skin.skin))
            RequestAnimDict(spawn.dict)
            while not HasAnimDictLoaded(spawn.dict) do
                Wait(10)
            end
            TaskPlayAnim(ped, spawn.dict, spawn.anim, 1.5, 1.5, -1, 1, 1.0, 1, 1, 1)
            peds[i] = ped
            Wait(500)
            local coords = GetEntityCoords(ped)
            local _, x, y  = GetHudScreenPositionFromWorldPosition(coords.x, coords.y, coords.z)
            SendNUIMessage({
                type = "loadChar",
                left = x*100,
                top = y*100,
                last = (i == numberOfChars),
                cid = player.cid,
                info = json.decode(player.info),
            })
        end
        SendNUIMessage({
            type = "CreateNewCharSetup",
            num = numberOfChars,
            max = Config.CharsNumber[identifier] or Config.DefaultCharsNumber,
            removeblur = numberOfChars == 0,
            dict = getlocales()
        })
    end)
end

RegisterNetEvent('pb-charselector:CharMenu')
AddEventHandler('pb-charselector:CharMenu', function()
    DoScreenFadeOut(500)
    SetNuiFocus(true, true)
    while not IsScreenFadedOut() do Wait(0) end
    RequestModel('a_m_m_rurmeth_01')
    while not HasModelLoaded('a_m_m_rurmeth_01') do
        Wait(10)
    end
    SetPlayerModel(PlayerId(), 'a_m_m_rurmeth_01')
    local ped = PlayerPedId()
    SetEntityCoords(ped, -766.1462, 314.0835, 175.4012)
    SetEntityHeading(ped, 318.1053)
    SetEntityVisible(ped, false, 0)
    Wait(1000)
    CharMenu()
    DoScreenFadeIn(500)
end)

RegisterNUICallback("RemoveBlur", function()
    SetTimecycleModifier('default')
end)

if GetConvar("pb:devenvironment", "false") == "true" then -- Remove the peds on Loading Screen
    RegisterCommand("removerPeds", function()
        for _,ped in pairs(peds) do
            DeletePed(ped)
        end
        SetNuiFocus(false, false)
        SetCam(false)
    end)
end

local function CharSelectionOnEntry()
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(0) end
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, 0)
    Wait(1000)
    CharMenu(true)
end

RegisterNUICallback("SelectChar", function(data)
    for k, ped in pairs(peds) do
        DeleteEntity(ped)
    end
    peds = {}
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    if not lib.callback.await('pb-charselector:SelectCharacter', false, data.cid) then return end
    Wait(1000)
    QBCore.Functions.GetPlayerData(function(pd)
        local ped = PlayerPedId()
        SetEntityVisible(ped, true, 0)
        SetEntityCoords(ped, pd.position.x, pd.position.y, pd.position.z)
        SetEntityHeading(ped, pd.position.a)
        FreezeEntityPosition(ped, false)
    end)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    SetCam(false)
    DoScreenFadeIn(500)
end)

RegisterNUICallback("CreateChar", function(data)
    for k, ped in pairs(peds) do
        DeleteEntity(ped)
    end
    peds = {}
    local ped = PlayerPedId()
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    local spawn = lib.callback.await('pb-charselector:CreateCharacter', false, data)
    if not spawn then return end
    Wait(500)
    SetEntityCoords(ped, Config.Spawns[1].x, Config.Spawns[1].y, Config.Spawns[1].z)
    SetEntityHeading(ped, Config.Spawns[1].w)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    SetEntityVisible(ped, true)
    Wait(500)
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    DoScreenFadeIn(500)
end)

RegisterNUICallback("DeleteCharacter", function(data)
    if Config.EnableDelete then
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do Wait(0) end
        for k, ped in pairs(peds) do
            DeleteEntity(ped)
        end
        peds = {}
        lib.callback.await('pb-charselector:DeleteCharacter', false, data.cid)
        Wait(1000)
        DoScreenFadeIn(500)
        CharMenu(true)
    else
        lib.notify({
            title = locale('error_title'),
            description = locale('deletechar_description'),
            type = 'error'
        })
    end
end)

RegisterNUICallback("errorNotify", function(data)
    lib.notify({
        title = locale('error_title'),
        description = data.text,
        type = 'error'
    })
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            exports.spawnmanager:setAutoSpawn(false)
            Wait(250)
            CharSelectionOnEntry()
            exports.spawnmanager:spawnPlayer({x = -766.1462, y = 314.0835, z = 175.4012, heading = 318.1053, model = 'a_m_m_rurmeth_01'})
            break
        end
    end
end)