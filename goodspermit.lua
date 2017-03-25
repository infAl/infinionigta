-------------------------------------------------------------------------------
--	
--	This script attaches to the player when they have purchased a dangerous
-- 	goods transportation permit.
--	The script itself actually doesn't do anything, it just counts down the
--	time remaining and then terminates.
--	Other scripts will check for it's presence and if the player has the script
--	then they have a permit for dangerous goods.
--
-------------------------------------------------------------------------------


-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
local Config = require ("infinionigta/config")

if not Config.disableMod then


-- Local Variables
local permitTime = 0
local onFirstUpdate = false



-- Avorion default functions
function updateServer(timestep)
	permitTime = permitTime - timestep
		
	local minutes, seconds = getMinutesSeconds(permitTime)
	local player = Player()
	
	-- Let the player know when they log in how long until their permit expires
	if not onFirstUpdate then
		player:sendChatMessage(Config.goodsPermit, 3, Config.infoTimeRemainingMS, minutes, seconds)
		onFirstUpdate = true
	end
	
	if permitTime < 0 then
		player:sendChatMessage(Config.goodsPermit, 3, Config.infoTimeExpired)
		terminate()
	elseif minutes % Config.updateIntervalMinutes == 0 and seconds <= 9 then
		player:sendChatMessage(Config.goodsPermit, 3, Config.infoTimeRemainingM, minutes)
	elseif minutes == 2 and seconds <= 9 then
		player:sendChatMessage(Config.goodsPermit, 3, Config.infoTimeRemainingM, minutes)
	elseif minutes == 1 and seconds <= 9 then
		player:sendChatMessage(Config.goodsPermit, 3, Config.infoTimeRemainingM, minutes)
	end
end

function getUpdateInterval()
    return 10
end

function secure()
	-- Save how much time they have remaining so that we can get the value
	-- next time they log in
	return {permitTime = permitTime}
end

function restore(data)
	-- Restore the time remaining from the last time they played
	if data then
		permitTime = data.permitTime
	end
end


-- Helper Functions
function getMinutesSeconds(seconds)
	local minutes = math.floor(permitTime / 60)
	local seconds = math.ceil(permitTime % 60)
	if seconds == 60 then
		minutes = minutes + 1
		seconds = 0
	end
	return minutes, seconds
end


-- API Functions

-- Lets other scripts/mods add minutes to the time remaining
-- @param minutes The number of minutes to add to the permit time
-- @return Does not return a value
function addTime(minutes)
	if minutes > 0 then
		permitTime = permitTime + minutes * 60
	end
	local player = Player(callingPlayer)

	local minutes, seconds = getMinutesSeconds(permitTime)
	player:sendChatMessage("Goods Permit", 3, Config.infoTimeRemainingMS, minutes, seconds)
	onFirstUpdate = true
end

-- Lets other scripts/mods read how much time is remaining for the permit
-- @return Permit time remaining in seconds
function permitTimeRemaining()

	return permitTime
end

else 
	-- disableMod is true
function initialize() terminate() end
end















