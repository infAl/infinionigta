-------------------------------------------------------------------------------
--	This script is for admins to do adminish stuff with.
--	Select from a list of online players and give them a cargo shield module or
--	a dangerous goods permit.
--	Doing stuff like this helps server admins to test and use the mod.
-------------------------------------------------------------------------------

-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
require ("infinionigta/config")

if not disableMod then

package.path = package.path .. ";data/scripts/lib/?.lua"
require ("utility")
require ("goods")
require ("randomext")


-- Local variables
local window = nil
local playerListBox
local cargoShieldRarity
local cargoShieldQty
local dangerousGoodsPermitQty

function getIcon(seed, rarity)
    return adminIcon
end

function interactionPossible(player)
    return true, ""
end

function initUI()

    local res = getResolution()
    local size = vec2(800, 650)

    local menu = ScriptUI()
    window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

    window.caption = modName .. " " .. adminUI
    window.showCloseButton = 1
    window.moveable = 1
    menu:registerWindow(window, modName .. " " .. adminUI);
	
	local pos = Rect(10, 40, 260, size.y-10)
	playerListBox = window:createListBox(pos)
	local playerListLabel = window:createLabel(vec2(10, 10), playersOnline, 14)
	
	local cargoShieldLabel = window:createLabel(vec2(290, 40), cargoShield, 16)
	cargoShieldRarity = window:createComboBox(Rect(300, 80, 450, 110), "dummy")
	cargoShieldRarity:addEntry("Common")
	cargoShieldRarity:addEntry("Uncommon")
	cargoShieldRarity:addEntry("Rare")
	cargoShieldRarity:addEntry("Exceptional")
	cargoShieldRarity:addEntry("Exotic")
	cargoShieldRarity:addEntry("Legendary")
	local cargoShieldQtyLabel = window:createLabel(vec2(460, 85), "Qty:", 14)
	cargoShieldQty = window:createTextBox(Rect(500, 80, 550, 110), "dummy")
	local cargoShieldButton = window:createButton(Rect(560, 80, 710, 110), "Give", "onGiveCargoShield")
	
	local dangerousGoodsPermitLabel = window:createLabel(vec2(290, 170), goodsPermit, 16)
	local dangerousGoodsPermitMinutesLabel = window:createLabel(vec2(300, 215), minutes, 14)
	dangerousGoodsPermitQty = window:createTextBox(Rect(380, 210, 430, 240), "dummy")
	local dangerousGoodsPermitButton = window:createButton(Rect(440, 210, 590, 240), "Give", "onGiveDangerousGoodsPermit")
	
	local foot = string.format("%s v%i.%i.%i", modName, modVersion.major, modVersion.minor, modVersion.revision)
	window:createLabel(vec2(size.x-400, size.y-20), foot, 12)
end

function onShowWindow()
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

function setOnlinePlayerList(playerList)
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
		local item = SystemUpgradeTemplate(scriptCargoShield, Rarity(rarity), random():createSeed())
		
		for i=1, quantity do
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
		
		if not player:hasScript(scriptGoodsPermit) then
			player:addScriptOnce(scriptGoodsPermit)
		end
		player:invokeFunction(scriptGoodsPermit, "addTime", minutes)
	end
end

-- This is to prevent errors with UI elements that require a function when something
-- is selected/changed etc but that function isn't being used by this script.
function dummy() end

else 
	-- disableMod is true
function initialize() terminate() end
end













