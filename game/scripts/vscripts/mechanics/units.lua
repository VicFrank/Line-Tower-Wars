if not Units then
  Units = class({})
end

-- Initializes one unit with all its required modifiers and functions
function Units:Init( unit )
  if unit.bFirstSpawned and not unit:IsRealHero() then return
  else unit.bFirstSpawned = true end

  if unit:IsRealHero() then
    ApplyModifier(unit, "builder_invulnerable_modifier")
  end

  -- Apply armor and damage modifier (for visuals)
  local attack_type = unit:GetAttackType()
  if attack_type and unit:GetAttackDamage() > 0 then
    ApplyModifier(unit, "modifier_attack_"..attack_type)
  end

  local armor_type = unit:GetArmorType()
  if armor_type then
    ApplyModifier(unit, "modifier_armor_"..armor_type)
    if armor_type == "divine" then
      unit:SetBaseMagicalResistanceValue(75)
    elseif armor_type == "hero" then
      unit:SetBaseMagicalResistanceValue(60)
    end
  end

  local attacks_enabled = unit:GetAttacksEnabled()
  if attacks_enabled ~= "none" then
    unit:AddNewModifier(unit, nil, "modifier_autoattack", {})
  end

  local bBuilding = IsCustomBuilding(unit)

  ApplyMaterialGroup(unit)

  -- Adjust Hull
  unit:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
  local collision_size = unit:GetCollisionSize()
  if not bBuilding and collision_size then
    unit:SetHullRadius(collision_size)
  end
end

function ApplyModifier(unit, modifier_name)
  GameRules.Applier:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end

MATERIAL_GROUPS = {
  ["ward_tower"] = "1",
  ["ultimate_ward_tower"] = "1",
}

function ApplyMaterialGroup(unit)
  local materialGroup = MATERIAL_GROUPS[unit:GetUnitName()]
  if materialGroup then
    unit:SetMaterialGroup(materialGroup)
  end
end

HULL_SIZES = {
  ["DOTA_HULL_SIZE_BARRACKS"]=144,
  ["DOTA_HULL_SIZE_BUILDING"]=81,
  ["DOTA_HULL_SIZE_FILLER"]=96,
  ["DOTA_HULL_SIZE_HERO"]=24,
  ["DOTA_HULL_SIZE_HUGE"]=80,
  ["DOTA_HULL_SIZE_REGULAR"]=16,
  ["DOTA_HULL_SIZE_SIEGE"]=16,
  ["DOTA_HULL_SIZE_SMALL"]=8,
  ["DOTA_HULL_SIZE_TOWER"]=144,
}

function CDOTA_BaseNPC:GetCollisionSize()
  local collision_size = self:GetKeyValue("CollisionSize")
  return collision_size
end

function GetOriginalModelScale( unit )
  return GameRules.UnitKV[unit:GetUnitName()]["ModelScale"] or unit:GetModelScale()
end

function SetRangedProjectileName( unit, pProjectileName )
  unit:SetRangedProjectileName(pProjectileName)
  unit.projectileName = pProjectileName
end

function GetOriginalRangedProjectileName( unit )
  return unit:GetKeyValue("ProjectileModel") or ""
end

function GetRangedProjectileName( unit )
  return unit.projectileName or unit:GetKeyValue("ProjectileModel") or ""
end

function IsCustomBuilding(unit)
  return unit:HasModifier("modifier_building")
end

function CDOTA_BaseNPC:IsFlyingUnit()
  return self:GetKeyValue("MovementCapabilities") == "DOTA_UNIT_CAP_MOVE_FLY"
end

-- Shortcut for a very common check
function IsValidAlive( unit )
  return (IsValidEntity(unit) and unit:IsAlive())
end

-- Auxiliar function that goes through every ability and item, checking for any ability being channelled
function IsChanneling ( unit )
  for abilitySlot=0,15 do
    local ability = unit:GetAbilityByIndex(abilitySlot)
    if ability and ability:IsChanneling() then 
      return ability
    end
  end

  for itemSlot=0,5 do
    local item = unit:GetItemInSlot(itemSlot)
    if item and item:IsChanneling() then
      return ability
    end
  end

  return false
end

-- Returns all visible enemies in radius of the unit/point
function FindEnemiesInRadius( unit, radius, point )
  local team = unit:GetTeamNumber()
  local position = point or unit:GetAbsOrigin()
  local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
  return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, target_type, flags, FIND_CLOSEST, false)
end

-- Includes enemies that aren't visible
function FindAllEnemiesInRadius( unit, radius, point )
  local team = unit:GetTeamNumber()
  local position = point or unit:GetAbsOrigin()
  local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, target_type, flags, FIND_CLOSEST, false)
end

-- Returns all units (friendly and enemy) in radius of the unit/point
function FindAllUnitsInRadius( radius, point )
  local position = point
  local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  return FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, target_type, flags, FIND_ANY_ORDER, false)
end

function FindAllUnits()
  local position = Vector(0,0,0)
  local target_type = DOTA_UNIT_TARGET_ALL
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
  return FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, target_type, flags, FIND_ANY_ORDER, false)
end

function FindAllVisibleUnitsInRadius( team, radius, point )
  local position = point
  local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
  return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, target_type, flags, FIND_ANY_ORDER, false)
end

-- Returns all units in radius of a point
function FindAllUnitsAroundPoint( unit, point, radius )
  local team = unit:GetTeamNumber()
  local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  return FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, target_type, flags, FIND_ANY_ORDER, false)
end

