local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local Rodux = require(ReplicatedStorage.Lib.Rodux)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local reducer =
    Rodux.createReducer(
    {
        NumSelectedPets = 0,
        NumPets = 1,
        SelectedPets = {},
        MaxPetStorageSlots = 10,
        MaxSelectedPets = 10,
        Pets = {
            [1000] = {
                PetClass="Clank",
                Selected=true
            },
            [1001] = {
                PetClass="Clank",
                Selected=false
            }
        },
    },
    {}
)
local store = Rodux.Store.new(reducer)

return function(target)
    local gui = require(script.Parent)
    local element = Roact.createElement(RoactRodux.StoreProvider, {store = store}, {App = Roact.createElement(gui)})
    local handle = Roact.mount(element, target)
    return function()
        Roact.unmount(handle)
    end
end
