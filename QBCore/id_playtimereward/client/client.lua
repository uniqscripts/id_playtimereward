local QBCore = exports['qb-core']:GetCoreObject()
local hours
local EVENT = TriggerServerEvent

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	Citizen.CreateThread(function()
		SetDisplay(not display)

		local minutes = GlobalState.Minutes
		TriggerServerEvent('id_playtimereward:server:playerLoaded')
		while true  do
			Citizen.Wait(60000)
			minutes = minutes - 1
	
			SendNUIMessage({action = 'whatminute', value = minutes})
	
			if minutes == 0 then
				QBCore.Functions.TriggerCallback("id_playtimereward:addHour", function() end)
				minutes = GlobalState.Minutes
				SendNUIMessage({action = 'whatminute', value = minutes})

				QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
					SendNUIMessage({action = 'whathour', value = hour})
					if hour >= GlobalState.Hours then
						if GlobalState.Reward == "vehicle" then
							local plates = GeneratePlate()
							EVENT("id_playtimereward:giveReward", plates)
						else
							EVENT("id_playtimereward:giveReward")
						end
					end
				end)
			end
		end
	end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	TriggerServerEvent('id_playtimereward:server:playerUnloaded')
end)

function SetDisplay(bool)
    SendNUIMessage({
        type = "show",
        status = bool,
    })

	QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
		SendNUIMessage({action = 'whathour', value = hour})
	end)

	SendNUIMessage({action = 'howmuchhours', value = GlobalState.Hours})

	SendNUIMessage({action = 'whatminute', value = GlobalState.Minutes})
end

-- Plate generation for vehicle as a reward
local NumberCharset = {}
local Charset = {}

for i = 48,	57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,	90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	local generatedPlate
	local doBreak = false

	while true do
		Citizen.Wait(0)
		math.randomseed(GetGameTimer())
		if GlobalState.PlateUseSpace then
			generatedPlate = string.upper(GetRandomLetter(GlobalState.PlateLetters) .. ' ' .. GetRandomNumber(GlobalState.PlateNumbers))
		else
			generatedPlate = string.upper(GetRandomLetter(GlobalState.PlateLetters) .. GetRandomNumber(GlobalState.PlateNumbers))
		end

		QBCore.Functions.TriggerCallback('id_playtimereward:isPlateTaken', function(isPlateTaken)
			if not isPlateTaken then
				doBreak = true
			end
		end, generatedPlate)

		if doBreak then
			break
		end
	end

	return generatedPlate
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end
