local ESX = exports['es_extended']:getSharedObject()

local hudVisible = true
local cached = {
    cash = 0,
    bank = 0,
    job = 'Unemployed',
    grade = '',
    hunger = 100,
    thirst = 100,
    id = GetPlayerServerId(PlayerId())
}

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

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
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

CreateThread(function()
    Wait(1500)
    refreshPlayerData()

    while true do
        local ped = PlayerPedId()
        local health = math.max(0, math.min(100, GetEntityHealth(ped) - 100))
        local armor = math.max(0, math.min(100, GetPedArmour(ped)))

        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            if status and status.getPercent then
                cached.hunger = math.floor(status.getPercent())
            end
        end)

        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            if status and status.getPercent then
                cached.thirst = math.floor(status.getPercent())
            end
        end)

        SendNUIMessage({
            action = 'update',
            visible = hudVisible,
            health = health,
            armor = armor,
            hunger = cached.hunger,
            thirst = cached.thirst,
            cash = cached.cash,
            bank = cached.bank,
            job = cached.job,
            grade = cached.grade,
            playerId = cached.id
        })

        Wait(500)
    end
end)

CreateThread(function()
    while true do
        refreshPlayerData()
        Wait(5000)
    end
end)

RegisterCommand('hud', function()
    hudVisible = not hudVisible
    SendNUIMessage({ action = 'visibility', visible = hudVisible })
end, false)
