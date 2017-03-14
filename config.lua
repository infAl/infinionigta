-------------------------------------------------------------------------------
--	This file contains all of the strings and configurable values for the mod
--	and could be edited for language localisation
--
-------------------------------------------------------------------------------

-- Use disableMod if you want to uninstall.
-- At the moment, if the game engine can't find a script that is attached to an
-- object it doesn't work well.
-- Entities like ships seem to be deleted, players seem to be respawned as a different
-- faction and not 'own' any of their existing ships and stations.
-- Set disableMod to true and leave all the files in place. They will simply
-- load and then terminate
disableMod = false -- [true/false]


modName = "Infinion Irregular Goods Transportation Addon"
modVersion = {major=1, minor=0, revision=0}
modDescription = "Irregular Goods Transportation Addon makes it possible for the player to evade detection when transporting illegal, stolen or suspicious goods and to purchase a permit to legally transport dangerous goods.\nThis mod is an addon for the Infinion Corporation mod."


-- Config
chancePiratesDropCargoShield = 30 -- [1 - 100] Percent chance of a pirate dropping a cargo shield module

-- Scripts
dir = "data/scripts/mods/infinionigta/"
scriptGoodsPermit = dir .. "goodspermit.lua"
scriptAntiSmuggle = dir .. "antismuggle.lua"
scriptCargoShield = dir .. "cargoshielding.lua"
scriptInfinionDialog = dir .. "infinion_goodspermit.lua"
scriptPlayer = dir .. "playerScript.lua"
scriptAdminUI = dir .. "admin.lua"


-- Buying a permit from the station
dialogGreeting = "Infinion Corporation Welcomes you.\nYou are speaking with the AI module for this automated outpost. How may I be of assistance?"
dialogWantPermit = "I'm looking for a permit to transport dangerous goods."
dialogOfferPermits = "Of course. Infinion are the galaxy's most trusted authority for dangerous goods transportation permits.\nWhat period would you like the permit for?"
dialogOfferDifferentPermit = "Would you like to purchase a permit of a different period?"
dialogTooPoor = "Unfortunately you don't have enough credits to complete this transaction. My human emotion simulation sub routines are telling me that this is awkward...."
dialogChangedMind = "Actually, I changed my mind."
dialogBuy5 = "5 minutes - 10,000 credits"
dialogBuy15 = "15 minutes - 20,000 credits"
dialogBuy30 = "30 minutes - 30,000 credits"
dialogBuy60 = "60 minutes - 50,000 credits"


-- Notifications from the Goods Permit Script
infoTimeRemainingMS = "Your dangerous goods transportation permit will expire in %i minutes, %i seconds"
infoTimeRemainingM = "Your dangerous goods transportation permit will expire in %i minutes"
infoTimeExpired = "Your dangerous goods transportation permit has now expired"
goodsPermit = "Goods Permit"


-- Admin UI
adminUI = "Admin UI"
playersOnline = "Players Online"
adminIcon = "data/textures/icons/jigsaw-piece.png"
goodsPermit = "Dangerous Goods Transportation Permit"
cargoShield = "Cargo Shielding Upgrade"
minutes = "Minutes:"


-- Cargo Shielding System Upgrade
saveValueName = "CargoShieldingFactor"
cargoShieldIcon = "data/textures/icons/rosa-shield.png"
cargoShieldDescription = "Makes it harder for nosy military\nships to scan your cargo."
shieldingFactor = "Shielding Factor"
cargoHold = "Cargo Hold"

-- Antismuggle
-- (only extracting the mod added strings. All the default ones can stay where they are)
scanFailed = "Your Cargo Shielding Module prevented the military ship from scanning your cargo."
beingScanned = "Your ship cargo is being scanned by a military ship!\nThey have a scanner strength of %i"



















