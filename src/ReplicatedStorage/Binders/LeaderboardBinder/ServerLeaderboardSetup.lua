local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local UPDATE_INTERVAL = 60

return function(leaderboard)
    assert(RunService:IsServer(), "Can only be called on client!")
    local leaderboardCategory = leaderboard:GetAttribute("LeaderboardCategory")
    local data = DataStoreService:GetOrderedDataStore(leaderboardCategory, "LIVE_DATA")
    local nc = leaderboard:GetNetworkChannel()
    local pageCache = {}
    local currPage = nil
    local currPageNum = 11
    local function refreshData()
        leaderboard:Log(3, "Getting category", leaderboardCategory)
        local page = data:GetSortedAsync(false, 10)
        pageCache[1] = page:GetCurrentPage()
        page:AdvanceToNextPageAsync()
        currPageNum = 2
        currPage = page
    end
    nc:Subscribe(
        "PAGES/GET",
        function(plr, pagenum)
            pagenum = pagenum or currPageNum + 5
            if not pageCache[pagenum] then
                while currPageNum <= pagenum do
                    pageCache[currPageNum] = currPage:GetCurrentPage()
                    currPage:AdvanceToNextPageAsync()
                    currPageNum = currPageNum + 1
                end
            end
            nc:PublishPlayer(plr, "PAGES/RESPONSE", pagenum, pageCache[pagenum])
        end
    )
    coroutine.wrap(
        function()
            while true do
                pcall(refreshData)
                nc:Publish("PAGES/UPDATE")
                wait(UPDATE_INTERVAL)
            end
        end
    )()
end
