local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Services = require(ReplicatedStorage.Services)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local Roact = require(ReplicatedStorage.Lib.Roact)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)

local BackpackMenuButton = require(script.Parent.BackpackMenuButton)
local BackpackList = Roact.Component:extend("BackpackList")
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)

function BackpackList:init()
    self._maid = Maid.new()
    self:setState(
        {
            ownedBackpacks = Services.ClientPlayerData:GetStore("OwnedBackpacks"):getState(),
            selectedBackpack = Services.ClientPlayerData:GetStore("SelectedBackpack"):getState(),
            highlightedBackpack = Services.ClientPlayerData:GetStore("SelectedBackpack"):getState()
        }
    )
end

function BackpackList:didMount()
    self._maid(Services.ClientPlayerData:GetStore("OwnedBackpacks").changed:connect(
        function(new, old)
            self:setState(
                {
                    ownedBackpacks = new
                }
            )
        end
    ))
    self._maid(Services.ClientPlayerData:GetStore("SelectedBackpack").changed:connect(
        function(new, old)
            self:setState(
                {
                    selectedBackpack = new
                }
            )
        end
    ))
end

function BackpackList:willUnmount()
    self._maid:Destroy()
end

local function getBackpackInfo(backpacks, ownedBackpacks, selectedBackpack, highlightedBackpack)
    local list = {}
    for _, backpack in pairs(backpacks) do
        local name = backpack.Name
        local displayName = backpack:FindFirstChild("DisplayName").Value
        local shopOrder = backpack:FindFirstChild("ShopOrder").Value
        local goldCost = backpack:FindFirstChild("GoldCost").Value
        local capacity = backpack:FindFirstChild("Capacity").Value
        local description = backpack:FindFirstChild("Description").Value
        local selected = (name == selectedBackpack)
        local highlighted = (name == highlightedBackpack)
        local owned = (TableUtil.contains(ownedBackpacks, name))
        local buyable = goldCost ~= math.huge
        local hidden = not (buyable or owned)

        list[name] = {
            Instance = backpack,
            Name = name,
            DisplayName = displayName,
            ShopOrder = shopOrder,
            GoldCost = goldCost,
            Capacity = capacity,
            Description = description,
            Selected = selected,
            Highlighted = highlighted,
            Owned = owned,
            Buyable = buyable,
            Hidden = hidden
        }
    end
    return list
end

