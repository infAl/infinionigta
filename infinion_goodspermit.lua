-- Include Files
package.path = package.path .. ";data/scripts/mods/?.lua"
local Config = require ("infinionigta/config")

if not Config.disableMod then

package.path = package.path .. ";data/scripts/lib/?.lua"
Dialog = require ("dialogutility")
require("randomext")


-- Local Variables
local buyPermitOptions =
{
	{
		answer = Config.dialogChangedMind,
		onSelect = "reset"
	},
	{
		answer = Config.dialogBuy5,
		onSelect = "buy5"
	},
	{
		answer = Config.dialogBuy15,
		onSelect = "buy15"
	},
	{
		answer = Config.dialogBuy30,
		onSelect = "buy30"
	},
	{
		answer = Config.dialogBuy60,
		onSelect = "buy60"
	}
}

function interactionPossible(player)
    return true
end

function initialize()
    -- The greeting text
	InteractionText(Entity().index).text = Config.dialogGreeting
end

function initUI()
    ScriptUI():registerInteraction(Config.dialogWantPermit, "onInteract")
end

function onInteract()
	if onClient() then
		ScriptUI():showDialog(normalDialog(), 0)
		return
	end
end

function normalDialog()
    local dialog =
    {
        text = Config.dialogOfferPermits,
        answers = buyPermitOptions
    }
    return dialog
end

function dialog2()
    local dialog =
    {
        text = Config.dialogOfferDifferentPermit,
        answers = buyPermitOptions
    }
    ScriptUI():showDialog(dialog, 0)
end

function reset()
	ScriptUI():restartInteraction()
end


function buy5() buyMinutes(5, 10000) end
function buy15() buyMinutes(15, 20000) end
function buy30() buyMinutes(30, 30000) end
function buy60() buyMinutes(60, 50000) end

function buyMinutes(minutes, fee)
	if onClient() then
		local player = Player()
		if not player:canPay(fee) then
		
			local dialog =	{
						text = Config.dialogTooPoor,
						answers = {{ answer = "Oh...."%_t, onSelect="dialog2"}}
					}
			ScriptUI():showDialog(dialog, 0)
			return
		end
		invokeServerFunction("buyMinutes", minutes, fee)
		return
	end

	local player = Player(callingPlayer)
	
	player:pay(fee)
	
	if not player:hasScript(Config.scriptGoodsPermit) then
		player:addScriptOnce(Config.scriptGoodsPermit)
	end
	player:invokeFunction(Config.scriptGoodsPermit, "addTime", minutes)
end


else 
	-- disableMod is true
function initialize() terminate() end
end









