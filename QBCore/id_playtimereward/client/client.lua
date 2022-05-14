local QBCore = exports['qb-core']:GetCoreObject()
local hours
local EVENT = TriggerServerEvent
local randomkey = 0

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	SetDisplay(not display)
    randomkey = key
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

Citizen.CreateThread(function()
	local minutes = GlobalState.Minutes
	while true do
		Citizen.Wait(60 * 1000)
		minutes = minutes - 1

		SendNUIMessage({action = 'whatminute', value = minutes})
		
		if minutes == 0 then
			EVENT("id_playtimereward:addHour")
			minutes = GlobalState.Minutes
		
			Citizen.Wait(1000)
			QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
				SendNUIMessage({action = 'whathour', value = hour})
			end)
		end
			
		QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
			if hour >= GlobalState.Hours then
				if GlobalState.Reward == "vehicle" then
					local plates = GeneratePlate()
					EVENT("id_playtimereward:giveReward", plates, randomkey)
				else
					EVENT("id_playtimereward:giveReward", randomkey)
				end
			end
		end)
	end
end)

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