function FindAlliesInRadius( unit, radius, point )
  local team = unit:GetTeamNumber()
  local position = point or unit:GetAbsOrigin()
  local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
  local flags = DOTA_UNIT_TARGET_FLAG_NONE
  return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, target_type, flags, FIND_ANY_ORDER, false)
end

-- Returns the first unit that passes the filter
function FindFirstUnit(list, filter)
  for _,unit in ipairs(list) do
    if filter(unit) then
      return unit
    end
  end
end

function ReplaceUnit( unit, new_unit_name )
  --print("Replacing "..unit:GetUnitName().." with "..new_unit_name)

  local hero = unit:GetOwner()
  local playerID = hero:GetPlayerOwnerID()

  local position = unit:GetAbsOrigin()
  local relative_health = unit:GetHealthPercent() * 0.01
  local fv = unit:GetForwardVector()
  local new_unit = CreateUnitByName(new_unit_name, position, true, hero, hero, hero:GetTeamNumber())
  new_unit:SetOwner(hero)
  new_unit:SetControllableByPlayer(playerID, true)
  new_unit:SetHealth(new_unit:GetMaxHealth() * relative_health)
  new_unit:SetForwardVector(fv)
  FindClearSpaceForUnit(new_unit, position, true)

  if PlayerResource:IsUnitSelected(playerID, unit) then
    PlayerResource:AddToSelection(playerID, new_unit)
  end

  -- Add the new unit to the player units
  Players:AddUnit(playerID, new_unit)

  -- Remove replaced unit from the game
  Players:RemoveUnit(playerID, unit)
  unit:CustomRemoveSelf()

  return new_unit
end

function IsAlliedUnit( unit, target )
  return (unit:GetTeamNumber() == target:GetTeamNumber())
end

function CDOTA_BaseNPC:HasDeathAnimation()
  return self:GetKeyValue("HasDeathAnimation")
end

function CDOTA_BaseNPC:IsDummy()
  return self:GetUnitName():match("dummy_") or self:GetUnitLabel():match("dummy")
end

function CDOTA_BaseNPC:HasSplashAttack()
  return self:GetKeyValue("SplashRadius")
end

function CDOTA_BaseNPC:GetSplashRadius()
  local splashRadius = self:GetKeyValue("SplashRadius") or 0
  if self:HasModifier("modifier_unholy_miasma") then
    splashRadius = self:GetModifierStackCount("modifier_unholy_miasma", self)
  end
  return splashRadius
end

-- All units should have DOTA_COMBAT_CLASS_ATTACK_HERO and DOTA_COMBAT_CLASS_DEFEND_HERO, or no CombatClassAttack/ArmorType defined
-- Returns a string with the wc3 damage name
function CDOTA_BaseNPC:GetAttackType()
  return self.AttackType or self:GetKeyValue("AttackType")
end

-- Returns a string with the wc3 armor name
function CDOTA_BaseNPC:GetArmorType()
  return self.ArmorType or self:GetKeyValue("ArmorType")
end

-- Changes the AttackType and current visual tooltip of the unit
function CDOTA_BaseNPC:SetAttackType( attack_type )
  local current_attack_type = self:GetAttackType()
  self:RemoveModifierByName("modifier_attack_"..current_attack_type)
  self.AttackType = attack_type
  ApplyModifier(self, "modifier_attack_"..attack_type)
end

-- Changes the ArmorType and current visual tooltip of the unit
function CDOTA_BaseNPC:SetArmorType( armor_type )
  local current_armor_type = self:GetArmorType()
  self:RemoveModifierByName("modifier_armor_"..current_armor_type)
  self.ArmorType = armor_type
  ApplyModifier(self, "modifier_armor_"..armor_type)
end

-- Returns the damage factor this unit does against another
function CDOTA_BaseNPC:GetAttackFactorAgainstTarget( unit )
  local attack_type = self:GetAttackType()
  local armor_type = unit:GetArmorType()
  local damageTable = GameRules.Damage
  return damageTable[attack_type] and damageTable[attack_type][armor_type] or 1
end

function CDOTA_BaseNPC:IsMechanical()
  return self:GetUnitLabel():match("mechanical")
end

function CDOTA_BaseNPC:CanAttackTarget(target)
  if not target.IsCreature then return true end -- filter item drops

  local attacks_enabled = self:GetAttacksEnabled()
  local target_type = GetMovementCapability(target)

  if not self:HasAttackCapability() or self:IsDisarmed() or target:IsInvulnerable()
    or target:IsAttackImmune() or not self:CanEntityBeSeenByMyTeam(target)
    or (self:GetAttackType() == "magic" and target:IsMagicImmune() and not IsCustomBuilding(target)) then
      return false
  end

  -- Buildings are special ground unit targets
  if attacks_enabled:match("building") and target_type == "ground" then
    return IsCustomBuilding(target)
  end

  return string.match(attacks_enabled, target_type)
end

function GetMovementCapability(unit)
  return unit:HasFlyMovementCapability() and "air" or "ground"
end

-- Default by omission is "none", other possible returns should be "ground,air" or "air"
function CDOTA_BaseNPC:GetAttacksEnabled()
    return self.attacksEnabled or self:GetKeyValue("AttacksEnabled") or "none"
end

-- MODIFIER_PROPERTY_HEALTH_BONUS doesn't work on npc_dota_creature
function CDOTA_BaseNPC_Creature:IncreaseMaxHealth(bonus)
  local newHP = self:GetMaxHealth() + bonus
  local relativeHP = self:GetHealthPercent() * 0.01
  if relativeHP == 0 then return end
  self:SetMaxHealth(newHP)
  self:SetBaseMaxHealth(newHP)
  self:SetHealth(newHP * relativeHP)
end