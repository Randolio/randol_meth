QBCore = exports['qb-core']:GetCoreObject()

Config = {
    ProductionInterval = 45000, -- 45 seconds between each minigame cycle.
    UseOxRadial = true, -- if false, will call for qb-radialmenu
    Minigames = { -- percentage based and rounded to the nearest threshold.
        [0] = { circles = 2, speed = 50, },
        [10] = { circles = 3, speed = 50, },
        [20] = { circles = 4, speed = 60, },
        [30] = { circles = 4, speed = 60, },
        [40] = { circles = 5, speed = 60, },
        [50] = { circles = 5, speed = 60, },
        [60] = { circles = 6, speed = 65, },
        [70] = { circles = 6, speed = 65, },
        [80] = { circles = 7, speed = 70, },
        [90] = { circles = 7, speed = 80, },
    },
    AllowedVehicles = {
        '60vwbus',
        'journey',
        'journey2',
        -- Add more vehicle models here, if necessary
    },
}
