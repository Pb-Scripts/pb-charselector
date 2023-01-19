TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local jobs = {
	unemployed = 'Desempregado',
	police = 'Policia',
	offpolice = 'Policia',
	ballas = 'Ballas',
	ambulance = 'Inem',
	bahamas = 'Bahamas',
	biker = 'Tunners',
	brinks = 'Prosegur',
	busdriver = 'Camionista',
	cartel = 'Cartel',
	ctt = 'Carteiro',
	forum = 'Forum Drive',
	garbage = 'Lixeiro',
	gouv = 'Governo',
	inem = 'Inem',
	mafia = 'Mafia',
	mechanic = 'Norauto',
	miner = 'Mineiro',
	offambulance = 'Inem',
	offmechanic = 'Norauto',
	peaky = 'Peaky Blinders',
	staff = 'Staff',
	taxi = 'Taxi',
	tequila = 'Tequi-la-la',
	thelost = 'The Lost',
	tribunal = 'Tribunal',
	vagos = 'Vagos',
	vanilla = 'Vanilla'
}

function getIdentity(source, callback)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT identifier, firstname, lastname, dateofbirth, sex, height, identidade, job FROM `users` WHERE `identifier` = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local jobA = result[1].job
		if result[1].firstname ~= nil then
			local data = {
				identifier	= result[1].identifier,
				firstname	= result[1].firstname,
				lastname	= result[1].lastname,
				dateofbirth	= result[1].dateofbirth,
				sex			= result[1].sex,
				height		= result[1].height,
				identidade	= result[1].identidade,
				job = jobs[jobA]
			}
			callback(data)
		else
			local data = {
				identifier	= '',
				firstname	= '',
				lastname	= '',
				dateofbirth	= '',
				sex			= '',
				height		= '',
				identidade	= '',
				job = '',
			}
			callback(data)
		end
	end)
end

function setIdentity(identifier, data, callback)
	local identidade = math.random(9) .. math.random(9) .. math.random(9) .. math.random(9)
	MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height, `identidade` = @identidade WHERE identifier = @identifier', {
		['@identifier']		= identifier,
		['@firstname']		= data.firstname,
		['@lastname']		= data.lastname,
		['@dateofbirth']	= data.dateofbirth,
		['@sex']			= data.sex,
		['@height']			= data.height,
		['@identidade']		= identidade
	}, function(rowsChanged)
		if callback then
			callback(true)
		end
	end)
end

function updateIdentity(playerId, data, callback)
	local identidade = math.random(9) .. math.random(9) .. math.random(9) .. math.random(9)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height, `identidade` = @identidade WHERE identifier = @identifier', {
		['@identifier']		= xPlayer.identifier,
		['@firstname']		= data.firstname,
		['@lastname']		= data.lastname,
		['@dateofbirth']	= data.dateofbirth,
		['@sex']			= data.sex,
		['@height']			= data.height,
		['@identidade']		= identidade,
	}, function(rowsChanged)
		if callback then
			TriggerEvent('esx_identity:characterUpdated', playerId, data)
			callback(true)
		end
	end)
end

function deleteIdentity(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height, `identidade` = @identitdade WHERE identifier = @identifier', {
		['@identifier']		= xPlayer.identifier,
		['@firstname']		= '',
		['@lastname']		= '',
		['@dateofbirth']	= '',
		['@sex']			= '',
		['@height']			= '',
		['@identidade']		= '',
	})
end

function setIdentidade(source)
	local identidade = math.random(9) .. math.random(9) .. math.random(9) .. math.random(9)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE `users` SET `identidade` = @identitdade WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@identidade'] = identidade,
	})
end

RegisterServerEvent('esx_identity:setIdentity')
AddEventHandler('esx_identity:setIdentity', function(data, myIdentifiers)
	local xPlayer = ESX.GetPlayerFromId(source)
	setIdentity(myIdentifiers.steamid, data, function(callback)
		if callback then
			TriggerClientEvent('esx_identity:identityCheck', myIdentifiers.playerid, true)
			TriggerEvent('esx_identity:characterUpdated', myIdentifiers.playerid, data)
		else
			xPlayer.showNotification(_U('failed_identity'))
		end
	end)
end)

