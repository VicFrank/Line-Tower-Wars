LinkLuaModifier("modifier_rising_heat", "abilities/buildings/rising_heat.lua", LUA_MODIFIER_MOTION_NONE)

rising_heat = class({})
function rising_heat:GetIntrinsicModifierName() return "modifier_rising_heat" end

-----------------------------

modifier_rising_heat = class({})

function modifier_rising_heat:IsHidden() return true end

function modifier_rising_heat:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.attack_rate_drop = self.ability:GetSpecialValueFor("attack_rate_drop")

  self:SetStackCount(0)
end

function modifier_rising_heat:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_FIXED_ATTACK_RATE
  }
  return funcs
end

function modifier_rising_heat:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.caster then
    self:IncrementStackCount()
  end
end

function modifier_rising_heat:GetModifierFixedAttackRate(keys)
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