Config = {}

Config.Hours = 24 -- how many hours players have to play for the reward
Config.Minutes = 59 -- do not touch (I don't even know why this is here :/)

Config.Reward = "vehicle" -- Can be "item", "vehicle" or "money"

Config.VehicleReward = "zentorno" -- vehicle will be spawned in the garage (owned_vehicles) (only if Config.Reward is "vehicle")
Config.MoneyReward = 10000 -- amount of money that will be given as a reward (only if Config.Reward is "money")
Config.ItemReward = "bread" -- item that will be given as a reward (only if Config.Reward is "item")
Config.ItemRewardCount = 1 -- count of items that will be given as a reward (only if Config.Reward is "item")

Config.PlateLetters = 3 -- How many plates letters will be created for the vehicle as a reward.
Config.PlateNumbers = 3 -- How many plates numbers will be created for the vehicle as a reward.
Config.PlateUseSpace = true	-- If the plates uses spaces between letters and numbers