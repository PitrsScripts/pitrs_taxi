local taxiNPCs = {}
local currentTaxi = nil
local currentDriver = nil
local isInTaxi = false

CreateThread(function()
    while true do
        if isInTaxi then
            DisableControlAction(0, 75, true)
        end
        Wait(0)
    end
end)


CreateThread(function()
    Wait(1000) 
    if Config.Debug then print(Config.Messages.SpawningNPC) end
    for i, coords in ipairs(Config.TaxiNPCs) do
        if Config.Debug then print(Config.Messages.LoadingModel .. Config.NPCModel) end
        RequestModel(GetHashKey(Config.NPCModel))
        while not HasModelLoaded(GetHashKey(Config.NPCModel)) do
            Wait(10)
        end
        if Config.Debug then print(Config.Messages.CreatingNPCAt .. tostring(coords)) end
        local npc = CreatePed(4, GetHashKey(Config.NPCModel), coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
        
        if DoesEntityExist(npc) then
            if Config.Debug then print(Config.Messages.NPCCreated .. npc) end
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            FreezeEntityPosition(npc, true)
            SetModelAsNoLongerNeeded(GetHashKey(Config.NPCModel))
            if Config.Target == 'ox' then
                exports.ox_target:addLocalEntity(npc, {
                    {
                        name = 'taxi_service_' .. i,
                        label = Config.Messages.TaxiService,
                        icon = 'fas fa-taxi',
                        onSelect = function()
                            openTaxiMenu()
                        end
                    }
                })
            elseif Config.Target == 'qb' then
                exports['qb-target']:AddTargetEntity(npc, {
                    options = {
                        {
                            type = "client",
                            event = "taxi:openMenu",
                            icon = "fas fa-taxi",
                            label = Config.Messages.TaxiService,
                        },
                    },
                    distance = 2.0
                })
            end
            
            table.insert(taxiNPCs, npc)
    
            if Config.ShowBlip then
                local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blip, Config.BlipSprite)
                SetBlipColour(blip, Config.BlipColor)
                SetBlipScale(blip, Config.BlipScale)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Config.BlipName)
                EndTextCommandSetBlipName(blip)
            end
        else
            if Config.Debug then print(Config.Messages.FailedCreateNPC) end
        end
    end
end)

RegisterNetEvent('taxi:openMenu', function()
    openTaxiMenu()
end)

function openTaxiMenu()
    local options = {}
    
    for i, dest in ipairs(Config.Destinations) do
        table.insert(options, {
            title = dest.label,
            description = Config.Messages.FreeTransport,
            icon = 'taxi',
            onSelect = function()
                callTaxi(dest)
            end
        })
    end
    
    lib.registerContext({
        id = 'taxi_menu',
        title = Config.Messages.TaxiService,
        options = options
    })
    
    lib.showContext('taxi_menu')
end


function callTaxi(destination)
    if isInTaxi then
        lib.notify({
            title = 'Taxi',
            description = Config.Messages.AlreadyInTaxi,
            type = 'error'
        })
        return
    end

    RequestModel(GetHashKey(Config.TaxiVehicle))
    while not HasModelLoaded(GetHashKey(Config.TaxiVehicle)) do Wait(1) end
    RequestModel(GetHashKey(Config.DriverModel))
    while not HasModelLoaded(GetHashKey(Config.DriverModel)) do Wait(1) end

    local spawnCoords = destination.spawnCoords
    currentTaxi = CreateVehicle(GetHashKey(Config.TaxiVehicle), spawnCoords.x, spawnCoords.y, spawnCoords.z, destination.spawnHeading, true, false)
    currentDriver = CreatePedInsideVehicle(currentTaxi, 26, GetHashKey(Config.DriverModel), -1, true, false)
    
    if Config.FuelSystem == 'cc-fuel' then
        exports['cc-fuel']:SetFuel(currentTaxi, 100.0)
    elseif Config.FuelSystem == 'LegacyFuel' then
        exports['LegacyFuel']:SetFuel(currentTaxi, 100.0)
    elseif Config.FuelSystem == 'ox_fuel' then
        Entity(currentTaxi).state.fuel = 100.0
    else
        SetVehicleFuelLevel(currentTaxi, 100.0)
    end

    SetEntityInvincible(currentDriver, true)
    SetBlockingOfNonTemporaryEvents(currentDriver, true)
    SetDriverAbility(currentDriver, 1.0)
    SetDriverAggressiveness(currentDriver, 0.0)

    TaskWarpPedIntoVehicle(PlayerPedId(), currentTaxi, 2)
    isInTaxi = true
    SetVehicleDoorsLocked(currentTaxi, 2)

    lib.notify({
        title = 'Taxi',
        description = Config.Messages.GoingTo .. destination.label,
        type = 'inform'
    })

    TaskVehicleDriveToCoordLongrange(
        currentDriver, currentTaxi,
        destination.coords.x, destination.coords.y, destination.coords.z,
        Config.DrivingSpeed, Config.DrivingStyle, 1.0
    )

    CreateThread(function()
        local parked = false
        while isInTaxi do
            local taxiPos = GetEntityCoords(currentTaxi)
            local destDistance = #(vector3(taxiPos.x, taxiPos.y, taxiPos.z) - vector3(destination.coords.x, destination.coords.y, destination.coords.z))
            if destDistance < 8.0 and not parked then
                ClearPedTasks(currentDriver)
                TaskVehiclePark(
                    currentDriver, currentTaxi,
                    destination.coords.x, destination.coords.y, destination.coords.z,
                    destination.coords.w,
                    1, 20.0, true
                )
                parked = true
            end

            if parked and IsVehicleStopped(currentTaxi) then
                lib.notify({
                    title = 'Taxi',
                    description = Config.Messages.ArrivedAtDestination,
                    type = 'success'
                })

                SetVehicleDoorsLocked(currentTaxi, 1)
                TaskLeaveVehicle(PlayerPedId(), currentTaxi, 0)
                Wait(Config.DespawnDelay)

                DeleteEntity(currentDriver)
                DeleteEntity(currentTaxi)
                currentTaxi = nil
                currentDriver = nil
                isInTaxi = false
                break
            end
            Wait(500)
        end
    end)
end





AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, npc in ipairs(taxiNPCs) do
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
        end
        
        if currentTaxi and DoesEntityExist(currentTaxi) then
            DeleteEntity(currentTaxi)
        end
        
        if currentDriver and DoesEntityExist(currentDriver) then
            DeleteEntity(currentDriver)
        end
    end
end)