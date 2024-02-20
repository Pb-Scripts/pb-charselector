lib.callback.register('pb-charselector:getCharacters', function(source)
    local identifier = GetPlayerIdentifierByType(source, 'license2')
    local chars = MySQL.prepare.await('SELECT cid, model, skin, firstname, lastname FROM apperances NATURAL JOIN players WHERE players.license = ?', {identifier})
    if not chars[1] then
        local char = chars
        chars = {}
        chars[1] = char
    end
    return chars
end)

lib.callback.register('pb-charselector:selectCharacter', function(source, cid)
    return exports['pb-core']:LoginPlayer(source, cid)
end)

lib.callback.register('pb-charselector:createCharacter', function(source, PlayerInfo)
    if exports['pb-core']:LoginPlayer(source, nil, PlayerInfo) then
        exports['pb-core']:GetPlayer(source).Save()
        return true
    end
    return false
end)