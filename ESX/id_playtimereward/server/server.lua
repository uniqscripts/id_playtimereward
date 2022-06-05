ESX = nil
local cache = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('iCarWash:getMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    local money = xPlayer.getMoney()

    cb(money)
end)

ESX.RegisterServerCallback('iCarWash:getOwnername', function(source, cb, broj)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ownername
        
    MySQL.query.await('SELECT * FROM carwash WHERE owner = owner', {
    }, function(owner)
      if owner then
        local res = MySQL.query.await('SELECT * FROM carwash')
                    
        for key, val in ipairs(res) do
            hasowner = val.owner~=nil and val.owner~=""
            if hasowner and not cache[val.owner] then cache[val.owner]=MySQL.Sync.fetchAll("SELECT firstname,lastname FROM users WHERE identifier = @identifier",{["@identifier"]=val.owner})[1] end
            if val.owner~=nil then cache[val.owner] = cache[val.owner]~=nil and cache[val.owner] or {firstname="N/A",lastname="N/A"} end
            ownername = cache[val.owner].firstname.." "..cache[val.owner].lastname or "Nobody"
        end
      
        cb(ownername)
      end
    end)
end)

ESX.RegisterServerCallback('iCarWash:getOwner', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query.await('SELECT * FROM carwash WHERE owner = ?', {xPlayer.identifier}, function(owner)
  
    cb(owner)
  end)
end)

ESX.RegisterServerCallback('iCarWash:getBusinessMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.scalar('SELECT money FROM carwash WHERE owner = ? ', {xPlayer.identifier} , function(businesscash)
  
    cb(businesscash)
  end)
end)

RegisterServerEvent("iCarWash:removeMoney")
AddEventHandler("iCarWash:removeMoney", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeMoney(amount)

    MySQL.update('UPDATE carwash SET money = money + ?',{amount})
end)

RegisterServerEvent("iCarWash:addMoney")
AddEventHandler("iCarWash:addMoney", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.scalar('SELECT money FROM carwash WHERE owner = ?', {xPlayer.identifier}, function(money)
        if amount > 0 then
            if amount <= tonumber(money) then
                xPlayer.addMoney(amount)

                MySQL.update('UPDATE carwash SET money = money - ?', {amount})
            end
        end
    end)
end)
