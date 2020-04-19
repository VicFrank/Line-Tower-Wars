LinkLuaModifier("modifier_ice_barrage", "abilities/buildings/ice_barrage", LUA_MODIFIER_MOTION_NONE)

ice_barrage = class({})
function ice_barrage:GetIntrinsicModifierName() return "modifier_ice_barrage" end

modifier_ice_barrage = class({})

function modifier_ice_barrage:IsHidden() return true end

function modifier_ice_barrage:OnCreated()
  self.ability = self:GetAbility()

  self.num_targets = self.ability:GetSpecialValueFor("num_targets")
  self.chance = self.ability:GetSpecialValueFor("chance")
  self.bonus_damage_percent = self.ability:GetSpecialValueFor("bonus_damage_percent")
  self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
end

function modifier_ice_barrage:DeclareFunctions()
  local decFuncs = {
    MODIFIER_EVENT_ON_ATTACK,
  }

  return decFuncs
end

function modifier_ice_barrage:OnAttack(keys)
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

    if RollPercentage(self.chance) then
      ApplyDamage({
        victim = keys.target,
        attacker = self:GetParent(),
        damage = keys.damage * self.bonus_damage_percent / 100,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility()
      })

      target:AddNewModifier(
        self:GetParent(),
        self:GetAbility(),
        "modifier_stunned",
        {duration = self.stun_duration}
      )

      target:EmitSound("Hero_Ancient_Apparition.ColdFeetTick")
    end
  end
end