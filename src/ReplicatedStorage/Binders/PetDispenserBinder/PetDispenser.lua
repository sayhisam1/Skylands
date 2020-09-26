local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local Promise = require(ReplicatedStorage.Lib.Promise)

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local PetDispenser = setmetatable({}, InstanceWrapper)
PetDispenser.__index = PetDispenser
PetDispenser.ClassName = script.Name

function PetDispenser.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid PetDispenser!")
    local self = setmetatable(InstanceWrapper.new(instance), PetDispenser)
    self:Log(3, "Created pet dispenser")
    self:Setup()
    return self
end

function PetDispenser:Setup()
    if self._isSetup or self._destroyed then
        return
    end
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientPetDispenserSetup") or script.Parent.ClientPetDispenserSetup
    else
        setup = self:GetAttribute("ServerPetDispenserSetup") or script.Parent.ServerPetDispenserSetup
    end
    require(setup)(self)
end

function PetDispenser:RollPet(plr, n)
    assert(plr and plr:IsA("Player"), "Invalid player!")
    local PetService = Services.PetService
    n = n or 1
    local petGenerator = require(self:FindFirstChild("PetProbabilities"))

    return Promise.new(function(resolve, reject, onCancel)
        local pets = {}

        for i = 1, n, 1 do
            local petToAward = petGenerator:Sample()[1]
            pets[#pets + 1] = petToAward
        end
        PetService:GivePlayerPets(plr, pets)
        resolve(pets)
    end)
end

function PetDispenser:TryPurchase(plr, n)
    local devproductId = self:GetAttribute("DevproductId")
    local gemCost = self:GetAttribute("GemCost")
    local ticketCost = self:GetAttribute("TicketCost")
    n = n or 1
    return Promise.new(function(resolve, reject, onCancel)
        local PlayerData = Services.PlayerData
        local PetService = Services.PetService
        PetService:AssertCanAddPets(plr, n)
        if devproductId then
            MarketplaceService:PromptProductPurchase(plr, devproductId, false)
            -- HACK: Kill promise chain via error (should be handled by robux prompt instead)
            return reject("Robux purchase")
        else
            if gemCost then
                local gemStore = PlayerData:GetStore(plr, "Gems")
                gemStore:dispatch({
                    type="Decrement",
                    Amount = gemCost * n
                })
                return resolve(true)
            else
                local ticketStore = PlayerData:GetStore(plr, "RebirthTickets")
                ticketStore:dispatch({
                    type="Decrement",
                    Amount = ticketCost * n
                })
                return resolve(true)
            end
        end
        reject("No currency!")
    end)
end

return PetDispenser
