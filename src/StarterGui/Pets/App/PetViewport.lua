local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

local Roact = require(ReplicatedStorage.Lib.Roact)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)
local AssetFinder = require(ReplicatedStorage.AssetFinder)
local PetPopup = require(script.Parent:WaitForChild("PetPopup"))
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local PetViewport = Roact.PureComponent:extend("PetViewport")

local PET_MULTIPLIERS = {
    {
        Name = "Gold",
        Image = "rbxassetid://5566037237"
    },
    {
        Name = "Critical",
        Image = "rbxassetid://5063940411"
    },
    {
        Name = "Speed",
        Image = "rbxassetid://3179225615"
    }
}
function PetViewport:render()
    local data = self.props.renderedPet
    local children = {}
    if data then
        local instance = AssetFinder.FindPet(data.PetClass)
        children["ViewportContainer"] =
            Roact.createElement(
            ViewportContainer,
            {
                Size = UDim2.new(1, 0, .4, 0),
                Position = UDim2.new(.5, 0, 0, 0),
                AnchorPoint = Vector2.new(.5, 0),
                RenderedModel = instance,
                CameraCFrame = CFrame.new(0, 0, 1)
            },
            {
                PetName = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = data.PetClass,
                        TextScaled = true,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextStrokeTransparency = 1,
                        Size = UDim2.new(1, 0, .2, 0),
                        Position = UDim2.new(.5, 0, 0, 0),
                        AnchorPoint = Vector2.new(.5, 0),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                        ZIndex = 1
                    }
                ),
                SelectText = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = data.Selected and "SELECTED" or "",
                        TextScaled = true,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(85, 109, 248),
                        TextStrokeTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(.5, .5),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                        ZIndex = 100,
                        Rotation = -20
                    }
                )
            }
        )
        children["Button"] =
            Roact.createElement(
            "TextButton",
            {
                Text = data and ((data.Selected and " UNEQUIP ") or " EQUIP "),
                Size = UDim2.new(.9, 0, .1, 0),
                AnchorPoint = Vector2.new(.5, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(.5, 0, .85, 0),
                TextColor3 = Color3.new(1, 1, 1),
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                TextStrokeTransparency = 0,
                Font = Enum.Font.GothamBold,
                BackgroundColor3 = Color3.fromRGB(67, 161, 4),
                TextScaled = true,
                [Roact.Event.MouseButton1Down] = data and function()
                        local petServiceNetworkChannel = Services.ClientPlayerData:GetServerNetworkChannel("PetService")
                        petServiceNetworkChannel:Publish((data.Selected and "UNSELECT_PET") or "SELECT_PET", data.Id)
                    end or nil
            },
            {
                UICorner = Roact.createElement(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(.2, 0)
                    }
                )
            }
        )
        children["Delete"] =
            Roact.createElement(
            "TextButton",
            {
                Text = "DELETE",
                Size = UDim2.new(.9, 0, .1, 0),
                AnchorPoint = Vector2.new(.5, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(.5, 0, .98, 0),
                TextColor3 = Color3.new(1, 1, 1),
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                TextStrokeTransparency = 0,
                Font = Enum.Font.GothamBold,
                BackgroundColor3 = Color3.fromRGB(160, 7, 7),
                TextScaled = true,
                [Roact.Event.MouseButton1Down] = data and
                    function()
                        local popup =
                            Roact.createElement(
                            PetPopup,
                            {},
                            {
                                Text = Roact.createElement(
                                    ShadowedText,
                                    {
                                        Font = Enum.Font.GothamBold,
                                        Text = string.format("Are you sure you want to delete %s?", data.PetClass),
                                        TextScaled = true,
                                        BackgroundTransparency = 1,
                                        TextColor3 = Color3.new(1, 1, 1),
                                        TextStrokeTransparency = 1,
                                        Size = UDim2.new(1, 0, .5, 0),
                                        Position = UDim2.new(.5, 0, 0, 0),
                                        AnchorPoint = Vector2.new(.5, 0),
                                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                                        ZIndex = 1000
                                    }
                                ),
                                YesButton = Roact.createElement(
                                    "TextButton",
                                    {
                                        Font = Enum.Font.GothamBold,
                                        Text = "YES",
                                        TextScaled = true,
                                        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
                                        BorderSizePixel = 0,
                                        TextColor3 = Color3.new(1, 1, 1),
                                        TextStrokeTransparency = 1,
                                        Size = UDim2.new(.3, 0, .3, 0),
                                        Position = UDim2.new(0.1, 0, .6, 0),
                                        AnchorPoint = Vector2.new(0, 0),
                                        ZIndex = 1001,
                                        [Roact.Event.MouseButton1Down] = function(ref)
                                            self.props.makePopup(Roact.None)
                                            self.props.setRenderedPet(Roact.None)
                                            local petServiceNetworkChannel = Services.ClientPlayerData:GetServerNetworkChannel("PetService")
                                            petServiceNetworkChannel:Publish("DELETE_PET", data.Id)
                                        end
                                    },
                                    {
                                        UICorner = Roact.createElement(
                                            "UICorner",
                                            {
                                                CornerRadius = UDim.new(.2, 0)
                                            }
                                        )
                                    }
                                ),
                                NoButton = Roact.createElement(
                                    "TextButton",
                                    {
                                        Font = Enum.Font.GothamBold,
                                        Text = "NO",
                                        TextScaled = true,
                                        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                                        BorderSizePixel = 0,
                                        TextColor3 = Color3.new(1, 1, 1),
                                        TextStrokeTransparency = 1,
                                        Size = UDim2.new(.3, 0, .3, 0),
                                        Position = UDim2.new(.6, 0, .6, 0),
                                        AnchorPoint = Vector2.new(0, 0),
                                        ZIndex = 1001,
                                        [Roact.Event.MouseButton1Down] = function(ref)
                                            self.props.makePopup(Roact.None)
                                        end
                                    },
                                    {
                                        UICorner = Roact.createElement(
                                            "UICorner",
                                            {
                                                CornerRadius = UDim.new(.2, 0)
                                            }
                                        )
                                    }
                                )
                            }
                        )
                        self.props.makePopup(popup)
                    end or
                    nil
            },
            {
                UICorner = Roact.createElement(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(.2, 0)
                    }
                )
            }
        )

        -- #TODO: Make this not messy xd
        local petMultipliers = {}
        for _, v in pairs(PET_MULTIPLIERS) do
            local mult = instance:FindFirstChild(v.Name .. "Multiplier")
            if mult and mult.Value ~= 1 then
                petMultipliers[#petMultipliers + 1] =
                    Roact.createElement(
                    IconFrame,
                    {
                        ZIndex = 1000,
                        Image = v.Image,
                    },
                    {
                        GoldMultiplier = Roact.createElement(
                            ShadowedText,
                            {
                                Font = Enum.Font.GothamBold,
                                Text = string.format("%.3fx", mult.Value),
                                TextScaled = true,
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                TextStrokeTransparency = 1,
                                Size = UDim2.new(1, 0, 1, 0),
                                Position = UDim2.new(0, 0, 0, 0),
                                ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                                ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                                ZIndex = 100
                            }
                        )
                    }
                )
            end
        end
        petMultipliers = Roact.createFragment(petMultipliers)
        children["Multipliers"] =
            Roact.createElement(
            "ScrollingFrame",
            {
                Size = UDim2.new(1, 0, .25, 0),
                Position = UDim2.new(.5, 0, .45, 0),
                AnchorPoint = Vector2.new(.5, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.new(0, 0, 1, 0)
            },
            {
                UIGridLayout = Roact.createElement(
                    "UIGridLayout",
                    {
                        CellSize = UDim2.new(.8, 0, .1, 0),
                        CellPadding = UDim2.new(0, 0, 0, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left
                    }
                ),
                petMultipliers
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
        children
    )
end

return PetViewport
