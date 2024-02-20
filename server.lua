local QBCore = exports['qb-core']:GetCoreObject()

pb.locales()

lib.callback.register('pb-charselector:GetChars', function(source)
    local license = QBCore.Functions.GetIdentifier(source, 'license2')
    local results = MySQL.query.await('SELECT * FROM players WHERE license = ?', {license})
    local chars_num = #results
    local chars = {}
    for k,player in pairs(results) do
        chars[k] = {}
        chars[k].cid = player.citizenid
        chars[k].info = player.charinfo
        chars[k].skin = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ?', {player.citizenid})[1]
    end
    return chars_num, chars, license
end)

lib.callback.register('pb-charselector:SelectCharacter', function(source, cid)
    if QBCore.Player.Login(source, cid) then
        QBCore.Commands.Refresh(source)
        -- Logs Aqui (Seleção de Char)
        return true
	end
    return false
end)

lib.callback.register('pb-charselector:CreateCharacter', function(source, data)
    dataToSend = {}
    dataToSend.cid = data.cid
    dataToSend.charinfo = data
    if QBCore.Player.Login(source, false, dataToSend) then
        QBCore.Commands.Refresh(source)
        -- Logs Aqui (Criação de Char)
        return true
	end
    return false
end)

lib.callback.register('pb-charselector:DeleteCharacter', function(source, citizenid)
    QBCore.Player.DeleteCharacter(source, citizenid)
    -- Logs Aqui (Criação de Char)
    return true
end)



lib.addCommand('logout', {
    help = locale('logout_help'),
    params = {
        {
            name = "target",
            type = 'playerId',
            help = 'Player Server Id',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local plyId = args.target or source
    QBCore.Player.Logout(plyId)
    TriggerClientEvent("pb-charselector:CharMenu", plyId)
end)