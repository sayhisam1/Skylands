local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local TypewriterText = Roact.Component:extend("TypewriterText")

function TypewriterText:init()
    self:setState(
        {
            maid = Maid.new(),
            currText = "",
            targetText = ""
        }
    )
end

function TypewriterText.getDerivedStateFromProps(props, state)
    return {
        targetText = props.Text,
        onUpdate = props.onUpdate
    }
end
function TypewriterText:render()
    local newProps = TableUtil.shallow(self.props)
    newProps["Text"] = self.state.currText
    newProps["onUpdate"] = nil
    return Roact.createElement("TextLabel", newProps)
end

function TypewriterText:didMount()
    self.running = true

    coroutine.wrap(
        function()
            while self.running do
                self:setState(
                    function(state)
                        if state.currText == state.targetText then
                            return {
                                currText = state.targetText
                            }
                        end
                        local ret = ""
                        if #state.currText >= #state.targetText then
                            ret = state.targetText[1]
                        else
                            ret = state.targetText:sub(1, #state.currText + 1)
                        end
                        if state.onUpdate then
                            state.onUpdate(ret)
                        end
                        return {
                            currText = ret
                        }
                    end
                )

                wait(.01)
            end
        end
    )()
end

function TypewriterText:willUnmount()
    self.running = false
end

return TypewriterText
