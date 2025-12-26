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

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Divulgate/BDTestCheat/'..readfile('BDTestCheat/profiles/commit.txt')..'/'..select(1, path:gsub('BDTestCheat/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local vape = shared.vape
vape.Libraries.bridgeduel = require(downloadFile('BDTestCheat/libraries/bridgeduel.lua'))
local bridgeduel = vape.Libraries.bridgeduel
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

for _, v in { "Speed", "Killaura" } do
	vape:Remove(v)
end

run(function()
	local Speed, SpeedSlider, newindex
	local char = lplr.Character or lplr.CharacterAdded:Wait()

	Speed = vape.Categories.Blatant:CreateModule({
		Name = "Speed",
		Function = function(callback) end,
		Tooltip = "Increases your movement.",
	})
	SpeedSlider = Speed:CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 26, -- check decimals later
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
    local Crit, Killaura, SwitchTool, AutoBlock
    local ForceBlocked, ForceSwitched = false, nil

    Crit = vape.Categories.Blatant:CreateModule({
        Name = "Crit",
        Function = function(callback) end,
        Tooltip = "Always land critical hits.",
    })

	local function TryAttackTarget(targetCharacter) -- literally taken from SwordClient and changed
		if not targetCharacter then
			return false
		end
		local targetEntity = bridgeduel.EntityModule.FindByCharacter(targetCharacter)
		if not targetEntity then
			return false
		end
		bridgeduel.BlinkClient.item_action.attack_entity.fire({
			["target_entity_id"] = targetEntity.Id,
			["is_crit"] = Crit.Enabled or lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0,
			["weapon_name"] = "WoodenSword",
			["extra"] = {
				["rizz"] = "Bro.",
				["owo"] = "What's this? OwO",
				["those"] = workspace.Name == "Ok",
			},
		})
		bridgeduel.ToolService:AttackPlayerWithSword(
			targetCharacter,
			Crit.Enabled or lplr.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0, -- crit
			"WoodenSword",
			"\226\128\139"
		)
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
                    if ForceBlocked then
                        ForceBlocked = false
					    bridgeduel.EntityModule.LocalEntity.IsBlocking = false
					    lplr:SetAttribute("ClientBlocking", false)
					    bridgeduel.ToolService:ToggleBlockSword(false, "WoodenSword")
                    end
                    if SwitchTool.Enabled and nearestDistance <= bridgeduel.EntityModule.LocalEntity.Reach + 4.67 then
                        ForceSwitched = lplr.Character and lplr.Character:FindFirstChildOfClass("Tool") or nil
                        if ForceSwitched and ForceSwitched.Name ~= "WoodenSword" then
                            local tool
                            for _, _tool in pairs(lplr.Backpack:GetChildren()) do
                                if _tool:IsA("Tool") and _tool.Name == "WoodenSword" then
                                    tool = _tool
                                end
                            end
                            if tool then
                                lplr.Character.Humanoid:EquipTool(tool)
                            else
                                ForceSwitched = nil
                            end
                        elseif ForceSwitched and ForceSwitched.Name == "WoodenSword" then
                            ForceSwitched = nil
                        end
                    end
					task.wait(0.01)
					TryAttackTarget(nearestPlayer)
					task.wait(0.01)
					if AutoBlock and nearestDistance <= bridgeduel.EntityModule.LocalEntity.Reach + 4.1 then
                        ForceBlocked = true
						bridgeduel.EntityModule.LocalEntity.IsBlocking = true
						lplr:SetAttribute("ClientBlocking", true)
						bridgeduel.ToolService:ToggleBlockSword(true, "WoodenSword")
					end
                    if ForceSwitched then
                        lplr.Character.Humanoid:EquipTool(ForceSwitched)
                        ForceSwitched = nil
                    end
                    if nearestDistance <= bridgeduel.EntityModule.LocalEntity.Reach + 4.67 then
                        task.wait(bridgeduel.MeleeConstants.COOLDOWN)
                    end
				end)
			until not Killaura.Enabled
		end,
		Tooltip = "Aura of killing >:)"
	})

    SwitchTool = Killaura:CreateToggle({
        Name = "Switch Tool",
        Default = true,
        Tooltip = "Switches to your sword when attacking.",
    })

    AutoBlock = Killaura:CreateToggle({
        Name = "Auto Block",
        Default = true,
        Tooltip = "Automatically blocks when close to players, and unblocks when not.",
    })
end)