RegisterServerEvent('pb:setCanSave')
AddEventHandler('pb:setCanSave', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.set('canSave', true)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	xPlayer.set('canSave', false)
	getIdentity(playerId, function(data)
		if data.identidade == '' or data.identidade == nil or data.identidade == null then
			TriggerEvent('setIdentidade', playerId)
		end
	end)
	Wait(10000)
	TriggerClientEvent('pb_start', playerId)
	Wait(15000)
	local myID = {
		steamid = xPlayer.identifier,
		playerid = playerId
	}
	TriggerClientEvent('esx_identity:saveID', playerId, myID)
	getIdentity(playerId, function(data)
		if data.firstname == '' then
			TriggerClientEvent('esx_identity:identityCheck', playerId, false)
			TriggerClientEvent('esx_identity:showRegisterIdentity', playerId)
		else
			TriggerClientEvent('esx_identity:identityCheck', playerId, true)
			TriggerEvent('esx_identity:characterUpdated', playerId, data)
		end
	end)
	Wait(5000)
	TriggerClientEvent('esx_identity:saveID', playerId, myID)
	getIdentity(playerId, function(data)
		if data.firstname == '' then
			TriggerClientEvent('esx_identity:identityCheck', playerId, false)
			TriggerClientEvent('esx_identity:showRegisterIdentity', playerId)
			TriggerClientEvent('pb_openMenu', playerId, "nada")
		else
			TriggerClientEvent('esx_identity:identityCheck', playerId, true)
			TriggerEvent('esx_identity:characterUpdated', playerId, data)
			TriggerClientEvent('pb_openMenu', playerId, data)
		end
	end)
end)

AddEventHandler('esx_identity:characterUpdated', function(playerId, data)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if xPlayer then
		xPlayer.setName(('%s %s'):format(data.firstname, data.lastname))
		xPlayer.set('firstName', data.firstname)
		xPlayer.set('lastName', data.lastname)
		xPlayer.set('dateofbirth', data.dateofbirth)
		xPlayer.set('sex', data.sex)
		xPlayer.set('height', data.height)
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(3000)
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer then
				local myID = {
					steamid  = xPlayer.identifier,
					playerid = xPlayer.source
				}
				TriggerClientEvent('esx_identity:saveID', xPlayer.source, myID)
				getIdentity(xPlayer.source, function(data)
					if data.firstname == '' then
						TriggerClientEvent('esx_identity:identityCheck', xPlayer.source, false)
						TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
					else
						TriggerClientEvent('esx_identity:identityCheck', xPlayer.source, true)
						TriggerEvent('esx_identity:characterUpdated', xPlayer.source, data)
					end
				end)
			end
		end
	end
end)

ESX.RegisterCommand('register', 'user', function(xPlayer, args, showError)
	getIdentity(xPlayer.source, function(data)
		if data.firstname ~= '' then
			xPlayer.showNotification(_U('already_registered'))
		else
			TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
		end
	end)
end, false, {help = _U('show_registration')})

ESX.RegisterCommand('char', 'user', function(xPlayer, args, showError)
	getIdentity(xPlayer.source, function(data)
		if data.firstname == '' then
			xPlayer.showNotification(_U('not_registered'))
		else
			xPlayer.showNotification(_U('active_character', data.firstname, data.lastname))
		end
	end)
end, false, {help = _U('show_active_character')})

ESX.RegisterCommand('chardel', 'user', function(xPlayer, args, showError)
	getIdentity(xPlayer.source, function(data)
		if data.firstname == '' then
			xPlayer.showNotification(_U('not_registered'))
		else
			deleteIdentity(xPlayer.source)
			xPlayer.showNotification(_U('deleted_character'))
			TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
		end
	end)
end, false, {help = _U('delete_character')})

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	playerLoaded = true
end)