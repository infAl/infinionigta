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
require ("infinionigta/config")

if not disableMod then

package.path = package.path .. ";data/scripts/systems/?.lua"
require ("basesystem")

package.path = package.path .. ";data/scripts/lib/?.lua"
require ("utility")
require ("randomext")

function getBonuses(seed, rarity)
    math.randomseed(seed)
	local perc = (30 - (rarity.value * 5) + math.random(-2, 2))/100

    return perc
end

function onInstalled(seed, rarity)
    local perc = getBonuses(seed, rarity) * -1

    addBaseMultiplier(StatsBonuses.CargoHold, perc)
	
	-- Saving the shielding factor to the ship's "value" table.
	Entity():setValue(saveValueName, rarity.value +2)
end

function onUninstalled(seed, rarity)
	Entity():setValue(saveValueName, nil)
end

function getName(seed, rarity)
   return cargoShield
end

function getIcon(seed, rarity)
    return cargoShieldIcon
end

function getEnergy(seed, rarity)
    return rarity.value * 1000 * 1000 * 1000
end

function getPrice(seed, rarity)
    return 4500 * 2.5 ^ rarity.value
end

function getTooltipLines(seed, rarity)

    local texts = {}
    local perc = getBonuses(seed, rarity)

    table.insert(texts, {ltext = cargoHold, rtext = string.format("-%i%%", perc * 100), icon = "data/textures/icons/wooden-crate.png"})
	table.insert(texts, {ltext = shieldingFactor, rtext = string.format("%i", rarity.value+2), icon = cargoShieldIcon})

    return texts
end

function getDescriptionLines(seed, rarity)
    return
    {
        {ltext = cargoShieldDescription, lcolor = ColorRGB(1, 0.5, 0.5)}
    }
end

function getShieldingFactor()
	return Entity():getValue(saveValueName)
end

else 
	-- disableMod is true
function initialize() terminate() end
end

