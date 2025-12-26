local replicatedStorage = game:GetService('ReplicatedStorage')
local BridgeDuel = {
    BlinkClient = require(replicatedStorage.Blink.Client),
    EntityModule = require(replicatedStorage.Modules.Entity),
    SettingsController = require(replicatedStorage.Client.Controllers.All.SettingsController), -- not currently used but oh well
    ToolService = require(replicatedStorage.Services.ToolService),
    MeleeConstants = require(replicatedStorage.Constants.Melee)
}

return BridgeDuel