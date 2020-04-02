LinkLuaModifier("modifier_frost_attack", "abilities/buildings/frost_attack.lua", LUA_MODIFIER_MOTION_NONE)

frost_attack = class({})
function frost_attack:GetIntrinsicModifierName() return "modifier_frost_attack" end

---------------------

modifier_frost_attack = class({})

function modifier_frost_attack:IsHidden() return false end

function modifier_frost_attack:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.num_attacks = self.ability:GetSpecialValueFor("num_attacks")
  self.bonus_damage_percent = self.ability:GetSpecialValueFor("bonus_damage_percent")
  self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")

  self:SetStackCount(1)
end

function modifier_frost_attack:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_frost_attack:OnAttackLanded(keys)
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