local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

local Roact = require(ReplicatedStorage.Lib.Roact)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)
local AssetFinder = require(ReplicatedStorage.AssetFinder)
local PetViewport = Roact.PureComponent:extend("PetViewport")

function PetViewport:render()
    local data = self.props.Data
    local viewportContainer =
        Roact.createElement(
        "Frame",
        {
            BackgroundTransparency = 1
        }
    )
    if data then
        viewportContainer =
            Roact.createElement(
            ViewportContainer,
            {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(.5, 0, .3, 0),
                AnchorPoint = Vector2.new(.5, .5),
                RenderedModel = AssetFinder.FindPet(data.PetClass),
                CameraCFrame = CFrame.new(0, 0, 6)
            },
            {
                UIAspectRatioConstraint = Roact.createElement(
                    "UIAspectRatioConstraint",
                    {
                        AspectRatio = 1,
                        AspectType = Enum.AspectType.ScaleWithParentSize,
                        DominantAxis = Enum.DominantAxis.Width
                    }
                )
            }
        )
    end
    return Roact.createElement(
        "Frame",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        },
        {
            Viewport = viewportContainer,
            Button =  Roact.createElement(
                "TextButton",
                {
                    Text = (data and ((data.Selected and " SELECTED ") or " SELECT ")) or "",
                    Size = UDim2.new(.92, 0, .2, 0),
                    AnchorPoint = Vector2.new(.5, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(.5, 0, .98, 0),
                    TextColor3 = Color3.new(1, 1, 1),
                    TextStrokeColor3 = Color3.new(1, 1, 1),
                    TextStrokeTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                    TextScaled = true,
                    [Roact.Event.MouseButton1Down] = function(ref)
                        if data then
                            local petServiceNetworkChannel = Services.ClientPlayerData:GetServerNetworkChannel("PetService")
                            petServiceNetworkChannel:Publish((data.Selected and "UNSELECT_PET") or "SELECT_PET", data.Id)
                        end
                    end
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.2, 0)
                        }
                    ),
                }
            )
        }
    )
end

return PetViewport
