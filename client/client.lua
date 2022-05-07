ESX = nil
local FirstSpawn = true
local hours

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("esx:playerSpawn")
AddEventHandler("esx:playerSpawn", function()
	Citizen.Wait(10000)

	SetDisplay(not display)

end)

AddEventHandler('playerSpawned', function()
	if FirstSpawn then
		SetDisplay(not display)
		FirstSpawn = false
	end
end)

function SetDisplay(bool)
    SendNUIMessage({
        type = "show",
        status = bool,
    })

	ESX.TriggerServerCallback("id_playtimereward:getHour", function(hour)
		SendNUIMessage({action = 'whathour', value = hour})
	end)

	SendNUIMessage({action = 'howmuchhours', value = Config.Hours})

	SendNUIMessage({action = 'whatminute', value = Config.Minutes})
end

Citizen.CreateThread(function()
	local minutes = Config.Minutes
	while true do
		Citizen.Wait(60000)
		minutes = minutes - 1
			
		SendNUIMessage({action = 'whatminute', value = minutes})
		
		if minutes == 0 then
			TriggerServerEvent("id_playtimereward:addHour")
			minutes = Config.Minutes
		
			ESX.TriggerServerCallback("id_playtimereward:getHour", function(hour)
				SendNUIMessage({action = 'whathour', value = hour + 1})
			end)
		end
			
		ESX.TriggerServerCallback("id_playtimereward:getHour", function(hour)
			if hour >= Config.Hours then
				TriggerServerEvent("id_playtimereward:giveReward")
			end
		end)
	end
end)