function GameMode:FilterDamage(filterTable)
  -- for k, v in pairs( filterTable ) do
  --  print("Damage: " .. k .. " " .. tostring(v) )
  -- end

  local victim_index = filterTable["entindex_victim_const"]
  local attacker_index = filterTable["entindex_attacker_const"]
  if not victim_index or not attacker_index then
    return true
  end

  local victim = EntIndexToHScript( victim_index )
  local attacker = EntIndexToHScript( attacker_index )
  local damagetype = filterTable["damagetype_const"]
  local inflictor = filterTable["entindex_inflictor_const"]

  local value = filterTable["damage"] --Post reduction
  local damage, reduction = GameMode:GetPreMitigationDamage(value, victim, attacker, damagetype) --Pre reduction

  -- Physical attack damage filtering
  if damagetype == DAMAGE_TYPE_PHYSICAL then
    if victim == attacker and not inflictor then return end -- Self attack, for fake attack ground

    if attacker:HasSplashAttack() and not inflictor then
      SplashAttackUnit(attacker, victim:GetAbsOrigin())
      return false
    end

    -- Apply custom armor reduction
    local attack_damage = damage
    local attack_type  = attacker:GetAttackType()
    local armor_type = victim:GetArmorType()
    local multiplier = attacker:GetAttackFactorAgainstTarget(victim)
    local armor = victim:GetPhysicalArmorValue(false)
    local wc3Reduction = (armor * 0.06) / (1 + (armor * 0.06))

    damage = (attack_damage * (1 - wc3Reduction)) * multiplier
    damage = math.max(damage, 1)

    -- print(string.format("Damage (%s attack vs %.f %s armor): (%.f * %.2f) * %.2f = %.f", attack_type, armor, armor_type, attack_damage, 1-wc3Reduction, multiplier, damage))

    -- Reassign the new damage
    filterTable["damage"] = damage
  end

  return true
end

function GameMode:GetPreMitigationDamage(value, victim, attacker, damagetype)
  if damagetype == DAMAGE_TYPE_PHYSICAL then
    local armor = victim:GetPhysicalArmorValue(false)
    -- 1 - ((0.052 × armor) ÷ (0.9 + 0.048 × |armor|))
    local reduction = ((0.052 * armor) / (0.9 + 0.048 * math.abs(armor)))
    local damage = value / (1 - reduction)

    return damage, reduction

  elseif damagetype == DAMAGE_TYPE_MAGICAL then
    local reduction = victim:GetMagicalArmorValue() * 0.01
    local damage = value / (1 - reduction)

    return damage, reduction
  else
    return value, 0
  end
end

-- Deals damage based on the attacker around a position, with full/medium/small factors based on distance from the impact
function SplashAttackGround(attacker, position)
  SplashAttackUnit(attacker, position)
  
  -- Hit ground particle. This could be each particle endcap instead
  local hit = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnus_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, attacker)
  ParticleManager:SetParticleControl(hit, 0, position)
end

function SplashAttackUnit(attacker, position)
  local full_damage_radius = attacker:GetSplashRadius()

  local medium_damage_radius = full_damage_radius / 2
  local small_damage_radius = full_damage_radius / 6

  local full_damage = attacker:GetAttackDamage()
  local medium_damage = full_damage * 0.4 or 0
  local small_damage = full_damage * 0.25 or 0
  medium_damage = medium_damage + small_damage -- Small damage gets added to the mid aoe

  local splash_targets = FindAllUnitsAroundPoint(attacker, position, small_damage_radius)
  if DEBUG then
    DebugDrawCircle(position, Vector(255,0,0), 50, full_damage_radius, true, 3)
    DebugDrawCircle(position, Vector(255,0,0), 50, medium_damage_radius, true, 3)
    DebugDrawCircle(position, Vector(255,0,0), 50, small_damage_radius, true, 3)
  end

  local canHitFlying = true
  if attacker:GetKeyValue("AttacksDisallowed") == "flying" then
    canHitFlying = false
  end

  for _,unit in pairs(splash_targets) do
    local isValidTarget = true

    if not canHitFlying and unit:HasFlyMovementCapability() then
      isValidTarget = false
    end

    if unit:GetTeam() == attacker:GetTeam() then
      isValidTarget = false
    end
    
    if isValidTarget then
      local distance_from_impact = (unit:GetAbsOrigin() - position):Length2D()
      if distance_from_impact <= full_damage_radius then
        ApplyDamage({ victim = unit, attacker = attacker, damage = full_damage, ability = GameRules.Applier, damage_type = DAMAGE_TYPE_PHYSICAL})
      elseif distance_from_impact <= medium_damage_radius then
        ApplyDamage({ victim = unit, attacker = attacker, damage = medium_damage, ability = GameRules.Applier, damage_type = DAMAGE_TYPE_PHYSICAL})
      else
        ApplyDamage({ victim = unit, attacker = attacker, damage = small_damage, ability = GameRules.Applier, damage_type = DAMAGE_TYPE_PHYSICAL})
      end
    end
  end
end