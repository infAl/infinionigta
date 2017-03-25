-- Infinion Irregular Goods Transportation Addon

package.path = package.path .. ";data/scripts/mods/?.lua"
local Config = require ("infinionigta/config")

local Mod = {}

-- Info for ModLoader
Mod.info = 
{
	name= Config.modName,
	version=Config.modVersion,
	description=Config.modDescription,
	author="infal",
	website="",
	icon=nil,
	dependency =
	{
		["Simple Mod Loader"]={ major=1, minor=2, revision=0 },
		["Infinion Corporation"]={ major=1, minor=0, revision=0 },
	},
	playerScript=Config.scriptPlayer,
	onInitialize=nil,
}

Mod.onInitialize = function()
	-- Use Mod Loader's built in function to add the Cargo Shield system upgrade to pirates at random
	registerSystemUpgradeAsLoot(scriptCargoShield, NPC.Pirate, ShipClass.Any, nil, chancePiratesDropCargoShield)
	
	-- Add the admin ui module to the mod loader admin ui
	registerAdminUIModule(Config.modName, Config.scriptAdminUI)
end

return Mod