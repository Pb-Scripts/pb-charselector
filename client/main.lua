
local guiEnabled, hasIdentity, isDead = false, false, false
local myIdentity, myIdentifiers = {}, {}
local spawned = true
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

function EnableGui(state)
	SetNuiFocus(state, state)
	guiEnabled = state
	SendNUIMessage({
		type = "enableui",
		enable = state
	})
end

RegisterNetEvent('pb_openMenu')
AddEventHandler('pb_openMenu', function(data)
	SendNUIMessage({
		data = data,
	})
end)

RegisterNetEvent('pb_start')
AddEventHandler('pb_start', function(data)
	local ped = PlayerPedId()
	TriggerEvent("clothing:client:adjustfacewear", 4)
	SetEntityCoords(ped, 9.28, 528.49, 169.64)
	SetEntityHeading(ped, 138.81)
	FreezeEntityPosition(ped, true)
	SetEntityVisible(ped, false, false)
	SetNuiFocus(true, true)
	SendNUIMessage({
		start = true,
	})
	CreateCam()
end)

RegisterNUICallback("select", function()
	local ped = PlayerPedId()
	selecting = true
	SetEntityCoords(ped, 9.28, 528.49, 169.64)
	SetEntityHeading(ped, 138.81)
	FreezeEntityPosition(ped, true)
	while selecting do
		Wait(0)
		SetEntityLocallyVisible(ped, true, true)
	end
end)

RegisterNUICallback("unselect", function()
	local ped = PlayerPedId()
	selecting = false
end)

local coords = nil

RegisterNetEvent('pb_sendCoords')
AddEventHandler('pb_sendCoords', function(coord)
	coords = coord
end)

RegisterNUICallback("play", function()
	local ped = PlayerPedId()
	SetEntityHealth(ped, 200)
    loadDict("anim@mp_player_intincarthumbs_uplow@ds@")
    TaskPlayAnim(ped, "anim@mp_player_intincarthumbs_uplow@ds@", "enter", 8.0, 8.0, 1000, 1, 1, 0, 0, 0)
	Wait(1500)
	RenderScriptCams(0)
	ExecuteCommand('hud')
	selecting = false
	SetEntityCoords(ped, coords.x, coords.y, coords.z - 1)
	SetEntityVisible(ped, true, true)
	FreezeEntityPosition(ped, false)
	SetNuiFocus(false, false)
	TriggerServerEvent('pb:setCanSave')
	TriggerEvent('CircleMap')
	TriggerServerEvent('UpdtData')
	ExecuteCommand('fixPhone')
	TriggerEvent('sem:entrada')
	SetPlayerHealthRechargeMultiplier(ped, 0.0)
	TriggerEvent("pbpolice:BackWeapons")
	TriggerEvent('np-target:refresh')
end)

function CreateCam()
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 6.64, 527.3, 170.62, 0, 0, 291.75, 50.00, false, 0)
	SetCamActive(cam, true)
    RenderScriptCams(true, false, 2000, true, true)
end

RegisterNetEvent('esx_identity:showRegisterIdentity')
AddEventHandler('esx_identity:showRegisterIdentity', function()
	if not isDead then
		EnableGui(true)
	end
end)

RegisterNetEvent('esx_identity:identityCheck')
AddEventHandler('esx_identity:identityCheck', function(identityCheck)
	hasIdentity = identityCheck
end)

RegisterNetEvent('esx_identity:saveID')
AddEventHandler('esx_identity:saveID', function(data)
	myIdentifiers = data
end)

RegisterNUICallback('escape', function(data, cb)
	if hasIdentity then
		EnableGui(false)
	else
		ESX.ShowNotification(_U('create_a_character'))
	end
end)

RegisterNetEvent('RefreshSpawned')
AddEventHandler('RefreshSpawned', function()
	local ped = PlayerPedId()
	spawned = true
	SetEntityVisible(ped, true, true)
end)

