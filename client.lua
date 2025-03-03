-- Configuration is defined in config.lua

-- State variables
local State = {
    hidden = true,
    loaded = false,
    framework = false,
    frameworkName = nil,
    lastStatus = {} -- Cache last status to avoid unnecessary updates
}

-- Detect which framework is being used
local function detectFramework()
    if GetResourceState('ox_core') == 'started' then
        State.frameworkName = 'ox_core'
        State.framework = true
        return
    elseif GetResourceState('es_extended') == 'started' and GetResourceState('esx_status') == 'started' then
        State.frameworkName = 'esx'
        State.framework = true
        return
    elseif GetResourceState('qb-core') == 'started' then
        State.frameworkName = 'qb-core'
        State.framework = true
        return
    end
    State.framework = false
    State.frameworkName = 'none'
    print('[g4_hud] No framework detected, using standalone mode')
end

-- Helper function to get vehicle data
local function getVehicleData()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not DoesEntityExist(vehicle) then return nil end
    
    return {
        value = math.floor(GetEntitySpeed(vehicle) * (Config.isUnitMetric and 3.6 or 2.236936)),
        fuel = math.floor(GetVehicleFuelLevel(vehicle)),
        unit = Config.isUnitMetric and 'km/h' or 'mph'
    }
end

-- Helper function to get player base stats
local function getPlayerBaseStats()
    local health = math.floor(GetEntityHealth(PlayerPedId()) / 2)
    local armour = math.floor(GetPedArmour(PlayerPedId()))
    local energy = math.floor(GetPlayerStamina(PlayerId()))
    
    return {
        health = health,
        armour = armour,
        energy = energy,
    }
end

-- Helper function to send NUI message
local function updateHUD(data)
    if State.loaded then
        -- Only send if data is different from last update
        local shouldUpdate = false
        
        -- Compare with last status
        if next(State.lastStatus) == nil then
            shouldUpdate = true
        else
            -- Check if vehicle state changed
            if (data.vehicle and not State.lastStatus.vehicle) or 
               (not data.vehicle and State.lastStatus.vehicle) then
                shouldUpdate = true
            end
            
            -- Check health or other critical stats
            if data.health ~= State.lastStatus.health or
               data.armour ~= State.lastStatus.armour then
                shouldUpdate = true
            end
            
            -- Check vehicle stats if in vehicle
            if data.vehicle and State.lastStatus.vehicle then
                if data.vehicle.value ~= State.lastStatus.vehicle.value or
                   data.vehicle.fuel ~= State.lastStatus.vehicle.fuel then
                    shouldUpdate = true
                end
            end
            
            -- Check other status values
            for k, v in pairs(data) do
                if type(v) ~= "table" and State.lastStatus[k] ~= v then
                    shouldUpdate = true
                    break
                end
            end
        end
        
        if shouldUpdate then
            -- Add color configuration
            data.colors = Config.colors
            SendNUIMessage({event = "updateStatus", data = data})
            -- Update cache
            State.lastStatus = data
        end
    end
end

-- Handler for NUI callback
RegisterNUICallback('loaded', function(data, cb)
    State.loaded = true
    print('[g4_hud] UI loaded')
    cb({})
end)

-- Initialize HUD
Citizen.CreateThread(function()
    -- Wait for NUI to load
    local startTime = GetGameTimer()
    local timeout = 5000 -- 5 second timeout
    
    while not State.loaded do
        Wait(100)
        if GetGameTimer() - startTime > timeout then
            print('[g4_hud] Warning: UI load timeout')
            break
        end
    end
    
    -- Detect framework
    detectFramework()
    
    -- Main loop
    while true do
        local wait = Config.updateInterval
        local status = {}
        local ped = PlayerPedId()
        
        -- Check if in vehicle
        if IsPedInAnyVehicle(ped, false) then
            wait = Config.vehicleUpdateInterval
            status.vehicle = getVehicleData()
            
            -- If framework is active, let the framework handlers add other stats
            if State.framework then
                SendNUIMessage({event = "updateStatus", data = status})
            end
        end
        
        -- If no framework is detected, use basic stats
        if not State.framework then
            local baseStats = getPlayerBaseStats()
            for k, v in pairs(baseStats) do
                status[k] = v
            end
            updateHUD(status)
        end

        -- Handle HUD visibility based on pause menu
        if Config.hideInPauseMenu then
            if State.hidden and not IsPauseMenuActive() then
                State.hidden = false
                SendNUIMessage({event = "show"})
            elseif not State.hidden and IsPauseMenuActive() then
                State.hidden = true
                SendNUIMessage({event = "hide"})
            end
        elseif State.hidden then
            State.hidden = false
            SendNUIMessage({event = "show"})
        end

        Wait(wait)
    end
end)

-- Framework-specific handlers
if GetResourceState('ox_core') == 'started' then
    AddEventHandler('ox:statusTick', function(newStatus)
        local status = {}

        -- Process ox_core status values
        for k, v in pairs(newStatus) do
            status[k] = math.floor(v)
        end

        -- Add energy if stress is not provided
        if not newStatus.stress then
            status.energy = math.floor(GetPlayerStamina(PlayerId()))
        end

        -- Add base stats
        local baseStats = getPlayerBaseStats()
        for k, v in pairs(baseStats) do
            status[k] = v
        end

        -- Check if in vehicle
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            status.vehicle = getVehicleData()
        end

        updateHUD(status)
    end)
elseif GetResourceState('es_extended') == 'started' and GetResourceState('esx_status') == 'started' then
    AddEventHandler('esx_status:onTick', function(newStatus)
        local status = {}

        -- Process ESX status values
        for i = 1, #newStatus do
            if newStatus[i].name == "thirst" then
                status.thirst = math.floor(newStatus[i].percent)
            end
            if newStatus[i].name == "hunger" then
                status.hunger = math.floor(newStatus[i].percent)
            end
        end

        -- Add base stats
        local baseStats = getPlayerBaseStats()
        for k, v in pairs(baseStats) do
            status[k] = v
        end

        -- Check if in vehicle
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            status.vehicle = getVehicleData()
        end

        updateHUD(status)
    end)
elseif GetResourceState('qb-core') == 'started' then
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(newStatus)
        local status = {}

        -- Process QBCore status values
        if tonumber(newStatus.metadata.hunger) then
            status.hunger = math.floor(newStatus.metadata.hunger)
        end
        if tonumber(newStatus.metadata.thirst) then
            status.thirst = math.floor(newStatus.metadata.thirst)
        end
        if tonumber(newStatus.metadata.stress) then
            status.stress = math.floor(newStatus.metadata.stress)
        else
            status.energy = math.floor(GetPlayerStamina(PlayerId()))
        end

        -- Add base stats
        local baseStats = getPlayerBaseStats()
        for k, v in pairs(baseStats) do
            status[k] = v
        end

        -- Check if in vehicle
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            status.vehicle = getVehicleData()
        end

        updateHUD(status)
    end)
end