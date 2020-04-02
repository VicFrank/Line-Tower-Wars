LinkLuaModifier("modifier_custom_ignite", "abilities/buildings/ignite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_ignite_debuff", "abilities/buildings/ignite.lua", LUA_MODIFIER_MOTION_NONE)

ignite = class({})
function ignite:GetIntrinsicModifierName() return "modifier_custom_ignite" end

----------------------

modifier_custom_ignite = class({})

function modifier_custom_ignite:IsHidden() return true end

function modifier_custom_ignite:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_custom_ignite:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    target:AddNewModifier(
      self:GetCaster(),
      self:GetAbility(),
      "modifier_custom_ignite_debuff",
      {duration = self.duration}
    )
  end
end

----------------------

modifier_custom_ignite_debuff = class({})

function modifier_custom_ignite_debuff:IsHidden() return false end
function modifier_custom_ignite_debuff:IsDebuff() return true end

function modifier_custom_ignite_debuff:OnCreated()
  self.damageTable = {
    victim = self:GetParent(),
    attacker = self:GetCaster(),
    damage = self.ability:GetSpecialValueFor("dps"),
    damage_type = self:GetAbility():GetAbilityDamageType(),
    ability = self:GetAbility(),
  }

  self:StartIntervalThink(1)
end

function modifier_custom_ignite_debuff:OnRefresh()
  if not IsServer() then return end
  self.damageTable.damage = self:GetAbility():GetSpecialValueFor("dps")
end

function modifier_custom_ignite_debuff:OnIntervalThink()
  ApplyDamage(self.damageTable)

  EmitSoundOn("Hero_OgreMagi.Ignite.Damage", self:GetParent())
end

function modifier_custom_ignite_debuff:GetEffectName()
  return "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf"
end

function modifier_custom_ignite_debuff:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end