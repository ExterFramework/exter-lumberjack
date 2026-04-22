Config = {
    -- Auto, qbcore, qbox, esx, standalone
    Framework = 'auto',
    FrameworkFolder = {
        qbcore = 'qb-core',
        qbox = 'qbx_core',
        esx = 'es_extended'
    },

    -- Auto, qb-inventory, ox_inventory, qs-inventory, esx_inventory, standalone
    Inventory = 'auto',

    -- Auto, LegacyFuel, CDN-Fuel, ox_fuel, qb-fuel, none
    FuelSystem = 'auto',

    Debug = false,

    treeModel = 'prop_tree_cedar_02',

    Items = {
        axe = 'axe',
        log = 'log',
        cleanlog = 'cleanlog',
        rawplank = 'rawplank',
        sandedplank = 'sandedplank',
        finishwood = 'finishwood'
    },

    logPerChop = 2,
    planksPerLog = 5,

    VehCoords = vector4(-574.3195, 5368.6880, 69.7720, 248.2354),
    VehicleModel = 'bison',
    StartFuel = 100,

    woodPrice = 150,

    getClean = vector3(-552.43, 5369.49, 70.95),
    getCleaned = vector3(-574.66, 5311.73, 70.15),
    getPlanks = vector3(-510.31, 5278.65, 80.51),
    sand = vector3(-487.63, 5285.98, 80.51),
    finish = vector3(-28.13, -2659.9, 5.01),

    TreeFallThreshold = 60.0,
    ChopDurationMs = 15000,

    trees = {
        {coords = vector3(-533.0241, 5232.419, 78.04932), isFallen = false, netId = nil},
        {coords = vector3(-549.7684, 5225.637, 74.40001), isFallen = false, netId = nil},
        {coords = vector3(-610.4636, 5243.29, 70.89495), isFallen = false, netId = nil},
        {coords = vector3(-626.639, 5235.579, 73.53409), isFallen = false, netId = nil},
        {coords = vector3(-615.1752, 5191.193, 90.5518), isFallen = false, netId = nil},
        {coords = vector3(-563.9933, 5175.367, 97.60523), isFallen = false, netId = nil},
        {coords = vector3(-554.9098, 5181.466, 95.6798), isFallen = false, netId = nil},
        {coords = vector3(-572.5436, 5147.082, 105.5383), isFallen = false, netId = nil},
        {coords = vector3(-621.5879, 5147.348, 109.7678), isFallen = false, netId = nil},
        {coords = vector3(-647.5836, 5149.276, 114.0346), isFallen = false, netId = nil},
        {coords = vector3(-676.9713, 5183.662, 104.6053), isFallen = false, netId = nil},
        {coords = vector3(-679.4445, 5170.439, 107.2553), isFallen = false, netId = nil},
        {coords = vector3(-693.2548, 5198.487, 101.336), isFallen = false, netId = nil},
        {coords = vector3(-681.7182, 5217.234, 94.31977), isFallen = false, netId = nil},
        {coords = vector3(-731.4064, 5236.307, 96.71639), isFallen = false, netId = nil},
        {coords = vector3(-750.4053, 5235.176, 96.74647), isFallen = false, netId = nil}
    }
}
