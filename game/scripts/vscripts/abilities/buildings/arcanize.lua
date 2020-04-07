LinkLuaModifier("modifier_arcanize", "abilities/buildings/arcanize.lua", LUA_MODIFIER_MOTION_NONE)

arcanize = class({})
function arcanize:GetIntrinsicModifierName() return "modifier_arcanize" end

modifier_arcanize = class({})

function modifier_arcanize:IsHidden() return true end

function modifier_arcanize:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.mana_gained = self.ability:GetSpecialValueFor("mana_gained")
  self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
end

function modifier_arcanize:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
  }
  return funcs
end

function modifier_arcanize:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    self.parent:GiveMana(self.mana_gained)
  end
end

function modifier_arcanize:GetModifierPreAttack_BonusDamage()
  if self.parent:GetMana() == self.parent:GetMaxMana() then
    return self.bonus_damage
  end
end