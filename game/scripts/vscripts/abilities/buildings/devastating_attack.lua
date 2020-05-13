LinkLuaModifier("modifier_devastating_attack", "abilities/buildings/devastating_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_devastating_attack_debuff", "abilities/buildings/devastating_attack.lua", LUA_MODIFIER_MOTION_NONE)

devastating_attack = class({})
function devastating_attack:GetIntrinsicModifierName() return "modifier_devastating_attack" end

modifier_devastating_attack = class({})

function modifier_devastating_attack:IsHidden() return true end

function modifier_devastating_attack:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.chance = self.ability:GetSpecialValueFor("chance")
end

function modifier_devastating_attack:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_devastating_attack:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    if RollPercentage(self.chance) then
      local modifier = target:AddNewModifier(self.parent, self.ability, "modifier_devastating_attack_debuff", {})

      modifier:IncrementStackCount()
    end
  end
end

--------------------

modifier_devastating_attack_debuff = class({})

function modifier_devastating_attack_debuff:IsDebuff() return true end

function modifier_devastating_attack_debuff:OnCreated()
  self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_devastating_attack_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
  return funcs
end

function modifier_devastating_attack_debuff:GetModifierPhysicalArmorBonus()
  return self.armor_reduction * self:GetStackCount()
end