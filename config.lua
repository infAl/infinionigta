-------------------------------------------------------------------------------
--	This file contains all of the strings and configurable values for the mod
--	and could be edited for language localisation
--
-------------------------------------------------------------------------------

local t = {}

-- Use disableMod if you want to uninstall.
-- At the moment, if the game engine can't find a script that is attached to an
-- object it doesn't work well.
-- Entities like ships seem to be deleted, players seem to be respawned as a different
-- faction and not 'own' any of their existing ships and stations.
-- Set disableMod to true and leave all the files in place. They will simply
-- load and then terminate
t.disableMod = false -- [true/false]

-- Mod info stuff
t.modName = "Infinion Irregular Goods Transportation Addon"
t.modVersion = {major=1, minor=0, revision=2}
t.modDescription = "Irregular Goods Transportation Addon makes it possible for the player to evade detection when transporting illegal, stolen or suspicious goods and to purchase a permit to legally transport dangerous goods.\nThis mod is an addon for the Infinion Corporation mod."


-- Config
t.chancePiratesDropCargoShield = 30 -- [1 - 100] Percent chance of a pirate dropping a cargo shield module
t.energyFactor = 0.9 -- Energy required for Cargo Shield Module is multiplied by this number. If you think they use too much power, make the number 0.5 or whatever
t.priceFactor = 1.0 -- Price for Cargo Shield Module is multiplied by this number
t.updateIntervalMinutes = 5 -- How often will the dangerous goods permit update the player on time remaining. Default is every 5 minutes.

-- Scripts
dir = "data/scripts/mods/infinionigta/"
t.scriptGoodsPermit = dir .. "goodspermit.lua"
t.scriptAntiSmuggle = dir .. "antismuggle.lua"
t.scriptCargoShield = dir .. "cargoshielding.lua"
t.scriptInfinionDialog = dir .. "infinion_goodspermit.lua"
t.scriptPlayer = dir .. "playerScript.lua"
t.scriptAdminUI = dir .. "adminui.lua"


-- Buying a permit from the station
t.dialogGreeting = "Infinion Corporation Welcomes you.\nYou are speaking with the AI module for this automated outpost. How may I be of assistance?"
t.dialogWantPermit = "I'm looking for a permit to transport dangerous goods."
t.dialogOfferPermits = "Of course. Infinion are the galaxy's most trusted authority for dangerous goods transportation permits.\nWhat period would you like the permit for?"
t.dialogOfferDifferentPermit = "Would you like to purchase a permit of a different period?"
t.dialogTooPoor = "Unfortunately you don't have enough credits to complete this transaction. My human emotion simulation sub routines are telling me that this is awkward...."
t.dialogChangedMind = "Actually, I changed my mind."
t.dialogBuy5 = "5 minutes - 10,000 credits"
t.dialogBuy15 = "15 minutes - 20,000 credits"
t.dialogBuy30 = "30 minutes - 30,000 credits"
t.dialogBuy60 = "60 minutes - 50,000 credits"


-- Notifications from the Goods Permit Script
t.infoTimeRemainingMS = "Your dangerous goods transportation permit will expire in %i minutes, %i seconds"
t.infoTimeRemainingM = "Your dangerous goods transportation permit will expire in %i minutes"
t.infoTimeExpired = "Your dangerous goods transportation permit has now expired"
t.goodsPermit = "Goods Permit"


-- Admin UI
t.adminUI = "Admin UI"
t.playersOnline = "Players Online"
t.adminIcon = "data/textures/icons/jigsaw-piece.png"
t.goodsPermit = "Dangerous Goods Transportation Permit"
t.cargoShield = "Cargo Shielding Upgrade"
t.minutes = "Minutes:"


-- Cargo Shielding System Upgrade
t.saveValueName = "CargoShieldingFactor"
t.cargoShieldIcon = "data/textures/icons/rosa-shield.png"
t.cargoShieldDescription = "Makes it harder for nosy military\nships to scan your cargo."
t.shieldingFactor = "Shielding Factor"
t.cargoHold = "Cargo Hold"
t.calibrating = "Your cargo cargo shield module is calibrating!\n%i seconds until shielding is online."
t.calibrateComplete = "Your cargo cargo shield module is online!\nShielding factor of %i."

-- Antismuggle
-- (only extracting the mod added strings. All the default ones can stay where they are)
t.scanFailed = "Your Cargo Shielding Module prevented the military ship from scanning your cargo."
t.beingScanned = "Your ship cargo is being scanned by a military ship!\nThey have a scanner strength of %i"

return t

















