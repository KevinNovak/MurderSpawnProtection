local MSP = {}

local cfgProtectLength =
    CreateConVar(
    "msp_protect_length",
    15,
    bit.bor(FCVAR_NOTIFY),
    "How long should players be protected after the round starts?"
)

local protectLength = cfgProtectLength:GetInt()

-- How long before players become unfrozen
local frozenTime = 10

function MSP:StartProtectingAllPlayers(time)
    for key, ply in pairs(player.GetAll()) do
        MSP:StartTimedProtection(ply, time)
    end
end

function MSP:StopProtectingAllPlayers()
    for key, ply in pairs(player.GetAll()) do
        MSP:ProtectPlayer(ply, false)
    end
end

function MSP:StartTimedProtection(ply, time)
    if not IsValid(ply) then
        return
    end

    MSP:ProtectPlayer(ply, true)

    timer.Simple(
        time,
        function()
            MSP:ProtectPlayer(ply, false)
        end
    )
end

function MSP:ProtectPlayer(ply, protect)
    if not IsValid(ply) then
        return
    end

    if protect then
        ply:GodEnable()
        ply.GodEnabled = true
        ply:SetMaterial("models/wireframe")
    else
        ply:GodDisable()
        ply.GodEnabled = false
        ply:SetMaterial("")
    end
end

hook.Add(
    "OnStartRound",
    "MurderSpawnProtection",
    function()
        local time = frozenTime + protectLength
        MSP:StartProtectingAllPlayers(time)
    end
)

hook.Add(
    "OnEndRound",
    "MurderSpawnProtection",
    function()
        MSP:StopProtectingAllPlayers()
    end
)

hook.Add(
    "PlayerDisconnected",
    "MurderSpawnProtection",
    function(ply)
        MSP:ProtectPlayer(ply, false)
    end
)

hook.Add(
    "EntityTakeDamage",
    "MurderSpawnProtection",
    function(target, damageInfo)
        if damageInfo:GetAttacker().GodEnabled then
            damageInfo:ScaleDamage(0)
        end
    end
)
