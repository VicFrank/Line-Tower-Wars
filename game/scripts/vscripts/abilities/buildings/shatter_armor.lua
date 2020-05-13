LinkLuaModifier("modifier_shatter_armor", "abilities/buildings/shatter_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shatter_armor_debuff", "abilities/buildings/shatter_armor.lua", LUA_MODIFIER_MOTION_NONE)

shatter_armor = class({})
function shatter_armor:GetIntrinsicModifierName() return "modifier_shatter_armor" end

modifier_shatter_armor = class({})

function modifier_shatter_armor:IsHidden() return true end

function modifier_shatter_armor:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.chance = self.ability:GetSpecialValueFor("chance")
  self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_shatter_armor:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_shatter_armor:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    if RollPercentage(self.chance) then
      target:AddNewModifier(self.parent, self.ability, "modifier_shatter_armor_debuff", {self.duration})
    end
  end
end

--------------------

modifier_shatter_armor_debuff = class({})

function modifier_shatter_armor_debuff:IsDebuff() return true end

function modifier_shatter_armor_debuff:OnCreated()
  self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_shatter_armor_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
  return funcs
end

function modifier_shatter_armor_debuff:GetModifierPhysicalArmorBonus()
  return self.armor_reduction
end