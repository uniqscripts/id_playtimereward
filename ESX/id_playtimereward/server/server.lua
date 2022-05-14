ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local randomkey = math.random(1000000000000, 9999999999999)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    TriggerClientEvent('id_playtimereward:client:randomkey', source, randomkey)
end)

RegisterNetEvent("id_playtimereward:addHour")
AddEventHandler("id_playtimereward:addHour", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.scalar('SELECT hour FROM users WHERE identifier = ?', {xPlayer.identifier}, function(hour)
	        if hour < GlobalState.Hours then
                MySQL.update('UPDATE users SET hour = hour + 1 WHERE identifier = ?', {xPlayer.identifier})
	        end
	    end)
    end
end)

ESX.RegisterServerCallback('id_playtimereward:getHour', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.scalar('SELECT hour FROM users WHERE identifier = ?', {xPlayer.identifier}, function(hour)
            cb(hour)
	    end)
    end
end)

ESX.RegisterServerCallback('id_playtimereward:isPlateTaken', function (source, cb, plate)
	local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})
	cb(result[1] ~= nil)
end)


RegisterNetEvent("id_playtimereward:giveReward")
AddEventHandler("id_playtimereward:giveReward", function(plates, password)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        MySQL.scalar('SELECT hour FROM users WHERE identifier = ?', {xPlayer.identifier}, function(hour)
        if hour >= GlobalState.Hours then
            MySQL.update('UPDATE users SET hour = 0 WHERE identifier = ?', {xPlayer.identifier})
            if GlobalState.Reward == "vehicle" then
                local mods =
                '{"neonEnabled":[false,false,false,false],"modFrame":-1,"modEngine":3,"engineHealth":1000.0,"modSideSkirt":-1,"modFrontBumper":-1,"modOrnaments":-1,"health":995,"modGrille":-1,"modTransmission":2,"plate":"' ..
                plates ..
                '","modTrimB":-1,"fuelLevel":45.91801071167,"modDoorSpeaker":-1,"windows":[1,false,false,false,false,1,1,1,1,false,1,false,false],"modSpeakers":-1,"modAerials":-1,"modTurbo":1,"pearlescentColor":67,"modVanityPlate":-1,"modSpoilers":-1,"modAirFilter":-1,"modArchCover":-1,"tyreSmokeColor":[255,255,255],"modEngineBlock":-1,"modHood":-1,"modRightFender":-1,"bodyHealth":997.25,"dirtLevel":4.0228095054626,"wheels":0,"modPlateHolder":-1,"modBrakes":2,"wheelColor":156,"modSteeringWheel":-1,"modFender":-1,"color2":62,"color1":9,"neonColor":[255,0,255],"modExhaust":-1,"modDial":-1,"model":' ..
                GetHashKey(GlobalState.VehicleReward) ..
                ',"plateIndex":1,"windowTint":3,"modBackWheels":-1,"tyres":[false,false,false,false,false,false,false],"modTank":-1,"modHydrolic":-1,"modSmokeEnabled":1,"modRearBumper":-1,"modArmor":4,"modFrontWheels":-1,"modRoof":-1,"extras":[],"modAPlate":-1,"modXenon":1,"modLivery":-1,"modDashboard":-1,"modShifterLeavers":-1,"modTrimA":-1,"modTrunk":-1,"modHorns":-1,"modSeats":-1,"modSuspension":3,"modStruts":-1,"modWindows":-1,"doors":[false,false,false,false,false,false]}'
                MySQL.Async.execute(
                    "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",
                    {
                        ["@owner"] = xPlayer.identifier,
                        ["@plate"] = plates,
                        ["@vehicle"] = mods
                    },
                    function(rowsChanged)
                    end
                )
            end
            if GlobalState.Reward == "money" then xPlayer.addMoney(GlobalState.MoneyReward) end
            if GlobalState.Reward == "item" then xPlayer.addInventoryItem(GlobalState.ItemReward, GlobalState.ItemRewardCount) end
        else DropPlayer(GlobalState.KickMessage) end
        end)
    end
end)
