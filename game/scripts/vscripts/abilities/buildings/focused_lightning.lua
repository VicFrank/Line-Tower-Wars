LinkLuaModifier("modifier_focused_lightning", "abilities/buildings/focused_lightning.lua", LUA_MODIFIER_MOTION_NONE)

focused_lightning = class({})
function focused_lightning:GetIntrinsicModifierName() return "modifier_focused_lightning" end

modifier_focused_lightning = class({})

function modifier_focused_lightning:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.bonus_damage_percent = self.ability:GetSpecialValueFor("bonus_damage_percent")
end

function modifier_focused_lightning:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
  }
  return funcs
end

function modifier_focused_lightning:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    self:IncrementStackCount()

    if not IsValidAlive(self.lastTarget) or not (self.lastTarget:GetEntityIndex() == target:GetEntityIndex()) then
      self:SetStackCount(0)
    end

    self.lastTarget = target
  end
end

function modifier_focused_lightning:GetModifierBaseDamageOutgoing_Percentage()
  return self.bonus_damage_percent * self:GetStackCount()
end