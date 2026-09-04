local ESX = exports['es_extended']:getSharedObject()

local hudVisible = true
local cached = {
    cash = 0,
    bank = 0,
    job = 'Unemployed',
    grade = '',
    hunger = 100,
    thirst = 100,
    stress = 0,
    id = GetPlayerServerId(PlayerId())
}

local function clamp(value, min, max)
    value = tonumber(value) or 0
    if value < min then return min end
    if value > max then return max end
    return value
end

local function getAccountMoney(name)
    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.accounts then return 0 end

    for _, account in ipairs(playerData.accounts) do
        if account.name == name then
            return account.money or 0
        end
    end

    return 0
end

local function refreshPlayerData()
    local playerData = ESX.GetPlayerData()
    cached.cash = getAccountMoney('money')
    cached.bank = getAccountMoney('bank')

    if playerData and playerData.job then
        cached.job = playerData.job.label or playerData.job.name or 'Unemployed'
        cached.grade = playerData.job.grade_label or playerData.job.grade_name or ''
    end

    cached.id = GetPlayerServerId(PlayerId())
end

local function readStatus(name, fallback)
    local value = fallback
    TriggerEvent('esx_status:getStatus', name, function(status)
        if status and status.getPercent then
            value = math.floor(status.getPercent())
        end
    end)
    return value
end

RegisterNetEvent('esx:playerLoaded', function()
    refreshPlayerData()
end)

RegisterNetEvent('esx:setJob', function(job)
    cached.job = job.label or job.name or cached.job
    cached.grade = job.grade_label or job.grade_name or ''
end)

RegisterNetEvent('esx:setAccountMoney', function(account)
    if not account or not account.name then return end
    if account.name == 'money' then cached.cash = account.money or 0 end
    if account.name == 'bank' then cached.bank = account.money or 0 end
end)

RegisterNetEvent('raku_hud:setStress', function(value)
    cached.stress = clamp(value, 0, 100)
end)

CreateThread(function()
    Wait(1500)
    refreshPlayerData()

    while true do
        local ped = PlayerPedId()
        local player = PlayerId()

        local health = clamp(GetEntityHealth(ped) - 100, 0, 100)
        local armor = clamp(GetPedArmour(ped), 0, 100)
        local stamina = clamp(GetPlayerSprintStaminaRemaining(player), 0, 100)

        local underwater = IsPedSwimmingUnderWater(ped)
        local oxygen = 100
        if underwater then
            oxygen = clamp((GetPlayerUnderwaterTimeRemaining(player) / 10.0) * 100.0, 0, 100)
        end

        cached.hunger = readStatus('hunger', cached.hunger)
        cached.thirst = readStatus('thirst', cached.thirst)
        cached.stress = readStatus('stress', cached.stress)

        local talking = NetworkIsPlayerTalking(player)
        local inVehicle = IsPedInAnyVehicle(ped, false)
        local vehicleHealth = 100
        local speed = 0

        if inVehicle then
            local vehicle = GetVehiclePedIsIn(ped, false)
            vehicleHealth = clamp(GetVehicleEngineHealth(vehicle) / 10.0, 0, 100)
            speed = math.floor(GetEntitySpeed(vehicle) * 3.6 + 0.5)
        end

        SendNUIMessage({
            action = 'update',
            visible = hudVisible,
            health = math.floor(health + 0.5),
            armor = math.floor(armor + 0.5),
            stamina = math.floor(stamina + 0.5),
            oxygen = math.floor(oxygen + 0.5),
            underwater = underwater,
            hunger = cached.hunger,
            thirst = cached.thirst,
            stress = cached.stress,
            cash = cached.cash,
            bank = cached.bank,
            job = cached.job,
            grade = cached.grade,
            playerId = cached.id,
            talking = talking,
            inVehicle = inVehicle,
            vehicleHealth = math.floor(vehicleHealth + 0.5),
            speed = speed
        })

        Wait(200)
    end
end)

CreateThread(function()
    while true do
        refreshPlayerData()
        Wait(4000)
    end
end)

CreateThread(function()
    while true do
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(13)
        HideHudComponentThisFrame(20)
        Wait(0)
    end
end)

RegisterCommand('hud', function()
    hudVisible = not hudVisible
    SendNUIMessage({ action = 'visibility', visible = hudVisible })
end, false)
