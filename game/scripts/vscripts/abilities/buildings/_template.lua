LinkLuaModifier("modifier_template", "abilities/buildings/template.lua", LUA_MODIFIER_MOTION_NONE)

template = class({})
function template:GetIntrinsicModifierName() return "modifier_template" end

modifier_template = class({})

function modifier_template:IsHidden() return true end

function modifier_template:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.chance = self.ability:GetSpecialValueFor("chance")
end

function modifier_template:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_template:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    
  end
end