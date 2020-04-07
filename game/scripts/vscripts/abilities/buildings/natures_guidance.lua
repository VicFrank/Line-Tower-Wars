LinkLuaModifier("modifier_natures_guidance", "abilities/buildings/natures_guidance.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_natures_guidance_debuff", "abilities/buildings/natures_guidance.lua", LUA_MODIFIER_MOTION_NONE)

natures_guidance = class({})
function natures_guidance:GetIntrinsicModifierName() return "modifier_natures_guidance" end

modifier_natures_guidance = class({})

function modifier_natures_guidance:IsHidden() return true end

function modifier_natures_guidance:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.heal_percent = self.ability:GetSpecialValueFor("heal_percent")
  self.chance = self.ability:GetSpecialValueFor("chance")
  self.armor_reduction = self.ability:GetSpecialValueFor("armor_reduction")
end

function modifier_natures_guidance:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_natures_guidance:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    if RollPercentage(self.chance) then
      local modifier = target:AddNewModifier(self.parent, self.ability, "modifier_natures_guidance_debuff", {})

      modifier:IncrementStackCount()
    end

    local damage = keys.damage
    local heal = self.heal_percent * damage

    self:Heal(heal, self.parent)

    local particleName = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, attacker)
    ParticleManager:SetParticleControlEnt(particle, 0, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
  end
end

--------------------

modifier_natures_guidance_debuff = class({})

function modifier_natures_guidance_debuff:IsDebuff() return true end

function modifier_natures_guidance_debuff:OnCreated()
  self.armor_reduction = self.ability:GetSpecialValueFor("armor_reduction")
end

function modifier_natures_guidance_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
  return funcs
end

function modifier_natures_guidance_debuff:GetModifierPhysicalArmorBonus()
  return self.armor_reduction * self:GetStackCount()
end