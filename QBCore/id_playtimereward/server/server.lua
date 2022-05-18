local QBCore = exports['qb-core']:GetCoreObject()
local ActivePlayerTimers = {}
local randomkey = math.random(1000000000000, 9999999999999)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    TriggerClientEvent('id_playtimereward:client:randomkey', source, randomkey)
end)

RegisterNetEvent('QBCore:Server:PlayerLoaded')
AddEventHandler('QBCore:Server:PlayerLoaded', function (Player)
    ActivePlayerTimers[Player.PlayerData.source] = os.time()
end)

RegisterNetEvent("id_playtimereward:addHour")
AddEventHandler("id_playtimereward:addHour", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid

    if (math.ceil((os.time() - ActivePlayerTimers[src])/60) < (GlobalState.Minutes - 1)) then
        DropPlayer(src, GlobalState.KickMessage)
        return
    end

    if Player then
        MySQL.scalar('SELECT hour FROM players WHERE citizenid = ?', {cid}, function(hour)
            if hour < GlobalState.Hours then
                MySQL.update.await('UPDATE players SET hour = hour + 1 WHERE citizenid = ?', {cid})
                ActivePlayerTimers[src] = os.time()
            end
        end)  
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
	    MySQL.scalar('SELECT hour FROM players WHERE license = ?', {license}, function(hour)
            if hour >= GlobalState.Hours then
                MySQL.update('UPDATE players SET hour = 0 WHERE license = ?', {license})
                if GlobalState.Reward == "vehicle" then
                    local mods = '{"model":'..GetHashKey(GlobalState.VehicleReward)..',"modSuspension":-1,"modTransmission":-1,"modFrontWheels":-1,"modTurbo":false,"modDashboard":-1,"modSeats":-1,"color2":62,"modFender":-1,"modHydrolic":-1,"modArchCover":-1,"dirtLevel":4.76596940834568,"modTrimA":-1,"xenonColor":255,"fuelLevel":100.08535757525947,"modKit17":-1,"modSteeringWheel":-1,"modWindows":-1,"modExhaust":-1,"modKit47":-1,"modStruts":-1,"modArmor":-1,"wheelColor":156,"tireBurstState":{"1":false,"2":false,"3":false,"4":false,"5":false,"0":false},"modSpoilers":-1,"modHorns":-1,"modAPlate":-1,"modTrunk":-1,"modTank":-1,"liveryRoof":-1,"modAerials":-1,"modBackWheels":-1,"tyreSmokeColor":[255,255,255],"modTrimB":-1,"modSideSkirt":-1,"modOrnaments":-1,"extras":[],"modRearBumper":-1,"modFrontBumper":-1,"wheelWidth":0.0,"windowStatus":{"1":true,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"0":true},"modFrame":-1,"modEngine":-1,"modLivery":-1,"modSpeakers":-1,"doorStatus":{"1":false,"2":false,"3":false,"4":false,"5":false,"0":false},"modAirFilter":-1,"oilLevel":4.76596940834568,"modRoof":-1,"interiorColor":112,"windowTint":-1,"modBrakes":-1,"modEngineBlock":-1,"bodyHealth":1000.0592475178704,"modCustomTiresF":false,"modCustomTiresR":false,"wheelSize":0.0,"modKit49":-1,"modShifterLeavers":-1,"pearlescentColor":18,"modPlateHolder":-1,"modDial":-1,"tireHealth":{"1":1000.0,"2":1000.0,"3":1000.0,"0":1000.0},"modSmokeEnabled":false,"modXenon":false,"modDoorSpeaker":-1,"modVanityPlate":-1,"neonColor":[0,0,0],"modGrille":-1,"engineHealth":1000.0592475178704,"dashboardColor":112,"neonEnabled":{"1":false,"2":false,"3":false,"0":false},"modRightFender":-1,"modKit19":-1,"color1":1,"tankHealth":1000.0592475178704,"headlightColor":255,"tireBurstCompletely":{"1":false,"2":false,"3":false,"4":false,"5":false,"0":false},"wheels":0,"plateIndex":0,"modKit21":-1,"modHood":-1,"plate": "' ..plates..'"}'
                    MySQL.insert("INSERT INTO player_vehicles (license, citizenid, plate, mods, vehicle, hash, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {license, cid, plates, mods, GlobalState.VehicleReward, GetHashKey(GlobalState.VehicleReward), 'legion', 1}, function(rowsChanged))
                end
                if GlobalState.Reward == "money" then Player.Functions.AddMoney('bank', GlobalState.MoneyReward, "Bank deposit") end
                if GlobalState.Reward == "item" then Player.Functions.AddItem(GlobalState.ItemReward, GlobalState.ItemRewardCount, 1, info) end
            end
        end)
    end
end)
