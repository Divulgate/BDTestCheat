local run = function(func)
	task.spawn(func)
end
local cloneref = cloneref or function(obj)
	return obj
end
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end,
})

local playersService = cloneref(game:GetService("Players"))
local replicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local runService = cloneref(game:GetService("RunService"))
local inputService = cloneref(game:GetService("UserInputService"))
local tweenService = cloneref(game:GetService("TweenService"))
local httpService = cloneref(game:GetService("HttpService"))
local textChatService = cloneref(game:GetService("TextChatService"))
local collectionService = cloneref(game:GetService("CollectionService"))
local contextActionService = cloneref(game:GetService("ContextActionService"))
local guiService = cloneref(game:GetService("GuiService"))
local coreGui = cloneref(game:GetService("CoreGui"))
local starterGui = cloneref(game:GetService("StarterGui"))

local isnetworkowner = identifyexecutor
		and table.find({ "AWP", "Nihon", "Hydrogen" }, ({ identifyexecutor() })[1])
		and isnetworkowner
	or function()
		return true
	end
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local function isFriend(plr, recolor)
	if vape.Categories.Friends.Options["Use friends"].Enabled then
		local friend = table.find(vape.Categories.Friends.ListEnabled, plr.Name) and true
		if recolor then
			friend = friend and vape.Categories.Friends.Options["Recolor visuals"].Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true
end

local function notif(...)
	return vape:CreateNotification(...)
end

local function removeTags(str)
	str = str:gsub("<br%s*/>", "\n")
	return (str:gsub("<[^<>]->", ""))
end

local function switchItem(tool, delayTime)
	delayTime = delayTime or 0.05
	local check = lplr.Character and lplr.Character:FindFirstChild("HandInvItem") or nil
	if check and check.Value ~= tool and tool.Parent ~= nil then
		task.spawn(function()
			bedwars.Client:Get(remotes.EquipItem):CallServerAsync({ hand = tool })
		end)
		check.Value = tool
		if delayTime > 0 then
			task.wait(delayTime)
		end
		return true
	end
end

for _, v in { "Speed", "Killaura" } do
	vape:Remove(v)
end

run(function()
	local Speed, SpeedSlider, index, newindex
	local char = lplr.Character or lplr.CharacterAdded:Wait()

	Speed = vape.Categories.Blatant:CreateModule({
		Name = "Speed",
		Function = function(callback) end,
		Tooltip = "Increases your movement.",
	})
	SpeedSlider = Speed:CreateSlider({
		Name = "Charge Time",
		Min = 1,
		Max = 150,
		Default = 26,
		Decimal = 10,
	})
	newindex = hookmetamethod(game, "__newindex", function(self, key, value)
		if
			not checkcaller()
			and typeof(self) == "Instance"
			and self:IsA("Humanoid")
			and type(key) == "string"
			and (key:lower() == "walkspeed")
			and self:IsDescendantOf(char)
			and Speed.Enabled
		then
			return newindex(self, key, SpeedSlider.Value)
		end
		return newindex(self, key, value)
	end)
	repeat
		task.wait()
		if not char or not char.Parent then
			char = lplr.Character or lplr.CharacterAdded:Wait()
		end
	until false
end)

run(function()
	-- TEMP --
	local BlinkClient = require(replicatedStorage.Blink.Client)
	local EntityModule = require(replicatedStorage.Modules.Entity)
	local SettingsController = require(replicatedStorage.Client.Controllers.All.SettingsController)
	local ToolService = require(replicatedStorage.Services.ToolService)
	-- TEMP --

    local Crit, Killaura

    Crit = vape.Categories.Blatant:CreateModule({
        Name = "Crit",
        Function = function(callback) end,
        Tooltip = "Always land critical hits.",
    })

	local function TryAttackTarget(targetCharacter) -- literally decomped from SwordClient and minorly changed
		if not targetCharacter then
			return false
		end
		local targetEntity = EntityModule.FindByCharacter(targetCharacter)
		if not targetEntity then
			return false
		end
		local attackEvent = BlinkClient.item_action.attack_entity.fire
		local attackData = {
			["target_entity_id"] = targetEntity.Id,
			["is_crit"] = Crit.Enabled or lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0,
			["weapon_name"] = "WoodenSword",
			["extra"] = {
				["rizz"] = "Bro.",
				["owo"] = "What's this? OwO",
				["those"] = workspace.Name == "Ok",
			},
		}
		attackEvent(attackData)
		ToolService:AttackPlayerWithSword(
			targetCharacter,
			Crit.Enabled or lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0, -- crit
			"WoodenSword",
			"\226\128\139"
		)
		local crosshair = SettingsController.Settings.DebugMode and lplr.PlayerGui.MainGui:FindFirstChild("Crosshair")
		if crosshair then
			local tween = tweenService:Create(crosshair, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				["ImageColor3"] = Color3.fromRGB(206, 0, 0),
			})
			tween:Play()
			tween.Completed:Connect(function()
				tweenService
					:Create(crosshair, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						["ImageColor3"] = Color3.fromRGB(255, 255, 255),
					})
					:Play()
			end)
		end
		return true
	end

	Killaura = vape.Categories.Blatant:CreateModule({
		Name = "Killaura",
		Function = function(callback)
			if not callback then
				return
			end
			repeat
				task.wait()
				pcall(function()
					local nearestPlayer, nearestDistance
					for _, player in pairs(playersService:GetPlayers()) do
						local character = player.Character
						if not character or player == lplr then
							continue
						end
						local distance = lplr:DistanceFromCharacter(character.PrimaryPart.CFrame.Position)
						if nearestDistance and distance >= nearestDistance then
							continue
						end
						nearestDistance = distance
						nearestPlayer = character
					end
					EntityModule.LocalEntity.IsBlocking = false
					lplr:SetAttribute("ClientBlocking", false)
					ToolService:ToggleBlockSword(false, "WoodenSword")
					task.wait(0.01)
					TryAttackTarget(nearestPlayer)
					if nearestPlayer then
						EntityModule.LocalEntity.IsBlocking = true
						lplr:SetAttribute("ClientBlocking", true)
						ToolService:ToggleBlockSword(true, "WoodenSword")
					end
				end)
			until not Killaura.Enabled
		end,
		Tooltip = "Aura of killing >:)",
	})
end)
