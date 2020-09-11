local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(leaderboard)
    assert(RunService:IsClient(), "Can only be called on client!")
    leaderboard:SetAttribute("CurrentPage", 1)
    local promise =
        Promise.new(
        function(resolve)
            local p1 = leaderboard:WaitForChildPromise("Gui")
            local p2 = leaderboard:WaitForChildPromise("PageButtons")
            resolve(p1:expect(), p2:expect())
        end
    ):andThen(
        function(gui, pagebuttons)
            local sf = gui:WaitForChild("ScrollingFrame")
            local textLabel = sf:WaitForChild("TextLabel"):Clone()
            local function renderData(pagenum, data)
                leaderboard:SetAttribute("CurrentPage", pagenum)
                for _, v in pairs(sf:GetChildren()) do
                    if v:IsA("TextLabel") then
                        v:Destroy()
                    end
                end
                for i, curr in ipairs(data or {}) do
                    local newText = textLabel:Clone()
                    Promise.new(
                        function(resolve)
                            local headshot =
                                Players:GetUserThumbnailAsync(tonumber(curr.key), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                            newText.CharacterPic.Image = headshot
                        end
                    ):catch(function()

                    end)

                    Promise.new(
                        function(resolve)
                            local name = Players:GetNameFromUserIdAsync(tonumber(curr.key))
                            newText.PlayerName.Text = name
                        end
                    ):catch(function()

                    end)
                    newText.Value.Text = NumberToStr(curr.value)
                    newText.LayoutOrder = i
                    newText.Parent = sf
                    local rank = i + (pagenum - 1) * 10
                    local rankColor = leaderboard:GetAttribute(string.format("Rank%dColor", rank))
                    if rankColor then
                        newText.BackgroundColor3 = rankColor
                    end

                    newText.Rank.Text = tostring(rank)
                end
            end
            local nc = leaderboard:GetNetworkChannel()
            nc:Subscribe("PAGES/RESPONSE", renderData)
            nc:Subscribe(
                "PAGES/UPDATE",
                function()
                    nc:Publish("PAGES/GET", leaderboard:GetAttribute("CurrentPage"))
                end
            )
            local down,
                up = pagebuttons:WaitForChild("Down"), pagebuttons:WaitForChild("Up")
            down.MouseButton1Click:Connect(
                function()
                    nc:Publish("PAGES/GET", math.max(leaderboard:GetAttribute("CurrentPage") - 1, 1))
                end
            )
            up.MouseButton1Click:Connect(
                function()
                    nc:Publish("PAGES/GET", leaderboard:GetAttribute("CurrentPage") + 1)
                end
            )
            nc:Publish("PAGES/GET", leaderboard:GetAttribute("CurrentPage"))
        end
    )
    leaderboard._maid:GiveTask(
        function()
            promise:cancel()
        end
    )
end
