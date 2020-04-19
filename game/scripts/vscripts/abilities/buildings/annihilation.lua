LinkLuaModifier("modifier_annihilation", "abilities/buildings/annihilation.lua", LUA_MODIFIER_MOTION_NONE)

annihilation = class({})
function annihilation:GetIntrinsicModifierName() return "modifier_annihilation" end

-----------------------------

modifier_annihilation = class({})

function modifier_annihilation:IsHidden() return true end

function modifier_annihilation:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.attack_rate_min = self.ability:GetSpecialValueFor("attack_rate_min")
  self.attack_rate_max = self.ability:GetSpecialValueFor("attack_rate_max")
end

function modifier_annihilation:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_FIXED_ATTACK_RATE
  }
  return funcs
end

function modifier_annihilation:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.caster then
    self:IncrementStackCount()
  end
end

function modifier_annihilation:GetModifierFixedAttackRate(keys)
  if not IsServer() then return end

  if RollPercentage(50) then
    return self.attack_rate_min
  else
    return self.attack_rate_max
  end
end