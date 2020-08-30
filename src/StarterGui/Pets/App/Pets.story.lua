local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local Rodux = require(ReplicatedStorage.Lib.Rodux)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local AssetFinder = require(ReplicatedStorage.AssetFinder)

return function(target)
    local clank1 = AssetFinder.FindPet("Clank")
    local clank2 = AssetFinder.FindPet("Clank")
    local reducer =
        Rodux.createReducer(
        {
            NumSelectedPets = 0,
            NumPets = 2,
            SelectedPets = {
                [1000] = clank1
            },
            MaxPetStorageSlots = 13,
            MaxSelectedPets = 24,
            Pets = {
                [1001] = clank2
            },
        },
        {}
    )
    local store = Rodux.Store.new(reducer)
    local gui = require(script.Parent)
    local element = Roact.createElement(RoactRodux.StoreProvider, {store = store}, {App = Roact.createElement(gui)})
    local handle = Roact.mount(element, target)
    return function()
        if handle then
            Roact.unmount(handle)
        end
    end
end
