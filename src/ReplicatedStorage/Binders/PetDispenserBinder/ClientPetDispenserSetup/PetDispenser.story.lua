local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local AssetFinder = require(ReplicatedStorage.AssetFinder)

local PetDispenserBuyGui = require(script.Parent.PetDispenserBuyGui)
return function(target)
    local el = Roact.createElement(PetDispenserBuyGui, {
        Choices = {
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 2313.
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
            {
                Pet = AssetFinder.FindPet("Cerberus"),
                Rarity = 100
            },
        },
        GemCost = 10
    }, {
    })

    local handle = Roact.mount(el, target)
    return function()
        Roact.unmount(handle)
    end
end
