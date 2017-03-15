-------------------------------------------------------------------------------
--
--	This script will replace the standard antismuggle.lua and allow the player
-- to evade detection of illegal, suspicious and stolen goods with a cargo
-- shielding system or legally carry dangerous goods with a permit.
--
-------------------------------------------------------------------------------

-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
require ("infinionigta/config")

if not disableMod then

package.path = package.path .. ";data/scripts/lib/?.lua"
require ("galaxy")
require ("stringutility")
require ("randomext")
ShipUtility = require ("shiputility")


local suspicion

local values = {}
values.timeOut = 60

local scannerTicker = 0
local scannerTick = 10

local scannerStrength = 2
local didScanFail
local scannedPlayer
local scanFailTicker = 0

local suspicionDetectedTicker = 0


-- This function is to allow a few seconds to pass between the player being warned that their ship is
-- being scanned and being told that the scan failed
function updateScanStatus(timestep)
	scanFailTicker = scanFailTicker + timestep
	if scanFailTicker < scannerTick then return end
	scanFailTicker = 3
	
	if scannedPlayer and didScanFail then
		-- A player's ship was scanned and the scan failed because of their cargo shielding
		-- so let the player know.
		scannedPlayer:sendChatMessage("", 3, scanFailed)
		scannedPlayer = nil
		didScanFail = false
	end
end


function initialize()
    if onServer() then
        Sector():registerCallback("onDestroyed", "onEntityDestroyed")
        scannerTicker = Entity().index % scannerTick
		
		-- The defender's scanner strength is based on their volume
		local maxVolumes = ShipUtility.getMaxVolumes()
		for i, w in pairs(maxVolumes) do
			if Entity().volume < w then
				scannerStrength = math.ceil(i / 2)
				break
			end
		end
    end
end

function getUpdateInterval()
    return 1.0
end

function updateServer(timeStep)
    updateSuspiciousShipDetection(timeStep)
    updateSuspicionDetectedBehaviour(timeStep)
	updateScanStatus(timeStep)
end

function updateSuspiciousShipDetection(timeStep)

    scannerTicker = scannerTicker + timeStep

    -- scan for suspicious ships
    if scannerTicker < scannerTick then return end
    scannerTicker = 0

    if suspicion then return end

    local self = Entity()
    local sphere = self:getBoundingSphere()

    local scannerDistance = 400.0

    local faction = Faction()
    sphere.radius = scannerDistance * (1.0 + 0.5 * faction:getTrait("paranoid"))

    local entities = {Sector():getEntitiesByLocation(sphere)}
    for _, ship in pairs(entities) do

        if suspicion then break end
        if not ship.factionIndex then break end
        if ship.factionIndex == 0 then break end

        if ship.index ~= self.index then

            local faction = Faction(ship.factionIndex)
            if valid(faction) and faction.isPlayer then
			
				-- Make it so that ships can only be scanned once per 60 seconds
				local saveValueName = string.format("shipLastScannedAt_%i", ship.index)
				local playerLastScannedAt = Sector():getValue(saveValueName) or 0
				if os.time() < playerLastScannedAt + 60 then return end
				Sector():setValue(saveValueName, os.time())

                if ship:hasComponent(ComponentType.CargoBay) then
				
					-- Inform the player their ship is being scanned
					local player = Player(ship.factionIndex)
					player:sendChatMessage(self.title, 2, beingScanned, scannerStrength);
					
					--Does the target ship have cargo shielding?
					local cargoShieldingFactor = 0
					if ship:hasScript(scriptCargoShield) then
						local _, cargoShieldingFactor = ship:invokeFunction(scriptCargoShield, "getShieldingFactor")
						
						if cargoShieldingFactor > scannerStrength then
							-- The target ship's shielding factor is better than this defender's
							-- scanning factor so, 100% unable to see irregular goods.
							didScanFail = true
							scannedPlayer = player
							return
						else
							local delta = scannerStrength - cargoShieldingFactor
							math.randomseed(Sector().seed)
							if delta < math.random(1, 10) then
								-- Defender was unable to scan the target. Player got lucky!
								didScanFail = true
								scannedPlayer = player
								return
							end
						end
					end
					
					-- Does the ship have a dangerous goods transport permit?
					local hasDangerousGoodsPermit = false
					if ship:hasScript(scriptGoodsPermit) then
						hasDangerousGoodsPermit = true
					end
					
                    for good, amount in pairs(ship:getCargos()) do
                        local payment = 0.0

                        if good.suspicious then
                            suspicion = suspicion or {type = 0}
                            payment = 1.5
                        end

                        if good.illegal then
                            suspicion = suspicion or {type = 1}
                            payment = 2.0
                        end

                        if good.stolen then
                            suspicion = suspicion or {type = 2}
                            payment = 3.0
                        end

                        if good.dangerous then
							
							if not hasDangerousGoodsPermit then
								suspicion = suspicion or {type = 3}
								payment = 1.5
							end
                        end

                        -- make sure this craft is not yet suspected by another defender
                        local suspectedBy = Sector():getValue(string.format("suspected_by_%i", ship.index))
                        if suspectedBy then suspicion = nil end

                        if suspicion then
                            suspicion.ship = ship
                            suspicion.index = ship.index
                            suspicion.player = Player(ship.factionIndex)
                            suspicion.fine = (suspicion.fine or 0) + (good.price * amount + 1500 * Balancing_GetSectorRichnessFactor(Sector():getCoordinates())) * payment
                            suspicion.fine = suspicion.fine * (1.0 + 0.5 * faction:getTrait("greedy"))

                            suspicion.fine = math.floor(suspicion.fine / 100) * 100
                        end
                    end
                end
            end
        end
    end

    if suspicion then
        -- register the suspicion
        Sector():setValue(string.format("suspected_by_%i", suspicion.index), self.index)
	end
