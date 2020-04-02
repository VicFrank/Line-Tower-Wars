LinkLuaModifier("modifier_bursting_light", "abilities/buildings/bursting_light", LUA_MODIFIER_MOTION_NONE)

bursting_light = class({})
function bursting_light:GetIntrinsicModifierName() return "modifier_bursting_light" end

modifier_bursting_light = class({})

function modifier_bursting_light:IsHidden() return true end

function modifier_bursting_light:OnCreated()
  self.ability = self:GetAbility()

  self.num_targets = self.ability:GetSpecialValueFor("num_targets")
end

function modifier_bursting_light:DeclareFunctions()
  local decFuncs = {
    MODIFIER_EVENT_ON_ATTACK,
  }

  return decFuncs
end

function modifier_bursting_light:OnAttack(keys)
  if not IsServer() then return end
  
  -- "Secondary arrows are not released upon attacking allies."
  -- The "not keys.no_attack_cooldown" clause seems to make sure the function doesn't trigger on PerformAttacks with that false tag so this thing doesn't crash
  if keys.attacker == self:GetParent() and keys.target and 
    keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and 
    not keys.no_attack_cooldown and not self:GetParent():PassivesDisabled() and 
    self:GetAbility():IsTrained() then

    local enemies = FindUnitsInRadius(
      self:GetParent():GetTeamNumber(), 
      self:GetParent():GetAbsOrigin(), 
      nil, 
      self:GetParent():Script_GetAttackRange(), 
      DOTA_UNIT_TARGET_TEAM_ENEMY,
      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
      FIND_ANY_ORDER, false)
    
    local target_number = 0
        
    for _, enemy in ipairs(enemies) do
      if enemy ~= keys.target then        
        self:GetParent():PerformAttack(enemy, false, false, true, false, true, false, false)
        
        target_number = target_number + 1
        
        if target_number >= self.num_targets then
          break
        end
      end
    end
  end
end