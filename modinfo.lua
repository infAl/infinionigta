-- Infinion Irregular Goods Transportation Addon

package.path = package.path .. ";data/scripts/mods/?.lua"
require ("infinionigta/config")

local Mod = {}

-- Info for ModLoader
Mod.info = 
{
	name= modName,
	version=modVersion,
	description=modDescription,
	author="infal",
	website="",
	icon=nil,
	dependency =
	{
		["Simple Mod Loader"]={ major=1, minor=0, revision=0 },
		["Infinion Corporation"]={ major=1, minor=0, revision=0 },
	},
	playerScript=scriptPlayer,
	onInitialize=nil,
}

--ModLoader.register(Mod)
return Mod