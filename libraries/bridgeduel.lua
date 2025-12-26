local replicatedStorage = game:GetService('ReplicatedStorage')
local lplr = game:GetService("Players").LocalPlayer
local BridgeDuel = {
    BlinkClient = require(replicatedStorage.Blink.Client),
    EntityModule = require(replicatedStorage.Modules.Entity),
    SettingsController = require(replicatedStorage.Client.Controllers.All.SettingsController), -- not currently used but oh well
    ToolService = require(replicatedStorage.Services.ToolService),
    MeleeConstants = require(replicatedStorage.Constants.Melee)
}

function BridgeDuel:TryAttackTarget(targetCharacter, forceCrit) -- literally taken from SwordClient and changed
		if not targetCharacter then
			return false
		end
		local targetEntity = BridgeDuel.EntityModule.FindByCharacter(targetCharacter)
		if not targetEntity then
			return false
		end
		BridgeDuel.BlinkClient.item_action.attack_entity.fire({
			["target_entity_id"] = targetEntity.Id,
			["is_crit"] = forceCrit or lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0,
			["weapon_name"] = "WoodenSword",
			["extra"] = {
				["rizz"] = "Bro.",
				["owo"] = "What's this? OwO",
				["those"] = workspace.Name == "Ok",
			},
		})
		BridgeDuel.ToolService:AttackPlayerWithSword(
			targetCharacter,
			forceCrit or lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0, -- crit
			"WoodenSword",
			"\226\128\139"
		)
		return true
	end

return BridgeDuel