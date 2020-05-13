LinkLuaModifier("modifier_ice_lance", "abilities/buildings/ice_lance.lua", LUA_MODIFIER_MOTION_NONE)

ice_lance = class({})
function ice_lance:GetIntrinsicModifierName() return "modifier_ice_lance" end

---------------------

modifier_ice_lance = class({})

function modifier_ice_lance:IsHidden() return false end

function modifier_ice_lance:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.num_attacks = self.ability:GetSpecialValueFor("num_attacks")
  self.bonus_damage_percent = self.ability:GetSpecialValueFor("bonus_damage_percent")
  self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")

  self:SetStackCount(1)
end

function modifier_ice_lance:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_ice_lance:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    self:IncrementStackCount()

    if self:GetStackCount() == num_attacks then
      target:AddNewModifier(
        self:GetParent(),
        self:GetAbility(),
        "modifier_stunned",
        {duration = self.stun_duration}
      )

      ApplyDamage({
        victim = target,
        attacker = self:GetParent(),
        damage = damage * self.bonus_damage_percent / 100,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility()
      })

      target:EmitSound("Hero_Ancient_Apparition.ColdFeetTick")

      self:SetStackCount(1)
    end
  end
end