end

function updateSuspicionDetectedBehaviour(timeStep)
    if not suspicion then return end
	
	-- Don't run this every second
	suspicionDetectedTicker = suspicionDetectedTicker + timeStep
    if suspicionDetectedTicker < scannerTick then return end
    suspicionDetectedTicker = 5

    local self = Entity()
    local sphere = self:getBoundingSphere()

    --
    if not valid(suspicion.ship) then
        local faction = Faction()
        Galaxy():changeFactionRelations(faction, suspicion.player, -25000 - (10000 * faction:getTrait("strict")))
        resetSuspicion()
        return
    end

    -- start talking, start timer for response
    if not suspicion.talkedTo then
        suspicion.talkedTo = true
        suspicion.timeOut = values.timeOut

        local faction = Faction()
        Galaxy():changeFactionRelations(faction, suspicion.player, -5000 - (2500 * faction:getTrait("strict")))

        invokeClientFunction(suspicion.player, "startTalk", suspicion.type, suspicion.fine)
    end

    -- if they don't respond in time, they are considered an enemy
    if not suspicion.responded then
        suspicion.timeOut = suspicion.timeOut - 1
        if suspicion.timeOut <= 0 then
            ShipAI():registerEnemyEntity(suspicion.ship.index)
        end

        if suspicion.timeOut == 0 then
            invokeClientFunction(suspicion.player, "startEnemyTalk")
        end
    end

    -- fly towards the suspicious ship
    if suspicion.responded or suspicion.timeOut > 0 then

        if self:hasScript("ai/patrol.lua") then
            self:invokeFunction("ai/patrol.lua", "setWaypoints", {suspicion.ship.translationf})
        else
            ShipAI():setFly(suspicion.ship.translationf, sphere.radius + 30.0)
        end

        if suspicion.responded and self:getNearestDistance(suspicion.ship) < 80.0 then
            
			-- Does the ship have a dangerous goods transport permit?
			local hasDangerousGoodsPermit = false
			if suspicion.ship:hasScript(scriptGoodsPermit) then
				hasDangerousGoodsPermit = true
			end
			
			-- take away the cargo
            for good, amount in pairs(suspicion.ship:getCargos()) do
                if good.suspicious
                    or good.illegal
                    or good.stolen then
                    
                    suspicion.ship:removeCargo(good, amount)
					
				elseif good.dangerous and not hasDangerousGoodsPermit then
					-- Only take dangerous goods if they don't have a permit
					suspicion.ship:removeCargo(good, amount)
                end
				
            end

            -- case closed, suspicion removed
            resetSuspicion()
        end
    end

