LinkLuaModifier("modifier_deadly_strike", "abilities/buildings/deadly_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_deadly_strike_debuff", "abilities/buildings/deadly_strike.lua", LUA_MODIFIER_MOTION_NONE)

deadly_strike = class({})
function deadly_strike:GetIntrinsicModifierName() return "modifier_deadly_strike" end

modifier_deadly_strike = class({})

function modifier_deadly_strike:IsHidden() return true end

function modifier_deadly_strike:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
  self.chance = self.ability:GetSpecialValueFor("chance")
  self.bonus_damage_percent = self.ability:GetSpecialValueFor("bonus_damage_percent")
end

function modifier_deadly_strike:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
  }
  return funcs
end

function modifier_deadly_strike:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    target:AddNewModifier(attacker, self.ability, "modifier_deadly_strike_debuff",{duration = self.duration})
  end
end

function modifier_deadly_strike:GetModifierPreAttack_CriticalStrike(keys)
  if RollPercentage(self.chance) then
    return self.bonus_damage_percent
  else
    return nil
  end
end

---------------------

modifier_deadly_strike_debuff = class({})

function modifier_deadly_strike_debuff:IsDebuff() return true end

function modifier_deadly_strike_debuff:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.slow = self.ability:GetSpecialValueFor("slow")
  self.dps = self.ability:GetSpecialValueFor("dps")

  self:StartIntervalThink(1)
  self:DamageTick()
end

function modifier_deadly_strike_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end

function modifier_deadly_strike_debuff:DamageTick()
  if IsServer() then

    local final_damage = ApplyDamage({
      attacker = self:GetCaster(),
      victim = self.parent,
      ability = self.ability,
      damage = self.dps,
      damage_type = DAMAGE_TYPE_MAGICAL,
      damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
    })
    
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self.parent, final_damage, nil)
  end
end

function modifier_deadly_strike_debuff:GetModifierMoveSpeedBonus_Percentage()
  return -self.slow
end

function modifier_deadly_strike_debuff:GetModifierAttackSpeedBonus_Constant()
  return -self.slow
end

function modifier_deadly_strike_debuff:OnIntervalThink()
  self:DamageTick()
end

function modifier_deadly_strike_debuff:GetEffectName()
  return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff.vpcf"
end

function modifier_deadly_strike_debuff:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end