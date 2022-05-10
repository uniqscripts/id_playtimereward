local QBCore = exports['qb-core']:GetCoreObject()

local playingforhour = false

local randomkey = math.random(1000000000000, 9999999999999)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(58000)
        playingforhour = true
        Citizen.Wait(2000)
        playingforhour = false
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    TriggerClientEvent('id_playtimereward:client:randomkey', source, randomkey)
end)

RegisterNetEvent("id_playtimereward:addHour")
AddEventHandler("id_playtimereward:addHour", function()
    local Player = QBCore.Functions.GetPlayer(source)

    if Player then
        if playingforhour then
	        MySQL.scalar('SELECT hour FROM players WHERE license = ?', {license}, function(hour)
	        	if hour < GlobalState.Hours then
                    MySQL.update.await('UPDATE players SET hour = hour + 1 WHERE license = ?', {license})
	        	end
	        end)
        else
            DropPlayer(GlobalState.KickMessage)
        end
    end
end)

QBCore.Functions.CreateCallback('id_playtimereward:getHour', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local plicense = Player.PlayerData.license
    
    if Player then
        MySQL.scalar('SELECT hour FROM players WHERE license = ?', {plicense}, function(hour)
          cb(hour)
        end)
    end
end)

QBCore.Functions.CreateCallback('id_playtimereward:isPlateTaken', function (source, cb, plate)
	MySQL.query('SELECT * FROM owned_vehicles WHERE plate = ?', {plate}, function (result)
		cb(result[1] ~= nil)
	end)
end)

RegisterNetEvent("id_playtimereward:giveReward")
AddEventHandler("id_playtimereward:giveReward", function(plates)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player then
        if (password ~= nil) then
            if (password == randomkey) then
	            MySQL.scalar('SELECT hour FROM players WHERE license = ?', {license}, function(hour)
                    if hour >= GlobalState.Hours then
                        MySQL.update('UPDATE players SET hour = 0 WHERE license = ?', {license})
                        if GlobalState.Reward == "vehicle" then
                            local mods =
                            '{"neonEnabled":[false,false,false,false],"modFrame":-1,"modEngine":3,"engineHealth":1000.0,"modSideSkirt":-1,"modFrontBumper":-1,"modOrnaments":-1,"health":995,"modGrille":-1,"modTransmission":2,"plate":"' ..
                            plates ..
                            '","modTrimB":-1,"fuelLevel":45.91801071167,"modDoorSpeaker":-1,"windows":[1,false,false,false,false,1,1,1,1,false,1,false,false],"modSpeakers":-1,"modAerials":-1,"modTurbo":1,"pearlescentColor":67,"modVanityPlate":-1,"modSpoilers":-1,"modAirFilter":-1,"modArchCover":-1,"tyreSmokeColor":[255,255,255],"modEngineBlock":-1,"modHood":-1,"modRightFender":-1,"bodyHealth":997.25,"dirtLevel":4.0228095054626,"wheels":0,"modPlateHolder":-1,"modBrakes":2,"wheelColor":156,"modSteeringWheel":-1,"modFender":-1,"color2":62,"color1":9,"neonColor":[255,0,255],"modExhaust":-1,"modDial":-1,"model":' ..
                            GetHashKey(GlobalState.VehicleReward) ..
                            ',"plateIndex":1,"windowTint":3,"modBackWheels":-1,"tyres":[false,false,false,false,false,false,false],"modTank":-1,"modHydrolic":-1,"modSmokeEnabled":1,"modRearBumper":-1,"modArmor":4,"modFrontWheels":-1,"modRoof":-1,"extras":[],"modAPlate":-1,"modXenon":1,"modLivery":-1,"modDashboard":-1,"modShifterLeavers":-1,"modTrimA":-1,"modTrunk":-1,"modHorns":-1,"modSeats":-1,"modSuspension":3,"modStruts":-1,"modWindows":-1,"doors":[false,false,false,false,false,false]}'
                        
                            MySQL.insert("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)", {license, plates, mods}, function(rowsChanged) 
                            end)
                        end
                    
                        if GlobalState.Reward == "money" then Player.Functions.AddMoney('bank', GlobalState.MoneyReward, "Bank deposit") end
                        if GlobalState.Reward == "item" then Player.Functions.AddItem(GlobalState.ItemReward, GlobalState.ItemRewardCount, 1, info) end
                    end
                end)
            else
                DropPlayer(GlobalState.KickMessage)
            end
        else
            DropPlayer(GlobalState.KickMessage)
        end
    end
end)
