--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {"PlayerSettingsService"}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

local Services = _G.Services

local PlayerSettingsService = Services.PlayerSettingsService

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local LoadedInputs = {}

function Service:Load()
    local channel = self:GetChannel()

    local input_settings = PlayerSettingsService:GetInputSettings()
    for group_name, key_group in pairs(input_settings) do
        for action_name, bindings in pairs(key_group) do
            local state_active = false
            for _, input_object in pairs(bindings) do
                -- input states keeps track of which keys have been held down
                local input_states = {}
                local function check_input_states()
                    for i = 1, #input_states, 1 do
                        if (not input_states[i]) then
                            return false
                        end
                    end
                    return true
                end

                -- Now we bind context action service to inputs
                for index, input_data in pairs(input_object:GetInputs()) do
                    input_states[index] = false
                    local key_code = input_data[1] -- the key code
                    local enabled_state = input_data[2] -- state when key is considered "enabled"

                    ContextActionService:BindAction(
                        tostring(key_code),
                        function(input_name, action_state, input_object)
                            -- check for gui 
                            if game:GetService("UserInputService"):GetFocusedTextBox() then
                                return Enum.ContextActionResult.Pass
                            end
                            if (action_state == enabled_state) then
                                input_states[index] = true
                                if (check_input_states()) then
                                    state_active = true
                                    channel:Publish(action_name, state_active)
                                end
                            else
                                input_states[index] = false
                                state_active = false
                                channel:Publish(action_name, false)
                            end
                            return Enum.ContextActionResult.Pass
                        end,
                        false,
                        key_code
                    )
                end
            end
        end
    end
end

function Service:Unload()
    for i, v in pairs(LoadedInputs) do
        v:Disconnect()
        LoadedInputs[i] = nil
    end
    LoadedInputs = {}
end

return Service