local GLOBAL_RAND_SHIFT = tick()
function BackpackList:render()
    local buttons = {}
    local ownedBackpacks = self.state.ownedBackpacks
    local selectedBackpack = self.state.selectedBackpack
    local highlightedBackpack = self.state.highlightedBackpack or selectedBackpack
    local highlightedBackpackData = nil
    local actionButton = nil
    for name, data in pairs(getBackpackInfo(BACKPACKS:GetChildren(), ownedBackpacks, selectedBackpack, highlightedBackpack)) do
        highlightedBackpackData = (data.Highlighted and data) or highlightedBackpackData
        if not data.Hidden then
            math.randomseed(string.byte(name) + GLOBAL_RAND_SHIFT)
            local buttonRotation = math.random(-2, 2)
            buttons[name] =
                Roact.createElement(
                BackpackMenuButton,
                {
                    IconProps = {
                        Image = "rbxassetid://5137381399",
                        ImageColor3 = (data.Highlighted and Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Rotation = buttonRotation,
                        SliceCenter = Rect.new(300, 0, 700, 0),
                        ScaleType = Enum.ScaleType.Slice
                    },
                    TextProps = {
                        Text = string.format("%s %s", ((data.Selected and "[SELECTED]") or (data.Owned and "[OWNED]") or ""), data.DisplayName),
                        TextColor3 = (data.Highlighted and Color3.fromRGB(0, 0, 0)) or Color3.fromRGB(255, 255, 255),
                        ShadowTextColor3 = (data.Highlighted and Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Position = UDim2.new(.5, 0, .5, 0),
                        AnchorPoint = Vector2.new(.5, .5),
                        Size = UDim2.new(.6, 0, 1, 0),
                        Rotation = buttonRotation
                    },
                    AspectType = Enum.AspectType.FitWithinMaxSize,
                    DominantAxis = Enum.DominantAxis.Width,
                    LayoutOrder = data.ShopOrder,
                    AspectRatio = 4,
                    Size = (data.Highlighted and UDim2.new(1.3, 0, .2, 0)) or UDim2.new(1, 0, .2, 0),
                    -- Event hooks --
                    [Roact.Event.MouseButton1Click] = function()
                        self:setState(
                            {
                                highlightedBackpack = name
                            }
                        )
                    end,
                    [Roact.Event.MouseEnter] = function(ref)
                        if data.Highlighted then
                            return
                        end
                        ref:TweenSize(UDim2.new(1.3, 0, .2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                        ref.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        ref.MainText.TextColor3 = Color3.fromRGB(0, 0, 0)
                        ref.ShadowText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end,
                    [Roact.Event.MouseLeave] = function(ref)
                        if data.Highlighted then
                            return
                        end
                        ref:TweenSize(UDim2.new(1, 0, .2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                        ref.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
                        ref.MainText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        ref.ShadowText.TextColor3 = Color3.fromRGB(0, 0, 0)
                    end
                }
            )
            if data.Highlighted then
                actionButton =
                    Roact.createElement(
                    BackpackMenuButton,
                    {
                        IconProps = {
                            Image = "rbxassetid://5137381399",
                            ImageColor3 = (data.Selected and Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(0, 0, 0),
                            Size = UDim2.new(1, 0, 1, 0),
                            SliceCenter = Rect.new(300, 0, 700, 0),
                            ScaleType = Enum.ScaleType.Slice,
                            ZIndex = 1000
                        },
                        TextProps = {
                            Text = string.format(
                                "%s",
                                (data.Selected and "SELECTED") or (data.Owned and "SELECT") or (data.Buyable and "BUY") or "NOT BUYABLE"
                            ),
                            TextColor3 = (data.Selected and Color3.fromRGB(0, 0, 0)) or Color3.fromRGB(255, 255, 255),
                            ShadowTextColor3 = (data.Selected and Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(0, 0, 0),
                            Font = Enum.Font.GothamBold,
                            Position = UDim2.new(.5, 0, .5, 0),
                            AnchorPoint = Vector2.new(.5, .5),
                            Size = UDim2.new(.6, 0, 1, 0),
                            ZIndex = 1001
                        },
                        AspectType = Enum.AspectType.FitWithinMaxSize,
                        DominantAxis = Enum.DominantAxis.Width,
                        AspectRatio = 4,
                        Size = (data.Selected and UDim2.new(.33, 0, .2, 0)) or UDim2.new(.3, 0, .2, 0),
                        Position = UDim2.new(.55, 0, .9, 0),
                        -- Event hooks --
                        [Roact.Event.MouseButton1Click] = function()
                            if data.Selected then
                                return
                            elseif data.Owned then
                                Services.ShopController:TrySelect(data.Instance)
                            elseif data.Buyable then
                                Services.ShopController:TryBuy(data.Instance)
                            end
                        end,
                        [Roact.Event.MouseEnter] = function(ref)
                            if data.Selected then
                                return
                            end
                            ref:TweenSize(UDim2.new(.33, 0, .2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                            ref.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                            ref.MainText.TextColor3 = Color3.fromRGB(0, 0, 0)
                            ref.ShadowText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end,
                        [Roact.Event.MouseLeave] = function(ref)
                            if data.Selected then
                                return
                            end
                            ref:TweenSize(UDim2.new(.3, 0, .2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                            ref.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
                            ref.MainText.TextColor3 = Color3.fromRGB(255, 255, 255)
                            ref.ShadowText.TextColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    }
                )
            end
        end
    end

    buttons = Roact.createFragment(buttons)
    return Roact.createFragment(
        {
            DecorStripe = Roact.createElement(
                "ImageLabel",
                {
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://5137326187",
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(.20, 0, 2, 0),
                    Position = UDim2.new(.08, 0, 0, 0),
                    Rotation = 5
                }
            ),
            ButtonFrame = Roact.createElement(
                "ScrollingFrame",
                {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(.20, 0, .9, 0),
                    CanvasSize = UDim2.new(0, 0, .2 * #BACKPACKS:GetChildren(), 0),
                    Position = UDim2.new(.10, 0, .05, 0),
                    AnchorPoint = Vector2.new(0, 0),
                    BorderSizePixel = 0,
                    ClipsDescendants = false
                },
                {
                    UIListLayout = Roact.createElement(
                        "UIListLayout",
                        {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Top,
                            Padding = UDim.new(0.005, 0),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        }
                    ),
                    Buttons = buttons
                }
            ),
            ViewportContainer = Roact.createElement(
                ViewportContainer,
                {
                    RenderedModel = highlightedBackpackData.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(.3, 0, .6, 0),
                    Position = UDim2.new(.4, 0, .15, 0),
                    CameraCFrame = CFrame.new(0, 0, -3)
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.1, 0)
                        }
                    ),
                    Stats = Roact.createElement(
                        "Frame",
                        {
                            Size = UDim2.new(.8, 0, .15, 0),
                            Position = UDim2.new(.5, 0, .8, 0),
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(.5, 0)
                        },
                        {
                            UIGridLayout = Roact.createElement(
                                "UIGridLayout",
                                {
                                    CellSize = UDim2.new(.5, 0, .5, 0),
                                    FillDirectionMaxCells = 2
                                }
                            ),
                            GoldCost = Roact.createElement(
                                IconFrame,
                                {
                                    Image = "rbxassetid://5013823501"
                                },
                                {
                                    Roact.createElement(
                                        "TextLabel",
                                        {
                                            Size = UDim2.new(1, 0, 1, 0),
                                            Text = string.format(" %d", highlightedBackpackData.GoldCost),
                                            TextColor3 = Color3.fromRGB(255, 187, 0),
                                            BackgroundTransparency = 1,
                                            Font = Enum.Font.GothamBold,
                                            TextScaled = true,
                                            TextXAlignment = Enum.TextXAlignment.Left
                                        }
                                    )
                                }
                            ),
                            Capacity = Roact.createElement(
                                IconFrame,
                                {
                                    Image = "rbxassetid://5572289405"
                                },
                                {
                                    Roact.createElement(
                                        "TextLabel",
                                        {
                                            Size = UDim2.new(1, 0, 1, 0),
                                            Text = string.format(" %d", highlightedBackpackData.Capacity),
                                            TextColor3 = Color3.fromRGB(255, 187, 0),
                                            BackgroundTransparency = 1,
                                            Font = Enum.Font.GothamBold,
                                            TextScaled = true,
                                            TextXAlignment = Enum.TextXAlignment.Left
                                        }
                                    )
                                }
                            )
                        }
                    )
                }
            ),
            Description = Roact.createElement(
                BackpackMenuButton,
                {
                    Size = UDim2.new(.6, 0, .1, 0),
                    Position = UDim2.new(.4, 0, 0, 0),
                    IconProps = {
                        Image = "rbxassetid://5137381399",
                        ImageColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        SliceCenter = Rect.new(300, 0, 700, 0),
                        ScaleType = Enum.ScaleType.Slice,
                        AnchorPoint = Vector2.new(.5, .5),
                        ZIndex = 1000
                    },
                    BackgroundIconProps = {
                        Image = "rbxassetid://5137381399",
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(1.03, 0, 1.15, 0),
                        SliceCenter = Rect.new(300, 0, 700, 0),
                        ScaleType = Enum.ScaleType.Slice,
                        AnchorPoint = Vector2.new(.5, .5),
                        ZIndex = 999
                    },
                    TextProps = {
                        Text = highlightedBackpackData.Description,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Position = UDim2.new(.5, 0, .5, 0),
                        AnchorPoint = Vector2.new(.5, .5),
                        Size = UDim2.new(.8, 0, .8, 0),
                        TextScaled = true,
                        ZIndex = 1001
                    },
                    AnchorPoint = Vector2.new(0, 0)
                }
            ),
            CurrCoinCount = Roact.createElement(
                BackpackMenuButton,
                {
                    Size = UDim2.new(.2, 0, .1, 0),
                    Position = UDim2.new(.8, 0, .1, 0),
                    IconProps = {
                        Image = "rbxassetid://5137381399",
                        ImageColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        SliceCenter = Rect.new(300, 0, 700, 0),
                        ScaleType = Enum.ScaleType.Slice,
                        AnchorPoint = Vector2.new(.5, .5),
                        ZIndex = 1000
                    },
                    BackgroundIconProps = {
                        Image = "rbxassetid://5137381399",
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(1.03, 0, 1.15, 0),
                        SliceCenter = Rect.new(300, 0, 700, 0),
                        ScaleType = Enum.ScaleType.Slice,
                        AnchorPoint = Vector2.new(.5, .5),
                        ZIndex = 999
                    },
                    TextProps = {
                        Text = string.format("Your coins: %d", Services.ClientPlayerData:GetStore("Gold"):getState()),
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Position = UDim2.new(.5, 0, .5, 0),
                        AnchorPoint = Vector2.new(.5, .5),
                        Size = UDim2.new(.8, 0, .8, 0),
                        TextScaled = true,
                        ZIndex = 1001
                    },
                    AnchorPoint = Vector2.new(0, 0)
                }
            ),
            ActionButton = actionButton
        }
    )
end

return BackpackList
