function Spawn(keys)
  -- Wait one frame to do logic on a spawned unit
  Timers:CreateTimer(.1, function()
    local lane = thisEntity.lane
    thisEntity.goal = Entities:FindByName(nil, "wave_target" .. lane):GetAbsOrigin()

    -- Get all of the unit's abilities
    thisEntity.abilityList = {}
    for i=0,15 do
      local ability = thisEntity:GetAbilityByIndex(i)
      if ability and not ability:IsPassive() then
        table.insert(thisEntity.abilityList, ability)
      end
    end

    Timers:CreateTimer(function() return thisEntity:AIThink() end)
  end)
end

function thisEntity:AIThink()
  if self:IsNull() then return end
  if not self:IsAlive() then return end

  if GameRules:IsGamePaused() then
    return 0.1
  end

  if not self:CanReachGoal() then
    -- attack nearest building
    return self:AttackBuildings()
  end

  return self:MoveTowardsGoal()
end

function thisEntity:CanReachGoal()
  return GridNav:CanFindPath(self:GetAbsOrigin(), self.goal)
end

function thisEntity:AttackBuildings()
  local searchRadius = 1000
  local target_type = DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  local nearbyBuildings = FindUnitsInRadius(
    self:GetTeam(),
    self:GetAbsOrigin(),
    nil,
    searchRadius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    target_type,
    flags,
    FIND_CLOSEST,
    false)

  local building

  for _,target in ipairs(nearbyBuildings) do
    if IsCustomBuilding(target) then
      building = target
      break
    end
  end

  if not building then
    return self:MoveTowardsGoal()
  end

  self:MoveToTargetToAttack(building)

  return 0.5
end

function thisEntity:MoveTowardsGoal()
  self:MoveToPosition(self.goal)

  return 0.5
end