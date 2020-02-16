--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {
    "AssetManager",
    "EffectsService",
    "SoundService",
    "GuiService",
    "PlayerSettingsService",
    "LightingService",
    "PlayerManager",
    "TeamManager",
    "CameraService"
}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

-------------------
--= LocalPlayer =--
-------------------
-- Stores a reference to the localplayer PlayerObject, and connects all necessary connections

local Maid = require("Maid").new()
local Services = _G.Services

local datadump = require("DataDump")
local NetworkChannel = require("NetworkChannel")
local PlayerManager = Services.PlayerManager
local LocalPlayer = nil

local event = nil
local PlayerNetworkChannel = nil
function Service:Load()
    LocalPlayer = PlayerManager:GetPlayerByReference(game.Players.LocalPlayer)
    assert(LocalPlayer, "Fatal error: Failed to get localplayer object!")
    -- Expose local player to rest of client --
    _G.LocalPlayer = LocalPlayer
    event = game.ReplicatedStorage.Remote:WaitForChild("PlayerEvent")

    PlayerNetworkChannel = NetworkChannel:New("Player", event)

    Maid:GiveTask(PlayerNetworkChannel)

    -- Bind network connections
    Maid:GiveTask(
        PlayerNetworkChannel:Subscribe(
            "CharacterAdded",
            function(char)
                local chan = self:GetChannel()
                chan:Publish("CharacterAdded", game.Players.LocalPlayer.Character)
            end
        )
    )

    Maid:GiveTask(
        PlayerNetworkChannel:Subscribe(
            "ZoneChanged",
            function(zone_id)
                local chan = self:GetChannel()
                chan:Publish("ZoneChanged", Services.ZoneManager:GetZoneById(zone_id))
            end
        )
    )
    Maid:GiveTask(
        PlayerNetworkChannel:Subscribe(
            "GiveItems",
            function(items)
                for category, itemlist in pairs(items) do
                    for itemname, amount in pairs(itemlist) do
                        _G.Services.SoundService:PlaySound("ItemPickup")
                        local newGui = _G.Services.GuiService:GetGui("ItemPickup")
                        game.Debris:AddItem(newGui,10)
                        newGui.Enabled = true
                        _G.Services.GuiService:SetViewportModel(newGui.Object.Thumbnail.ViewportFrame, _G.Services.AssetManager:GetAssetViewport(category, itemname))
                        newGui.Object.Top.Text = itemname
                        newGui.Object.Bottom.Text = tostring(amount)
                        newGui.Parent = game.Players.LocalPlayer.PlayerGui
                        spawn(function()
                            newGui.Object:TweenPosition(UDim2.new(.5,0,.2,0), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce)
                            wait(3)
                            newGui.Object:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0, 10,.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad)
                        end)
                        wait(.1)
                    end
                end
                
            end
        )
    )
    while not (game.Players.LocalPlayer.Character) do
        PlayerNetworkChannel:Publish("RequestCharacter")
        wait(1)
    end

end

function Service:Unload()
    LocalPlayer = nil
    _G.LocalPlayer = nil
    Maid:Destroy()
    event:Destroy()
    event = nil
end

local MAX_RAY_DIST = 1000
-- Returns a unit ray from character's primary part to the mouse's hit (or an arbitrary point very far away if no hit)
function Service:GetLookvectorFromCharacter()
    local mouse = LocalPlayer:GetReference():GetMouse()
    local mouse_ray = mouse.UnitRay
    local mouse_origin = mouse_ray.Origin
    local mouse_direction = mouse_ray.Direction

    local part, pos =
        workspace:FindPartOnRayWithIgnoreList(
        Ray.new(mouse_origin, mouse_direction * MAX_RAY_DIST),
        {LocalPlayer:GetCharacter()}
    )

    if part == nil then
        pos = mouse_direction * MAX_RAY_DIST + mouse_origin
    end

    local char_origin = LocalPlayer:GetPosition()
    local char_direction = pos - char_origin

    local ray = Ray.new(char_origin, char_direction).Unit
    return ray
end
return Service
