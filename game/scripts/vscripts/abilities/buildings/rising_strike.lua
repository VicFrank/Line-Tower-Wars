LinkLuaModifier("modifier_rising_strike", "abilities/buildings/rising_strike.lua", LUA_MODIFIER_MOTION_NONE)

rising_strike = class({})
function rising_strike:GetIntrinsicModifierName() return "modifier_rising_strike" end

-----------------------------

modifier_rising_strike = class({})

function modifier_rising_strike:IsHidden() return true end

function modifier_rising_strike:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.attack_rate_drop = self.ability:GetSpecialValueFor("attack_rate_drop")

  self:SetStackCount(0)
end

function modifier_rising_strike:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_FIXED_ATTACK_RATE
  }
  return funcs
end

function modifier_rising_strike:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.caster then
    self:IncrementStackCount()
  end
end

function modifier_rising_strike:GetModifierFixedAttackRate(keys)
  if not IsServer() then return end

  local charges = self:GetStackCount()
  local attackRate = self:GetParent():GetBaseAttackTime()
  local newAttackRate = attackRate - (self.attack_rate_drop * charges)

  if newAttackRate <= 0 then
    self:SetStackCount(0)
    return 0.5
  end

  return newAttackRate
end