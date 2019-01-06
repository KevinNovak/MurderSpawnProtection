local MSP = {}

local cfgProtectLength =
    CreateConVar(
    "msp_protect_length",
    15,
    bit.bor(FCVAR_NOTIFY),
    "How long should players be protected after the round starts?"
)

local protectLength = cfgProtectLength:GetInt()

function MSP:StartProtectingAllPlayers()
    for key, ply in pairs(player.GetAll()) do
        MSP:StartTimedProtection(ply)
    end
end

function MSP:StopProtectingAllPlayers()
    for key, ply in pairs(player.GetAll()) do
        MSP:ProtectPlayer(ply, false)
    end
end

function MSP:StartTimedProtection(ply)
    if not IsValid(ply) then
        return
    end

    MSP:ProtectPlayer(ply, true)

    timer.Simple(
        protectLength,
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
        print("Started Protecting '" .. ply:GetName() .. "' at " .. CurTime())
        ply:GodEnable()
        ply.GodEnabled = true
        ply:SetMaterial("models/wireframe")
    else
        print("Stopped Protecting '" .. ply:GetName() .. "' at " .. CurTime())
        ply:GodDisable()
        ply.GodEnabled = false
        ply:SetMaterial("")
    end
end

hook.Add(
    "OnStartRound",
    "MurderSpawnProtection",
    function()
        MSP:StartProtectingAllPlayers()
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
