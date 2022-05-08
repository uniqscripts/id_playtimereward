QBCore = nil
local hours

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	SetDisplay(not display)
end)

function SetDisplay(bool)
    SendNUIMessage({
        type = "show",
        status = bool,
    })

	QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
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

		local plates = GeneratePlate()

		SendNUIMessage({action = 'whatminute', value = minutes})
		
		if minutes == 0 then
			TriggerServerEvent("id_playtimereward:addHour")
			minutes = Config.Minutes
		
			Citizen.Wait(1000)
			QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
				SendNUIMessage({action = 'whathour', value = hour})
			end)
		end
			
		QBCore.Functions.TriggerCallback("id_playtimereward:getHour", function(hour)
			if hour >= Config.Hours then
				if Config.Reward == "vehicle" then
					TriggerServerEvent("id_playtimereward:giveReward", plates)
				else
					TriggerServerEvent("id_playtimereward:giveReward")
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
		if Config.PlateUseSpace then
			generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. ' ' .. GetRandomNumber(Config.PlateNumbers))
		else
			generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. GetRandomNumber(Config.PlateNumbers))
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