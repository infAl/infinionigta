-------------------------------------------------------------------------------
--	infinionigta/playerScript.lua
--
--	This script is attached to the player entity at log in and registers a
--  callback for when the player enters a new sector, leaves the sector and
--	when entities are created in the sector
--
--	For the onSectorEntered and onEntityCreate events we look at the ships
--	and if they are military ships, replace their antismuggle script with a
--	custom version.
--
-------------------------------------------------------------------------------

-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
local Config = require ("infinionigta/config")

if not Config.disableMod then

package.path = package.path .. ";data/scripts/lib/?.lua"
require("utility")
require("randomext")

-- Avorion default functions
function initialize()
	if onServer() then

		-- Infinion Corp mod has an API function that lets us register our script so that any time an Infinion station
		-- is spawned, our script will automatically be added to the station.
		Player():invokeFunction("infinion/playerScript.lua", "registerExternalStationScript", Config.scriptInfinionDialog)

		local player = Player()
		player:registerCallback("onSectorEntered", "onSectorEntered")
		player:registerCallback("onSectorLeft", "onSectorLeft")

		Sector():registerCallback("onEntityCreate", "onEntityCreate")
	end
end

-- Event handler functions
function onSectorLeft(playerIndex, x, y)
	if Player().index ~= playerIndex then return end
	if onServer() then
		--printlog("<Infinion IGTA:onSectorLeft> x: %i, y: %i", x, y)
		Sector():unregisterCallback("onEntityCreate", "onEntityCreate")
	end
end

function onSectorEntered(playerIndex, x, y)
	if Player().index ~= playerIndex then return end
	if onServer() then		
		local sector = Sector()
		sector:registerCallback("onEntityCreate", "onEntityCreate")
		
		local shipList = {sector:getEntitiesByType(EntityType.Ship)}		
		for _, ship in pairs(shipList) do
			if ship:hasScript("entity/antismuggle.lua") then
				-- "Brainwashing"
				-- Find any military ships and replace their antismuggle script with our custom one
				ship:removeScript("entity/antismuggle.lua")
				ship:addScriptOnce(Config.scriptAntiSmuggle)
			end
		end
	end		
end

function onEntityCreate(entityIndex)
	if onServer() then
		if Entity(entityIndex).isShip then
			-- For some reason the game doesn't return Entity():getValue("is_pirate") when called
			-- from this function but works fine if we call from a deferredCallback with 1 sec delay
			deferredCallback(1, "deferredEntityCreate", entityIndex)
		end
	end
end

function deferredEntityCreate(entityIndex)
	local entity = Entity(entityIndex)
	local sector = Sector()
	-- Check if the entity is a military ship
	if entity:hasScript("entity/antismuggle.lua") then
		-- "Brainwashing"
		-- Find any military ships and replace their antismuggle script with our custom one
		entity:removeScript("entity/antismuggle.lua")
		entity:addScriptOnce(Config.scriptAntiSmuggle)
	end
end

else 
	-- disableMod is true
function initialize() terminate() end
end



















