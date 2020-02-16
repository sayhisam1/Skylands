local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
return function()
    local Team = require("Team")
    local TeamManager = _G.Services.TeamManager
    if IsServer then
        describe(
            "Team Creation",
            function()
                HACK_NO_XPCALL()
                it(
                    "Should create a new team",
                    function()
                        local test_team = Team:New("TEST_TEAM_ONE", "TEST_TEAM_ID")
                        expect(test_team).to.be.a("table")
                        expect(test_team:GetId()).to.equal("TEST_TEAM_ID")
                    end
                )
                it(
                    "Should add team to team manager",
                    function()
                        local test_team = Team:New("TEST_TEAM_TWO", "TEST_TEAM_ID_2")
                        TeamManager:AddTeam(test_team)
                        local t2 = TeamManager:GetTeamById(test_team:GetId())
                        expect(test_team).to.equal(t2)
                        TeamManager:RemoveTeam(test_team)
                        t2 = TeamManager:GetTeamById(test_team:GetId())
                        expect(t2).never.to.be.ok()
                    end
                )
                it(
                    "Should catch teams with same id",
                    function()
                        local test_team = Team:New("TEST_TEAM_TWO", "TEST_TEAM_ID_2")
                        TeamManager:AddTeam(test_team)
                        local test_team_2 = Team:New("TEST_TEAM", "TEST_TEAM_ID_2")
                        local stat, err =
                            pcall(
                            function()
                                TeamManager:AddTeam(test_team_2)
                            end
                        )
                        expect(stat).to.equal(false)
                    end
                )
            end
        )
    end
end