end

function onDestroyed(index)
    if suspicion and valid(suspicion.ship) and suspicion.ship.index == index then
        resetSuspicion()
    end
end

function resetSuspicion()
    if suspicion then
        -- remove the suspicion
        Sector():setValue(string.format("suspected_by_%i", suspicion.index), nil)
    end

    suspicion = nil
    local self = Entity()
    if self:hasScript("ai/patrol.lua") then
        self:invokeFunction("ai/patrol.lua", "setWaypoints", nil)
    else
        ShipAI():setIdle()
    end
end

function makeSuspiciousDialog(fine)
    values.fine = fine

    local dialog0 = {}
    dialog0.text = "Hello. This is a routine scan. Please remain calm.\n\nYour cargo will be confiscated and we will have to fine you ${fine} credits.\n\nYou have ${timeOut} seconds to respond."%_t % values

    dialog0.answers = {
        {answer = "Comply"%_t, onSelect = "onComply", text = "Thank you for your cooperation.\n\nRemain where you are. We will now approach you and confiscate your cargo."%_t},
        {answer = "[Ignore]"%_t, onSelect = "onIgnore"}
    }

    return dialog0
end

function makeIllegalDialog(fine)
    values.fine = fine

    local dialog0 = {}
    dialog0.text = "Hold on. Our scanners show illegal cargo on your ship.\n\nYour cargo will be confiscated and you are fined ${fine} credits.\n\nYou have ${timeOut} seconds to respond."%_t % values

    dialog0.answers = {
        {answer = "Comply"%_t, onSelect = "onComply", text = "Thank you for your cooperation.\n\nRemain where you are. We will now approach you and confiscate your cargo."%_t},
        {answer = "[Ignore]"%_t, onSelect = "onIgnore"}
    }

    return dialog0
end

function makeStolenDialog(fine)
    values.fine = fine

    local dialog0 = {}
    dialog0.text = "Hold on. Our scanners show stolen cargo on your ship.\n\nYour cargo will be confiscated and you are fined ${fine} credits.\n\nYou have ${timeOut} seconds to respond."%_t % values

    dialog0.answers = {
        {answer = "Comply"%_t, onSelect = "onComply", text = "Thank you for your cooperation.\n\nRemain where you are. We will now approach you and confiscate your cargo."%_t},
        {answer = "[Ignore]"%_t, onSelect = "onIgnore"}
    }

    return dialog0
end

function makeDangerousDialog(fine)
    values.fine = fine

    local dialog0 = {}
    dialog0.text = "Hold on. Our scanners show dangerous cargo on your ship.\n\nAccording to our records, you don't have transportation permit for dangerous cargo in our area.\n\nYour cargo will be confiscated and you are fined ${fine} credits.\n\nYou have ${timeOut} seconds to respond."%_t % values

    dialog0.answers = {
        {answer = "Comply"%_t, onSelect = "onComply", text = "Thank you for your cooperation.\n\nRemain where you are. We will now approach you and confiscate your cargo."%_t},
        {answer = "[Ignore]"%_t, onSelect = "onIgnore"}
    }

    return dialog0
end


function startTalk(type, fine)
    local dialog = nil

    fine = createMonetaryString(fine)

    if type == 0 then
        dialog = makeSuspiciousDialog(fine)
    elseif type == 1 then
        dialog = makeIllegalDialog(fine)
    elseif type == 2 then
        dialog = makeStolenDialog(fine)
    elseif type == 3 then
        dialog = makeDangerousDialog(fine)
    end

    ScriptUI():interactShowDialog(dialog, 0)
end

function startEnemyTalk(type)
    local dialog = {text = "Your non-responsiveness is considered a hostile act."%_t}

    ScriptUI():interactShowDialog(dialog, 0)
end


function onComply()
    if onClient() then
        invokeServerFunction("onComply")
        return
    end

    if suspicion and suspicion.player and suspicion.player.index == callingPlayer then
        suspicion.responded = true
        Player(callingPlayer):pay(suspicion.fine)
    end
end

function onIgnore()
end

else 
	-- disableMod is true
function initialize()
	Entity():addScriptOnce("data/scripts/entity/antismuggle.lua")
	terminate()
end
end











