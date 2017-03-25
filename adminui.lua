--[[---------------------------------------------------------------------------
	
	This script is a plugin module for the ModLoader Admin UI.

	Select from a list of online players and give them a cargo shield module or
	a dangerous goods permit.

--]]---------------------------------------------------------------------------

-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
local Config = require ("infinionigta/config")

package.path = package.path .. ";data/scripts/lib/?.lua"
require ("utility")
require ("goods")
require ("randomext")


-- Local variables
local t = {}
local container
local playerListBox
local cargoShieldRarity
local cargoShieldQty
local dangerousGoodsPermitQty

function getIcon(seed, rarity)
    return Config.adminIcon
end

function interactionPossible(player)
    return true, ""
end

t.initUI = function(parent)

	container = parent

    local size = container.size
	
	local pos = Rect(10, 40, 260, size.y)
	playerListBox = container:createListBox(pos)
	local playerListLabel = container:createLabel(vec2(10, 10), Config.playersOnline, 14)
	
	local cargoShieldLabel = container:createLabel(vec2(290, 40), Config.cargoShield, 16)
	cargoShieldRarity = container:createComboBox(Rect(300, 80, 450, 110), "dummy")
	cargoShieldRarity:addEntry("Common")
	cargoShieldRarity:addEntry("Uncommon")
	cargoShieldRarity:addEntry("Rare")
	cargoShieldRarity:addEntry("Exceptional")
	cargoShieldRarity:addEntry("Exotic")
	cargoShieldRarity:addEntry("Legendary")
	local cargoShieldQtyLabel = container:createLabel(vec2(460, 85), "Qty:", 14)
	cargoShieldQty = container:createTextBox(Rect(500, 80, 550, 110), "dummy")
	local cargoShieldButton = container:createButton(Rect(560, 80, 710, 110), "Give", "onGiveCargoShield")
	
	local dangerousGoodsPermitLabel = container:createLabel(vec2(290, 170), Config.goodsPermit, 16)
	local dangerousGoodsPermitMinutesLabel = container:createLabel(vec2(300, 215), Config.minutes, 14)
	dangerousGoodsPermitQty = container:createTextBox(Rect(380, 210, 430, 240), "dummy")
	local dangerousGoodsPermitButton = container:createButton(Rect(440, 210, 590, 240), "Give", "onGiveDangerousGoodsPermit")
	
	--local foot = string.format("%s v%i.%i.%i", Config.modName, Config.modVersion.major, Config.modVersion.minor, Config.modVersion.revision)
	--container:createLabel(vec2(size.x-100, size.y-10), foot, 12)
end

t.onShowWindow = function()
    if onClient() then
		invokeServerFunction("getOnlinePlayerList")
	end
end

function getOnlinePlayerList()
	if onServer() then
		local playerNames = {Galaxy():getOnlinePlayerNames()}
		invokeClientFunction(Player(callingPlayer), "setOnlinePlayerList", playerNames)
	end
end

function setOnlinePlayerList (playerList)
	if onClient and playerList then
		playerListBox:clear()
		for _, playerName in pairs(playerList) do
			playerListBox:addEntry(playerName)
		end
	end
end

function onGiveCargoShield()
	if onClient() then
		local playerName = playerListBox:getSelectedEntry()
		if playerName == nil then return end
		local rarityValue = cargoShieldRarity.selectedIndex
		local quantity = tonumber(cargoShieldQty.text) or 1
		invokeServerFunction("giveCargoShield", playerName, rarityValue, quantity)
		return
	end
end

function giveCargoShield(playerName, rarity, quantity)
	if onServer() then
		local playerList = {Server():getOnlinePlayers()}
		local player = nil
		for _, p in pairs(playerList) do
			if p.name == playerName then
				player = p
				break
			end
		end
		if player == nil then return end
		
		for i=1, quantity do
			local item = SystemUpgradeTemplate(Config.scriptCargoShield, Rarity(rarity), random():createSeed())
			player:getInventory():add(item)
		end
	end
end

function onGiveDangerousGoodsPermit()
	if onClient() then
		local playerName = playerListBox:getSelectedEntry()
		if playerName == nil then return end
		local minutes = tonumber(dangerousGoodsPermitQty.text) or 5
		invokeServerFunction("giveDangerousGoodsPermit", playerName, minutes)
		return
	end
end

function giveDangerousGoodsPermit(playerName, minutes)
	if onServer() then
		local playerList = {Server():getOnlinePlayers()}
		local player = nil
		for _, p in pairs(playerList) do
			if p.name == playerName then
				player = p
				break
			end
		end
		if player == nil then return end
		
		if not player:hasScript(Config.scriptGoodsPermit) then
			player:addScriptOnce(Config.scriptGoodsPermit)
		end
		player:invokeFunction(Config.scriptGoodsPermit, "addTime", minutes)
	end
end

-- This is to prevent errors with UI elements that require a function when something
-- is selected/changed etc but that function isn't being used by this script.
function dummy() end

return t













