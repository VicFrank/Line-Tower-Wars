function OnStartTouch(trigger)
  local activator = trigger.activator
  local caller = trigger.caller

  activator:ForceKill(false)
  activator:AddNoDraw()

  local lane = activator.lane
  
  if hero and hero:IsAlive() then
    EmitSoundOnClient("General.CompendiumLevelUpMinor", PlayerResource:GetPlayer(hero:GetPlayerID()))

    local damage = 1

    ApplyDamage({
      victim = hero,
      attacker = activator,
      damage = damage,
      damage_type = DAMAGE_TYPE_PURE,
    })
    SendOverheadEventMessage(hero, OVERHEAD_ALERT_LAST_HIT_MISS, hero, damage, nil)
  end
  
end