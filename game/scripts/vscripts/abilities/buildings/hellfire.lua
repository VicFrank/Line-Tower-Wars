LinkLuaModifier("modifier_hellfire", "abilities/buildings/hellfire.lua", LUA_MODIFIER_MOTION_NONE)

hellfire = class({})
function hellfire:GetIntrinsicModifierName() return "modifier_hellfire" end

modifier_hellfire = class({})

function modifier_hellfire:IsHidden() return true end

function modifier_hellfire:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.damage_increase = self.ability:GetSpecialValueFor("damage_increase")
  self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_hellfire:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_hellfire:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
     local enemies = FindEnemiesInRadius(target, self.radius)
  end
end