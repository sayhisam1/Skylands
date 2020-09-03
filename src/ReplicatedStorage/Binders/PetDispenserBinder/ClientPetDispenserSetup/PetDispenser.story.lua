local PetDispenserBuyGui = require(script.Parent.PetDispenserBuyGui)
local PetDispenser = require(script.Parent.Parent.PetDispenser)
local SampleDispenser = game.Workspace.PetDispensers.BlueSpawner
local mockDispenser = PetDispenser.new(SampleDispenser)
return function(target)
    return PetDispenserBuyGui(target, mockDispenser)
end
