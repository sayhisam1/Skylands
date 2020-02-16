local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local ENABLED_ON_SERVER = true
if IsServer and not ENABLED_ON_SERVER then
    warn("Skipping " .. script.Name .. " since there are no players!")
    return function()
    end
end
if not IsServer then return function() end end
return function()
    local PlayerObject = require("PlayerObject")
    local obj = require("ServerBotPlayer"):New("testbot")
    _G.Services.PlayerManager:AddPlayer(obj)
    local DEFAULT_BOT_TEAM = _G.Services.TeamManager:GetDefaultBotTeam()
    DEFAULT_BOT_TEAM:AddMember(obj)
    obj:LoadCharacter()
    describe(
        "Creation",
        function()
            it(
                "should contain a reference",
                function()
                    expect(obj._reference).to.be.a("table")
                    expect(obj:GetReference()).to.equal(obj._reference)
                end
            )
            it(
                "should be vulnerable",
                function()
                    expect(obj.Invulnerable).to.equal(false)
                end
            )
        end
    )

    describe(
        "Serialization",
        function()
            local Pickler = require("Pickler")
            local serialized = Pickler:Pickle(obj)
            it(
                "should serialize",
                function()
                    expect(serialized).to.be.a("table")
                end
            )
        end
    )

    describe(
        "Unserialization",
        function()
            local Pickler = require("Pickler")
            local serialized = Pickler:Pickle(obj)
            local unserialized = Pickler:Unpickle(serialized)
            it(
                "should unserialize",
                function()
                    expect(unserialized).to.be.a("table")
                end
            )
            for key, val in pairs(unserialized) do
                it(
                    "should unserialize " .. key,
                    function()
                        expect(unserialized[key]).to.be.a(type(obj[key]))
                    end
                )
            end
        end
    )

    describe(
        "Merging",
        function()
            local Pickler = require("Pickler")
            local tmp = PlayerObject:New(obj:GetReference())
            it(
                "invulnerable should start at false",
                function()
                    expect(tmp.Invulnerable).to.equal(false)
                end
            )

            it(
                "should have same reference",
                function()
                    local serialized = Pickler:Pickle(tmp)
                    Pickler:Merge(tmp, serialized)
                    expect(tmp:GetReference()).to.equal(obj:GetReference())
                end
            )
            it(
                "should change invulnerable",
                function()
                    local serialized = Pickler:Pickle(tmp)
                    serialized.Invulnerable = true
                    Pickler:Merge(tmp, serialized)
                    expect(tmp.Invulnerable).to.equal(true)
                end
            )
        end
    )

    describe(
        "Cleanup",
        function()
            it(
                "should remove the object",
                function()
                    local id = obj:GetId()
                    _G.Services.PlayerManager:RemoveObject(obj)
                    expect(_G.Services.PlayerManager:GetObjectById(id)).never.to.be.ok()
                end
            )
        end
    )
end
