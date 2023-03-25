--[[
    HitTracker v0.2.1
    Author:
        Museus (Discord: Museus#7777)

    Track Hits and Damage taken per chamber, per biome, and per run.
    Customizable grace period after each hit.
]]
ModUtil.Mod.Register("HitTracker")

local config = {
    Enabled = true, -- If false, mod does nothing
    TrackHits = true, -- If true, log all hits taken
    TrackDamage = true, -- If true, log all damage taken
    DisplayBiomes = false, -- If true, display per-biome breakdown
    BlocksSeparate = true, -- If true, add a separate line for blocks
    GracePeriodDuration = 1, -- Duration in seconds to ignore consecutive hits
}
HitTracker.config = config
HitTracker.config.TrackHits = HitTracker.config.Enabled and HitTracker.config.TrackHits
HitTracker.config.TrackDamage = HitTracker.config.Enabled and HitTracker.config.TrackDamage

function HitTracker.Log( text )
    DebugPrint({ Text = "[HitTracker] " .. text })
end

function string.starts( target_string, starting_substring )
    return string.sub( target_string, 1, string.len(starting_substring) ) == starting_substring
end

function HitTracker.InitializeTracker()
    HitTracker.Hits = {
        Depth = {},
        Biome = {},
        Total = 0,
    }
    HitTracker.Blocks = {
        Depth = {},
        Biome = {},
        Total = 0,
    }
    HitTracker.Damage = {
        Depth = {},
        Biome = {},
        Total = 0,
    }
    HitTracker.InGracePeriod = false

    -- If we start mid-run, don't want to crash
    local startingDepth = GetRunDepth( CurrentRun )
    local startingBiome = CurrentRun.CurrentRoom.RoomSetName
    HitTracker.InitializeDepth( startingDepth )
    HitTracker.InitializeBiome( startingBiome )

    HitTracker.Initialized = true
end

function HitTracker.InitializeDepth( depth )
    if HitTracker.Hits.Depth[depth] == nil then
        HitTracker.Hits.Depth[depth] = {}
    end

    if HitTracker.Blocks.Depth[depth] == nil then
        HitTracker.Blocks.Depth[depth] = {}
    end

    if HitTracker.Damage.Depth[depth] == nil then
        HitTracker.Damage.Depth[depth] = {}
        HitTracker.Damage.Depth[depth].Total = 0
    end
end

function HitTracker.InitializeBiome( biome )
    if HitTracker.Hits.Biome[biome] == nil then
        HitTracker.Hits.Biome[biome] = {}
    end

    if HitTracker.Blocks.Biome[biome] == nil then
        HitTracker.Blocks.Biome[biome] = {}
    end

    if HitTracker.Damage.Biome[biome] == nil then
        HitTracker.Damage.Biome[biome] = {}
        HitTracker.Damage.Biome[biome].Total = 0
    end
end

function HitTracker.StartGracePeriod( duration )
    HitTracker.InGracePeriod = true
    HitTracker.GracePeriodEnd = GetTime({ }) + HitTracker.config.GracePeriodDuration

    while GetTime({ }) < HitTracker.GracePeriodEnd do
        wait(0.016)
    end

    HitTracker.InGracePeriod = false
end

function HitTracker.ProcessHit( attacker, damage, blocked )
    if not HitTracker.config.TrackHits then
        return
    end

    if HitTracker.InGracePeriod then
        return
    end

    -- Don't count walking on lava without taking damage
    if (string.starts(attacker, "Lava") or string.starts(attacker, "EliteLava")) and damage == 0 then
        HitTracker.Log( "Ignoring 0 damage lava hit." )
        return
    end

    if string.starts(attacker, "GasTrap") and damage == 0 then
        HitTracker.Log( "Ignoring gas trap." )
        return
    end

    for invulnerabilityFlag, isFlagActive in pairs(CurrentRun.Hero.InvulnerableFlags) do
        if isFlagActive and isFlagActive ~= "ShieldFireSelfInvulnerable" then
            HitTracker.Log( "Ignoring hit while invulnerability flag " .. invulnerabilityFlag .. " is set." )
            return
        end
    end

    if HitTracker.config.GracePeriodDuration > 0 then
        thread(HitTracker.StartGracePeriod)
    end

    local depth = GetRunDepth( CurrentRun )
    local biomeName = CurrentRun.CurrentRoom.RoomSetName
    local hitEntry = {
        Attacker = attacker,
        Damage = damage
    }

    if HitTracker.Hits.Depth[depth] == nil then
        HitTracker.InitializeDepth( depth )
    end

    if HitTracker.Hits.Biome[biomeName] == nil then
        HitTracker.InitializeBiome( biomeName )
    end

    table.insert(HitTracker.Hits.Depth[depth], hitEntry)
    table.insert(HitTracker.Hits.Biome[biomeName], hitEntry)
    HitTracker.Hits.Total = HitTracker.Hits.Total + 1

    if blocked then
        table.insert(HitTracker.Blocks.Depth[depth], hitEntry)
        table.insert(HitTracker.Blocks.Biome[biomeName], hitEntry)
        HitTracker.Blocks.Total = HitTracker.Blocks.Total + 1
    end

    HitTracker.Display()
    HitTracker.Log("Tracked hit for " .. damage .. " damage (pre-modifiers) by " .. attacker)
end

function HitTracker.ProcessDamage( attacker, damage )
    if not HitTracker.config.TrackDamage then
        return
    end

    local depth = GetRunDepth( CurrentRun )
    local biomeName = CurrentRun.CurrentRoom.RoomSetName
    if attacker == nil then
        attacker = "Unknown (Probably Chaos)"
    end

    local damageEntry = {
        Attacker = attacker,
        Damage = damage
    }

    if HitTracker.Damage.Depth[depth] == nil then
        HitTracker.InitializeDepth( depth )
    end

    if HitTracker.Damage.Biome[biomeName] == nil then
        HitTracker.InitializeBiome( biomeName )
    end

    table.insert(HitTracker.Damage.Depth[depth], damageEntry)
    table.insert(HitTracker.Damage.Biome[biomeName], damageEntry)

    HitTracker.Damage.Biome[biomeName].Total = HitTracker.Damage.Biome[biomeName].Total + damage
    HitTracker.Damage.Total = HitTracker.Damage.Total + damage

    HitTracker.Display()
    HitTracker.Log("Tracked " .. damage .. " damage (post-modifiers) from " .. attacker)
end

function HitTracker.Display()
    if not (HitTracker.config.TrackHits or HitTracker.config.TrackDamage) then
        return
    end

    local y_pos = 90
    if RtaTimer ~= nil and RtaTimer.Running then
        y_pos = y_pos + UIData.CurrentRunDepth.TextFormat.FontSize + 5
    end

    local depth = GetRunDepth( CurrentRun )
    local biomeName = CurrentRun.CurrentRoom.RoomSetName

    if HitTracker.Hits.Depth[depth] == nil then
        HitTracker.InitializeDepth( depth )
    end
    if HitTracker.Hits.Biome[biomeName] == nil then
        HitTracker.InitializeBiome( biomeName )
    end

    if HitTracker.config.TrackHits and HitTracker.config.DisplayBiomes then
        local hitsInBiome = #HitTracker.Hits.Biome[biomeName]
        PrintUtil.createOverlayLine(
            "HitTracker_HitsBiome",
            "Hits in " .. biomeName .. ": " .. hitsInBiome,
            MergeTables(
                UIData.CurrentRunDepth.TextFormat,
                {
                    justification = "right",
                    x_pos = 1903,
                    y_pos = y_pos,
                }
            )
        )

        y_pos = y_pos + UIData.CurrentRunDepth.TextFormat.FontSize + 5
    end

    if HitTracker.config.TrackHits and HitTracker.config.BlocksSeparate and HitTracker.config.DisplayBiomes then
        local blocksInBiome = #HitTracker.Blocks.Biome[biomeName]
        PrintUtil.createOverlayLine(
            "HitTracker_BlocksBiome",
            "Hits Blocked in " .. biomeName .. ": " .. blocksInBiome,
            MergeTables(
                UIData.CurrentRunDepth.TextFormat,
                {
                    justification = "right",
                    x_pos = 1903,
                    y_pos = y_pos,
                }
            )
        )

        y_pos = y_pos + UIData.CurrentRunDepth.TextFormat.FontSize + 5
    end

    if HitTracker.config.TrackDamage and HitTracker.config.DisplayBiomes then
        local damageInBiome = HitTracker.Damage.Biome[biomeName].Total
        PrintUtil.createOverlayLine(
            "HitTracker_DamageBiome",
            "Damage in " .. biomeName .. ": " .. damageInBiome,
            MergeTables(
                UIData.CurrentRunDepth.TextFormat,
                {
                    justification = "right",
                    x_pos = 1903,
                    y_pos = y_pos,
                }
            )
        )

        y_pos = y_pos + UIData.CurrentRunDepth.TextFormat.FontSize + 5
    end

    if HitTracker.config.TrackHits then
        PrintUtil.createOverlayLine(
            "HitTracker_HitsTotal",
            "Total Hits: " .. HitTracker.Hits.Total,
            MergeTables(
                UIData.CurrentRunDepth.TextFormat,
                {
                    justification = "right",
                    x_pos = 1903,
                    y_pos = y_pos,
                }
            )
        )

        y_pos = y_pos + UIData.CurrentRunDepth.TextFormat.FontSize + 5
    end

    if HitTracker.config.TrackHits and HitTracker.config.BlocksSeparate then
        PrintUtil.createOverlayLine(
            "HitTracker_BlocksTotal",
            "Total Blocks: " .. HitTracker.Blocks.Total,
            MergeTables(
                UIData.CurrentRunDepth.TextFormat,
                {
                    justification = "right",
                    x_pos = 1903,
                    y_pos = y_pos,
                }
            )
        )

        y_pos = y_pos + UIData.CurrentRunDepth.TextFormat.FontSize + 5
    end

    if HitTracker.config.TrackDamage then
        PrintUtil.createOverlayLine(
            "HitTracker_DamageTotal",
            "Total Damage: " .. HitTracker.Damage.Total,
            MergeTables(
                UIData.CurrentRunDepth.TextFormat,
                {
                    justification = "right",
                    x_pos = 1903,
                    y_pos = y_pos,
                }
            )
        )
    end
end

ModUtil.Path.Wrap("WindowDropEntrance", function( baseFunc, ... )
    local val = baseFunc(...)

    if HitTracker ~= nil and (HitTracker.config.TrackHits or HitTracker.config.TrackDamage) then
        HitTracker.InitializeTracker()
        HitTracker.Display()
    end

    return val
end, HitTracker)

-- Scripts/RoomManager.lua : 1874
ModUtil.Path.Wrap("StartRoom", function ( baseFunc, currentRun, currentRoom )
    DebugPrint({ Text = "Starting room." })
    if HitTracker ~= nil and (HitTracker.config.TrackHits or HitTracker.config.TrackDamage) then
        if not HitTracker.Initialized then
            HitTracker.InitializeTracker()
        end

        HitTracker.Display()
    end

    baseFunc(currentRun, currentRoom)
end, HitTracker)

-- Scripts/UIScripts.lua : 145
ModUtil.Path.Wrap("ShowCombatUI", function ( baseFunc, flag )
    if HitTracker ~= nil and (HitTracker.config.TrackHits or HitTracker.config.TrackDamage) then
        if not HitTracker.Initialized then
            HitTracker.InitializeTracker()
        end

        HitTracker.Display()
    end

    baseFunc(flag)
end, HitTracker)

OnHit{
    function( triggerArgs )
        local victim = triggerArgs.TriggeredByTable
        if victim ~= nil and victim == CurrentRun.Hero then
            local attackerName = triggerArgs.AttackerName
            local damageAmount = triggerArgs.DamageAmount
            HitTracker.ProcessHit( attackerName, damageAmount, false )
        end
    end
}

OnWeaponFired{
    function( triggerArgs )
        -- chaos curse effects
        if triggerArgs.OwnerTable == CurrentRun.Hero and not CurrentRun.Hero.Frozen then
            for i, data in pairs(GetHeroTraitValues("DamageOnFireWeapons")) do
                if Contains( data.WeaponNames, triggerArgs.name ) then
                    HitTracker.ProcessHit( "Chaos Curse (" .. triggerArgs.name .. ")", data.Damage, false )
                end
            end
        end
    end
}

OnProjectileBlock{
    function( triggerArgs )
        if triggerArgs.triggeredById == CurrentRun.Hero.ObjectId and triggerArgs.WeaponName == "ShieldWeaponRush" then
            HitTracker.ProcessHit( triggerArgs.WeaponName, 0, true )
        end
    end
}

OnProjectileReflect{
    function( triggerArgs )
        for i, weaponNames in pairs(GetHeroTraitValues("OnProjectileReflectWeapons")) do
            for s, weaponName in pairs(weaponNames) do
                local targetId = triggerArgs.AttackerId or CurrentRun.Hero.ObjectId
            end
        end
    end
}


OnProjectileDeath{
    function( triggerArgs )
        if triggerArgs.IsDeflected then
            HitTracker.ProcessHit( "Deflected " .. triggerArgs.WeaponName, 0, false )
        end
    end
}

-- Scripts/Combat.lua : 723
ModUtil.Path.Wrap("DamageHero", function ( baseFunc, victim, triggerArgs )
    HitTracker.ProcessDamage( triggerArgs.AttackerName, triggerArgs.DamageAmount)
    baseFunc( victim, triggerArgs )
end, HitTracker)
