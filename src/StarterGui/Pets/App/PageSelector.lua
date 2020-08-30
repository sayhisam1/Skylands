local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

local PageSelector = Roact.Component:extend("PageSelector")

function PageSelector:render()
    local maxPages = math.ceil(self.props.MaxPetStorageSlots / 12)
    local prevPage = math.max(1, self.props.CurrentPage - 1)
    local nextPage = math.min(maxPages, self.props.CurrentPage + 1)
    return Roact.createElement(
        "Frame",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 50
        },
        {
            CurrPage = Roact.createElement(
                ShadowedText,
                {
                    ShadowOffset = UDim2.new(.01, 0, .01, 0),
                    Size = UDim2.new(1, 0, .4, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = string.format("%d/%d", self.props.CurrentPage, maxPages)
                }
            ),
            Prev = Roact.createElement(
                "TextButton",
                {
                    Size = UDim2.new(.45, 0, .6, 0),
                    Position = UDim2.new(0, 0, .4, 0),
                    BackgroundTransparency = 0,
                    TextScaled = true,
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(128, 191, 247),
                    [Roact.Event.MouseButton1Click] = function()
                        self.props.setCurrentPage(prevPage)
                    end
                },
                {
                    Text = Roact.createElement(
                        ShadowedText,
                        {
                            ShadowOffset = UDim2.new(.04, 0, .03, 0),
                            Size = UDim2.new(.8, 0, .8, 0),
                            Position = UDim2.new(.5, 0, .5, 0),
                            AnchorPoint = Vector2.new(.5, .5),
                            Text = "PREV"
                        }
                    ),
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.4, 0)
                        }
                    )
                }
            ),
            Next = Roact.createElement(
                "TextButton",
                {
                    Size = UDim2.new(.45, 0, .6, 0),
                    Position = UDim2.new(0.55, 0, .4, 0),
                    BackgroundTransparency = 0,
                    TextScaled = true,
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(128, 191, 247),
                    [Roact.Event.MouseButton1Click] = function()
                        self.props.setCurrentPage(nextPage)
                    end
                },
                {
                    Text = Roact.createElement(
                        ShadowedText,
                        {
                            ShadowOffset = UDim2.new(.03, 0, .03, 0),
                            Size = UDim2.new(.8, 0, .8, 0),
                            Position = UDim2.new(.5, 0, .5, 0),
                            AnchorPoint = Vector2.new(.5, .5),
                            Text = "NEXT"
                        }
                    ),
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.4, 0)
                        }
                    )
                }
            )
        }
    )
end

PageSelector =
    RoactRodux.connect(
    function(state, _)
        return {
            MaxPetStorageSlots = state.MaxPetStorageSlots
        }
    end
)(PageSelector)

return PageSelector
