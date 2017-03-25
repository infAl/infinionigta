-------------------------------------------------------------------------------
--
--	This script is a system upgrade that will interact with the defender
--	script. (antismuggle.lua)
--	When the defender scans a ship for irregular goods, if the ship has this
--	cargo shielding module, they will have a shielding factor. The defender will
--	have a scanning factor.
--	If the shielding factor is greater than the scanning factor the defender
--	will not be able to scan the cargo.
--	If the shielding factor is equal to or less than the scanning factor,
--	there will be a random chance to block scanning.
--	
--
-------------------------------------------------------------------------------

-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
local Config = require ("infinionigta/config")

if not Config.disableMod then

package.path = package.path .. ";data/scripts/modloader/lib/?.lua"
require ("enums")

package.path = package.path .. ";data/scripts/systems/?.lua"
require ("basesystem")

package.path = package.path .. ";data/scripts/lib/?.lua"
require ("utility")
require ("randomext")

local isCalibrated = false

function getBonuses(seed, rarity)
    math.randomseed(seed)
	local perc = (30 - (rarity.value * 5) + math.random(-2, 2))/100

    return perc
end

function onInstalled(seed, rarity)
    local perc = getBonuses(seed, rarity) * -1

    addBaseMultiplier(StatsBonuses.CargoHold, perc)
	
	-- Saving the shielding factor to the ship's "value" table.
	Entity():setValue(Config.saveValueName, rarity.value + 2)
end

function onUninstalled(seed, rarity)
	Entity():setValue(Config.saveValueName, nil)
end

function getName(seed, rarity)
   return Config.cargoShield
end

function getIcon(seed, rarity)
    return Config.cargoShieldIcon
end

function getEnergy(seed, rarity)
	math.randomseed(seed)
    return (rarity.value ^ 2  * Metric.Giga + math.random() * Metric.Mega) * Config.energyFactor
end

function getPrice(seed, rarity)
    return (4500 * 2.5 ^ rarity.value) * Config.priceFactor
end

function getTooltipLines(seed, rarity)

    local texts = {}
    local perc = getBonuses(seed, rarity)

    table.insert(texts, {ltext = Config.cargoHold, rtext = string.format("-%i%%", perc * 100), icon = "data/textures/icons/wooden-crate.png"})
	table.insert(texts, {ltext = Config.shieldingFactor, rtext = string.format("%i", rarity.value+2), icon = Config.cargoShieldIcon})

    return texts
end

function getDescriptionLines(seed, rarity)
    return
    {
        {ltext = Config.cargoShieldDescription, lcolor = ColorRGB(1, 0.5, 0.5)}
    }
end

function getShieldingFactor()
	return Entity():getValue(Config.saveValueName)
end


else 
	-- disableMod is true
function initialize() terminate() end
end

