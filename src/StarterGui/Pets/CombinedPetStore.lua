-- PET MENU --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local ClientPlayerData = Services.ClientPlayerData
local PetStore = ClientPlayerData:GetStore("Pets")
local MaxSelectedPets = ClientPlayerData:GetStore("MaxSelectedPets")
local MaxPetStorageSlots = ClientPlayerData:GetStore("MaxPetStorageSlots")

local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local Rodux = require(ReplicatedStorage.Lib.Rodux)

local reducer =
    Rodux.createReducer(
    {
        NumSelectedPets = 0,
        NumPets = 0,
        SelectedPets = {},
        MaxPetStorageSlots = 0,
        MaxSelectedPets = 0,
        Pets = {},
    },
    {
        UpdatePets = function(state, action)
            local newState = TableUtil.shallow(state)
            newState.Pets = action.Pets or {}
            -- update selected pets
            newState.NumPets = TableUtil.len(newState.Pets)
            newState.SelectedPets =
                TableUtil.filter(
                newState.Pets,
                function(k, v)
                    return v.Selected
                end
            )
            newState.NumSelectedPets = TableUtil.len(newState.SelectedPets)
            return newState
        end,
        UpdateMaxSelectedPets = function(state, action)
            local newState = TableUtil.shallow(state)
            newState.MaxSelectedPets = action.MaxSelectedPets
            return newState
        end,
        UpdateMaxPetStorageSlots = function(state, action)
            local newState = TableUtil.shallow(state)
            newState.MaxPetStorageSlots = action.MaxPetStorageSlots
            return newState
        end
    }
)
local CombinedPetsStore = Rodux.Store.new(reducer)

PetStore.changed:connect(
    function(new)
        CombinedPetsStore:dispatch(
            {
                type = "UpdatePets",
                Pets = new
            }
        )
    end
)

CombinedPetsStore:dispatch(
    {
        type = "UpdatePets",
        Pets = PetStore:getState()
    }
)

MaxSelectedPets.changed:connect(
    function(new)
        CombinedPetsStore:dispatch(
            {
                type = "UpdateMaxSelectedPets",
                MaxSelectedPets = new
            }
        )
    end
)

CombinedPetsStore:dispatch(
    {
        type = "UpdateMaxSelectedPets",
        MaxSelectedPets = MaxSelectedPets:getState()
    }
)

MaxPetStorageSlots.changed:connect(
    function(new)
        CombinedPetsStore:dispatch(
            {
                type = "UpdateMaxPetStorageSlots",
                MaxPetStorageSlots = new
            }
        )
    end
)

CombinedPetsStore:dispatch(
    {
        type = "UpdateMaxPetStorageSlots",
        MaxPetStorageSlots = MaxPetStorageSlots:getState()
    }
)

return CombinedPetsStore