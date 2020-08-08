-- stores player inventories --

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local PetBinder = require(ReplicatedStorage.PetBinder)
local PETS = ReplicatedStorage:WaitForChild("Pets")
local Players = game:GetService("Players")
local Enums = require(ReplicatedStorage.Enums)

function Service:Load()
    local maid = self._maid
    local PlayerData = self.Services.PlayerData

    local function setupPlayer(plr)
        self:Log(2, "Setting up pet for", plr)
        local pets = PlayerData:GetStore(plr, "Pets")
        local petChangedConnector =
            pets.changed:connect(
            function(new, old)
                self:SetPlayerPets(plr, new)
            end
        )
        maid:GiveTask(plr.CharacterAdded:Connect(function()
            self:SetPlayerPets(plr, pets:getState())
        end))
        maid:GiveTask(
            function()
                petChangedConnector:disconnect()
            end
        )
        self:ValidatePlayer(plr)
    end
    for _, plr in pairs(Players:GetPlayers()) do
        while not plr.Character do wait() end
        setupPlayer(plr)
    end
    maid:GiveTask(
        Players.PlayerAdded:Connect(
            function(plr)
                maid:GiveTask(
                    plr.CharacterAdded:Connect(
                        function()
                            setupPlayer(plr)
                        end
                    )
                )
            end
        )
    )
end

local function removePets(plr)
    assert(plr and plr:IsA("Player"), "Invalid player")
    for _, v in pairs(plr:GetChildren()) do
        if CollectionService:HasTag(v, Enums.Tags.Pet) then
            v:Destroy()
        end
    end
end

local function addPet(plr, pet)
    assert(plr and plr:IsA("Player"), "Invalid player")
    assert(pet and pet:IsDescendantOf(PETS), "Invalid pet")
    local pet = pet:Clone()
    pet.Parent = plr
    CollectionService:AddTag(pet, Enums.Tags.Pet)
end

function Service:SetPlayerPets(plr, pets)
    self:Log(2, "SETTING PET", plr, pet)
    removePets(plr)
    for _, pet in pairs(pets) do
        local loadedPet = self:LoadPetFromData(pet)
        if loadedPet then
            addPet(plr, loadedPet)
        end
    end
end

function Service:LookupPet(name)
    self:Log(1, "Looking up pet", name)
    local pet = PETS:FindFirstChild(name)
    return pet
end

function Service:LoadPetFromData(data)
    local petclass = data.PetClass
    local instance = self:LookupPet(petclass)
    return instance
end

function Service:ValidatePlayer(plr)
    local PlayerData = self.Services.PlayerData
    local pets = PlayerData:GetStore(plr, "Pets"):getState()
    for _, data in pairs(pets) do
        if not data.PetClass and data.Id then
            error(plr, "Doesn't have valid pet data!")
        end
    end
end

function Service:GivePlayerPet(plr, pet)
    assert(plr and plr:IsA("Player"), "Invalid player")
    assert(pet and typeof(pet) == "string", "Invalid pet")
    petInstance = self:LookupPet(pet)
    assert(petInstance and petInstance:IsA("Model"), "Unknown pet!")
    local petData = {
        PetClass = pet,
        Id = HttpService:GenerateGUID(false)
    }
    local store = self.Services.PlayerData:GetStore(plr, "Pets")
    store:dispatch({
        type="AddPet",
        Data = petData
    })
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
