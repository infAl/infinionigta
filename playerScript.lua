-------------------------------------------------------------------------------
--	infinion igta/playerScript.lua
--
--	This script is attached to the player entity at log in and registers a
--  callback for when the player enters a new sector.
--
--  When the player enters a sector we search for any stations with 'Infinion'
--	in the title and add a script to the station that lets players purchase a
--	dangerous goods permit.
--
--	Also, look at any ships in the sector. For pirates, give them a chance at
--	dropping the cargo shielding module. For military ships, replace their
--	antismuggle script with a custom version.
--
-------------------------------------------------------------------------------

-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
require ("infinionigta/config")

if not disableMod then

package.path = package.path .. ";data/scripts/lib/?.lua"
require("utility")
require("randomext")


-- Local variables
local rarities = {}
	rarities[5] = 0.1	-- legendary
	rarities[4] = 1		-- exotic
	rarities[3] = 8		-- exceptional
	rarities[2] = 16	-- rare
	rarities[1] = 32	-- uncommon
	rarities[0] = 128	-- common


-- Avorion default functions
function initialize()
	Player():registerCallback("onSectorEntered", "onSectorEntered")
	
	if onServer() then
		-- Infinion Corp mod has an API function that lets us register our script so that any time an Infinion station
		-- is spawned, our script will automatically be added to the station.
		Player():invokeFunction("infinion/playerScript.lua", "registerExternalStationScript", scriptInfinionDialog)
	end
end

-- Event handler functions
function onSectorLeft(playerIndex, x, y)
	Sector():unregisterCallback("onEntityCreate")
	Sector():unregisterCallback("onEntityEntered")
end

function onSectorEntered(playerIndex, x, y)
	if onServer() then
		
		local sector = Sector()
		
		sector:registerCallback("onEntityCreate", "onEntityCreate")
		sector:registerCallback("onEntityEntered", "onEntityEntered")
		
		local shipList = {sector:getEntitiesByType(EntityType.Ship)}
		
		math.randomseed(sector.seed)
		
		for _, ship in pairs(shipList) do
		
			if ship:getValue("is_pirate") == 1 and math.random(1, 100) <= chancePiratesDropCargoShield then
				-- If the ship has the is_pirate value set, we can add a cargo shield system upgrade to their loot table
				-- Use a random to make it, well... more random - ie: not every pirate drops the module
				
				local rarity = Rarity(getValueFromDistribution(rarities))
				Loot(ship.index):insert(SystemUpgradeTemplate(scriptCargoShield, rarity, random():createSeed()))
			elseif ship:hasScript("entity/antismuggle.lua") then
				-- "Brainwashing"
				-- Find any military ships and replace their antismuggle script with our custom one
				
				ship:removeScript("entity/antismuggle.lua")
				ship:addScriptOnce(scriptAntiSmuggle)
			end
		end
	end		
end

function onEntityEntered(entityIndex)
	Server():broadcastChatMessage("Infinion IGTA", 0, "onEntityEntered")
	onEntityCreate(entityIndex)
end

function onEntityCreate(entityIndex)
	--Server():broadcastChatMessage("Infinion IGTA", 0, "onEntityCreate")

	local entity = Entity(entityIndex)
	local sector = Sector()
	math.randomseed(sector.seed)
	
	if entity.isShip then
		-- Check if the entity is a pirate or military ship
		if entity:getValue("is_pirate") == 1 and math.random(1, 100) <= chancePiratesDropCargoShield then
			-- If the ship has the is_pirate value set, we can add a cargo shield system upgrade to their loot table
			-- Use a random to make it, well... more random - ie: not every pirate drops the module
			
			local rarity = Rarity(getValueFromDistribution(rarities))
			Loot(entityIndex):insert(SystemUpgradeTemplate(scriptCargoShield, rarity, random():createSeed()))
			
		elseif entity:hasScript("entity/antismuggle.lua") then
			-- "Brainwashing"
			-- Find any military ships and replace their antismuggle script with our custom one
			
			entity:removeScript("entity/antismuggle.lua")
			entity:addScriptOnce(scriptAntiSmuggle)
		end
	end
end

else 
	-- disableMod is true
function initialize() terminate() end
end



















