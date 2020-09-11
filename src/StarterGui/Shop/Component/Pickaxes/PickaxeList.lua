local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)
local PICKAXES = ReplicatedStorage:WaitForChild("Pickaxes")

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Services = require(ReplicatedStorage.Services)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local Roact = require(ReplicatedStorage.Lib.Roact)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)

local PickaxeMenuButton = require(script.Parent.PickaxeMenuButton)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local PickaxeButtons = Roact.Component:extend("PickaxeButtons")

function PickaxeButtons:init()
    self._maid = Maid.new()
    self:setState(
        {
            ownedPickaxes = Services.ClientPlayerData:GetStore("OwnedPickaxes"):getState(),
            selectedPickaxe = Services.ClientPlayerData:GetStore("SelectedPickaxe"):getState(),
            highlightedPickaxe = Services.ClientPlayerData:GetStore("SelectedPickaxe"):getState()
        }
    )
end

function PickaxeButtons:didMount()
    self._maid:GiveTask(
        Services.ClientPlayerData:GetStore("OwnedPickaxes").changed:connect(
            function(new, old)
                self:setState(
                    {
                        ownedPickaxes = new
                    }
                )
            end
        )
    )
    self._maid:GiveTask(
        Services.ClientPlayerData:GetStore("SelectedPickaxe").changed:connect(
            function(new, old)
                self:setState(
                    {
                        selectedPickaxe = new
                    }
                )
            end
        )
    )
end

function PickaxeButtons:willUnmount()
    self._maid:Destroy()
end

local function getPickaxeInfo(pickaxes, ownedPickaxes, selectedPickaxe, highlightedPickaxe)
    local list = {}
    for _, pickaxe in pairs(pickaxes) do
        local name = pickaxe.Name
        local displayName = pickaxe:FindFirstChild("DisplayName").Value
        local shopOrder = pickaxe:FindFirstChild("ShopOrder").Value
        local goldCost = pickaxe:FindFirstChild("GoldCost").Value
        local description = pickaxe:FindFirstChild("Description").Value
        local damage = pickaxe:FindFirstChild("Damage").Value
        local critChance = pickaxe:FindFirstChild("CritChance").Value
        local selected = (name == selectedPickaxe)
        local highlighted = (name == highlightedPickaxe)
        local owned = (TableUtil.contains(ownedPickaxes, name))
        local buyable = goldCost ~= math.huge
        local hidden = not (buyable or owned)

        list[name] = {
            Instance = pickaxe,
            Name = name,
            DisplayName = displayName,
            Damage = damage,
            CritChance = critChance,
            ShopOrder = shopOrder,
            GoldCost = goldCost,
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
function PickaxeButtons:render()
    local buttons = {}
    local ownedPickaxes = self.state.ownedPickaxes
    local selectedPickaxe = self.state.selectedPickaxe
    local highlightedPickaxe = self.state.highlightedPickaxe or selectedPickaxe
    local highlightedPickaxeData = nil
    local actionButton = nil
    for name, data in pairs(getPickaxeInfo(PICKAXES:GetChildren(), ownedPickaxes, selectedPickaxe, highlightedPickaxe)) do
        highlightedPickaxeData = (data.Highlighted and data) or highlightedPickaxeData
        if not data.Hidden then
            math.randomseed(string.byte(name) + GLOBAL_RAND_SHIFT)
            local buttonRotation = math.random(-2, 2)
            buttons[name] =
                Roact.createElement(
                PickaxeMenuButton,
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
                                highlightedPickaxe = name
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
                    PickaxeMenuButton,
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
                    CanvasSize = UDim2.new(0, 0, .2 * #PICKAXES:GetChildren(), 0),
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
                    RenderedModel = highlightedPickaxeData.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(.3, 0, .7, 0),
                    Position = UDim2.new(.4, 0, .15, 0),
                    CameraCFrame = CFrame.new(0, 0, 5),
                    -- ModelCFrame = CFrame.Angles(0, math.pi / 8, math.pi / 8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                },
                {
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
                                    CellPadding = UDim2.new(0, 0, 0, 0),
                                    CellSize = UDim2.new(.5, 0, .5, 0),
                                    FillDirectionMaxCells = 2,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }
                            ),
                            GoldCost = Roact.createElement(
                                IconFrame,
                                {
                                    Image = "rbxassetid://5013823501",
                                    LayoutOrder = 3
                                },
                                {
                                    Roact.createElement(
                                        "TextLabel",
                                        {
                                            Size = UDim2.new(1, 0, 1, 0),
                                            Text = string.format("%s", NumberToStr(highlightedPickaxeData.GoldCost)),
                                            TextColor3 = Color3.fromRGB(255, 187, 0),
                                            BackgroundTransparency = 1,
                                            Font = Enum.Font.GothamBold,
                                            TextScaled = true,
                                            TextXAlignment = Enum.TextXAlignment.Left
                                        }
                                    )
                                }
                            ),
                            Damage = Roact.createElement(
                                IconFrame,
                                {
                                    Image = "rbxassetid://5063940411",
                                    LayoutOrder = 1
                                },
                                {
                                    Roact.createElement(
                                        "TextLabel",
                                        {
                                            Size = UDim2.new(1, 0, 1, 0),
                                            Text = string.format("%s", NumberToStr(highlightedPickaxeData.Damage)),
                                            TextColor3 = Color3.fromRGB(255, 187, 0),
                                            BackgroundTransparency = 1,
                                            Font = Enum.Font.GothamBold,
                                            TextScaled = true,
                                            TextXAlignment = Enum.TextXAlignment.Left
                                        }
                                    )
                                }
                            ),
                            CriticalStrike = Roact.createElement(
                                IconFrame,
                                {
                                    Image = "rbxassetid://5063940411",
                                    LayoutOrder = 2
                                },
                                {
                                    Roact.createElement(
                                        "TextLabel",
                                        {
                                            Size = UDim2.new(1, 0, 1, 0),
                                            Text = string.format(" %.2f", highlightedPickaxeData.CritChance),
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
                PickaxeMenuButton,
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
                        Text = highlightedPickaxeData.Description,
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
                PickaxeMenuButton,
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
                        Text = string.format("Your coins: %s", NumberToStr(Services.ClientPlayerData:GetStore("Gold"):getState())),
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

return PickaxeButtons
