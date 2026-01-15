Config = {}

-- Debug
Config.Debug = false -- true/false 

-- Target System
Config.Target = 'ox' -- ox/qb

-- Fuel System
Config.FuelSystem = 'ox_fuel' -- 'cc-fuel', 'LegacyFuel', 'ox_fuel' 



-- NPC Model
Config.NPCModel = 'a_m_y_business_01' -- NPC model taxi
Config.DriverModel = 's_m_m_cntrybar_01' -- NPC model driver

-- NPC Position TaxiNPC
Config.TaxiNPCs = {
    vector4(-1039.7371, -2731.4570, 20.2143, 196.1140) -- Los Santos Airport (x, y, z, heading)
}

-- Blip
Config.ShowBlip = false  -- true/false
Config.BlipSprite = 198 -- Sprite
Config.BlipColor = 5 -- Yellow 
Config.BlipScale = 0.6 -- Scale
Config.BlipName = "<font face='Fire Sans'>Taxi Service" -- Blip name

-- Taxi vehicle
Config.TaxiVehicle = 'taxi' -- Vehicle model

-- Destination
Config.Destinations = {
    {
        label = "LSPD Mission Row",
        coords = vector4(407.8554, -979.9058, 29.2687, 232.2409), -- x, y, z, heading
        spawnCoords = vector3(383.9413, -679.1871, 29.2720),
        spawnHeading = 267.9250
    },
    {
        label = "Central Bank",
        coords = vector4(143.1421, -1026.4192, 29.2222, 251.4734), -- x, y, z, heading
        spawnCoords = vector3(-94.6049, -1117.6069, 25.7865),
        spawnHeading = 172.8256
    },
     {
        label = "PDM",
        coords = vector4(-73.0167, -1096.8569, 26.2578, 339.7244), -- x, y, z, heading
        spawnCoords = vector3(-233.5694, -981.2352, 29.1540),
        spawnHeading = 161.2605
    },

    
}

-- Speed Driving 
Config.DrivingSpeed = 12.0 
-- Style ride 
Config.DrivingStyle = 524419 
-- DespawnDelay
Config.DespawnDelay = 3000

-- Messages
Config.Messages = {
    SpawningNPC = '^2[TAXI]^7 Spawning NPC...',
    LoadingModel = '^2[TAXI]^7 Loading model: ',
    CreatingNPCAt = '^2[TAXI]^7 Creating NPC at: ',
    NPCCreated = '^2[TAXI]^7 NPC created with ID: ',
    FailedCreateNPC = '^1[TAXI ERROR]^7 Failed to create NPC!',
    TaxiService = 'Taxi Service',
    FreeTransport = 'Free transport',
    AlreadyInTaxi = 'You are already in a taxi!',
    GoingTo = 'We are going to ',
    ArrivedAtDestination = 'We have arrived at the destination!'
}

