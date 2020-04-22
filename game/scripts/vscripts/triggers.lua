function OnStartTouch(trigger)
  local activator = trigger.activator
  local caller = trigger.caller

  local lane = GetLane(activator.lane)
  local hero = lane.hero

  activator:ForceKill(false)
  activator:AddNoDraw()
  
  if IsValidAlive(hero) then
    -- Damage the hero
    EmitSoundOnClient("General.CompendiumLevelUpMinor", PlayerResource:GetPlayer(hero:GetPlayerID()))

    local damage = 1

    if IsInToolsMode() then
      damage = 0
    end

    ApplyDamage({
      victim = hero,
      attacker = activator,
      damage = damage,
      damage_type = DAMAGE_TYPE_PURE,
    })
    SendOverheadEventMessage(hero, OVERHEAD_ALERT_LAST_HIT_MISS, hero, damage, nil)
    ScreenShake(hero:GetAbsOrigin(), 5, 150, 0.25, 2000, 0, true)
  end
end