RegisterNUICallback('register', function(data, cb)
	local reason = ""
	myIdentity = data
	for theData, value in pairs(myIdentity) do
		if theData == "firstname" or theData == "lastname" then
			reason = verifyName(value, 1)
			if reason ~= "" then
				break
			end
		elseif theData == "dateofbirth" then
			if value == "invalid" then
				reason = "Sua data de nascimento está inválida"
				break
			end
		elseif theData == "height" then
			local height = tonumber(value)
			if height then
				if height > 220 or height < 120 then
					reason = "Você não pode colocar menos que 120 e maior que 220"
					break
				end
			else
				reason = "Você digitou algo errado na altura..."
				break
			end
		end
	end
	if reason == "" then
		local ped = PlayerPedId()
		TriggerServerEvent('esx_identity:setIdentity', data, myIdentifiers)
		EnableGui(false)
		SendNUIMessage({
			data = "fechar"
		})
		FreezeEntityPosition(ped, false)
		SetNuiFocus(false, false)
		loadDict("anim@mp_player_intincarthumbs_uplow@ds@")
		TaskPlayAnim(ped, "anim@mp_player_intincarthumbs_uplow@ds@", "enter", 8.0, 8.0, 1000, 1, 1, 0, 0, 0)
		selecting = false
		Wait(1500)
		ExecuteCommand('hud')
		RenderScriptCams(0)
		TriggerEvent('CircleMap')
		Wait(1000)
		TriggerEvent("clothing:client:openMenu", true)
		TriggerEvent("player:receiveItem", 'bmx', 1)
		TriggerServerEvent('UpdtData')
		Wait(3000)
		TriggerServerEvent('UpdtIban')
		if data.sex == "f" then
			TriggerEvent('skinchanger:loadSkin', {sex = 1})
			SetEntityVisible(ped, true, true)
			Wait(1000)
			SetEntityVisible(ped, false, false)
		end
		spawned = false
		while not spawned do
			Wait(0)
			SetEntityLocallyVisible(ped, true, true)
		end
		ExecuteCommand('fixPhone')
		SetEntityHealth(ped, 200)
		SetPlayerHealthRechargeMultiplier(ped, 0.0)
		TriggerEvent("pbpolice:BackWeapons")
		TriggerEvent('np-target:refresh')
	else
		ESX.ShowNotification(reason)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if guiEnabled then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function verifyName(name, type)
	if type == 1 then
		-- Don't allow short user names
		local nameLength = string.len(name)
		if nameLength > 25 or nameLength < 2 then
			return 'O seu nome não pode ser muito pequeno, e nem muito grande! (Min: 2, Max: 25)'
		end

		-- Don't allow special characters (doesn't always work)
		local count = 0
		for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzêâÊÂãÃåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ -]') do
			count = count + 1
		end
		if count ~= nameLength then
			return 'Estás a tentar usar caracteres inválidos no seu nome!'
		end

		-- Does the player carry a first and last name?
		--
		-- Example:
		-- Allowed:     'Bob Joe'
		-- Not allowed: 'Bob'
		-- Not allowed: 'Bob joe'
		local spacesInName    = 0
		local spacesWithUpper = 0
		for word in string.gmatch(name, '%S+') do

			if string.match(word, '%u') then
				spacesWithUpper = spacesWithUpper + 1
			end

			spacesInName = spacesInName + 1
		end

		if spacesInName > 2 then
			return 'Identificamos que no seu nome tem 2 espaços'
		end

		if spacesWithUpper ~= spacesInName then
			return 'O seu nome tem que iniciar com a primeira letra maiuscula'
		end

		return ''
	else
		-- Don't allow short user names

		-- Don't allow special characters (doesn't always work)
		local count = 0
		for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzêâÊÂãÃåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ -]') do
			count = count + 1
		end

		local spacesInName    = 0
		local spacesWithUpper = 0
		for word in string.gmatch(name, '%S+') do

			if string.match(word, '%u') then
				spacesWithUpper = spacesWithUpper + 1
			end

			spacesInName = spacesInName + 1
		end

		return ''
	end
end

loadDict = function(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end
