-- stores player inventories --

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData", "InitializeBinders"}
Service:AddDependencies(DEPENDENCIES)

local Enums = require(ReplicatedStorage.Enums)
local AssetFinder = require(ReplicatedStorage.AssetFinder)

function Service:Load()
    local maid = self._maid

    local function setupPlayer(plr)
        local pets = self.Services.PlayerData:GetStore(plr, "Pets")
        maid:GiveTask(
            pets.changed:connect(
                function(new)
                    self:SetPlayerPets(plr, new)
                end
            )
        )
        maid:GiveTask(
            plr.CharacterAdded:Connect(
                function()
                    self:SetPlayerPets(plr, pets:getState())
                end
            )
        )
        self:ValidatePlayer(plr)
    end
    self:HookPlayerAction(setupPlayer)

    local network_channel = self:GetNetworkChannel()
    maid:GiveTask(
        network_channel:Subscribe(
            "SELECT_PET",
            function(plr, petId)
                self:SelectPet(plr, petId)
            end
        )
    )
    maid:GiveTask(
        network_channel:Subscribe(
            "UNSELECT_PET",
            function(plr, petId)
                local store = self.Services.PlayerData:GetStore(plr, "Pets")
                store:dispatch(
                    {
                        type = "UnselectPet",
                        Id = petId
                    }
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
    assert(pet and pet:IsA("Model"), "Invalid pet")
    pet.Parent = plr
    CollectionService:AddTag(pet, Enums.Tags.Pet)
end

function Service:SelectPet(plr, petId)
    assert(plr and plr:IsA("Player"), "Invalid player")
    assert(typeof(petId) == "string", "Invalid pet id!")
    local store = self.Services.PlayerData:GetStore(plr, "Pets")
    local selectedPets = {}
    for id, v in pairs(store:getState()) do
        if v.Selected then
            selectedPets[id] = v
        end
    end
    local numSelected = self.TableUtil.len(selectedPets)
    local maxSelected = self.Services.PlayerData:GetStore(plr, "MaxSelectedPets"):getState()
    if numSelected < maxSelected then
        store:dispatch(
            {
                type = "SelectPet",
                Id = petId
            }
        )
    end
end

function Service:SetPlayerPets(plr, pets)
    removePets(plr)
    for _, pet in pairs(pets) do
        if pet.Selected then
            local loadedPet = self:LoadPetFromData(pet)
            if loadedPet then
                addPet(plr, loadedPet)
            end
        end
    end
end

function Service:LoadPetFromData(data)
    local petclass = data.PetClass
    return AssetFinder.FindPet(petclass):Clone()
end

function Service:ValidatePlayer(plr)
    local PlayerData = self.Services.PlayerData
    local pets = PlayerData:GetStore(plr, "Pets"):getState()
    for _, data in pairs(pets) do
        if not data.PetClass and data.Id then
            error(plr.Name .. "Doesn't have valid pet data!")
        end
    end
end

function Service:CreatePetData(petName)
    assert(petName and typeof(petName) == "string", "Invalid pet name!")
    local instance = AssetFinder.FindPet(petName)
    local data = {
        PetClass = instance.Name,
        Id = HttpService:GenerateGUID(false)
    }
    return data
end

function Service:GivePlayerPet(plr, petName)
    assert(plr and plr:IsA("Player"), "Invalid player")
    local petData = self:CreatePetData(petName)
    local store = self.Services.PlayerData:GetStore(plr, "Pets")
    store:dispatch(
        {
            type = "AddPet",
            Data = petData
        }
    )
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
