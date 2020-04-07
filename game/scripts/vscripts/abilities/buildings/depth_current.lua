LinkLuaModifier("modifier_depth_current", "abilities/buildings/depth_current.lua", LUA_MODIFIER_MOTION_NONE)

depth_current = class({})
function depth_current:GetIntrinsicModifierName() return "modifier_depth_current" end

modifier_depth_current = class({})

function modifier_depth_current:IsHidden() return true end

function modifier_depth_current:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.health_as_damage = self.ability:GetSpecialValueFor("health_as_damage")
  self.chance = self.ability:GetSpecialValueFor("chance")
  self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_depth_current:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }

  return funcs
end

function modifier_depth_current:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    if RollPercentage(chance) then
      local particleName = "particles/units/heroes/hero_zuus/zuus_static_field.vpcf"
      local casterPosition = self:GetParent():GetAbsOrigin()

      caster:EmitSound("Hero_Zuus.StaticField")

      local enemies = FindAllEnemiesInRadius(attacker, self.radius, target:GetAbsOrigin())

      for _,enemy in pairs(enemies) do
        local damage = enemy:GetHealth() * self.health_as_damage / 100

        local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particle, 0, casterPosition)
        ParticleManager:SetParticleControl(particle, 1, casterPosition * 100)
        ParticleManager:ReleaseParticleIndex(particle)

        ApplyDamage({
          victim = enemy,
          attacker = self:GetParent(),
          damage = damage,
          damage_type = self:GetAbility():GetAbilityDamageType(),
          ability = self:GetAbility(),
        })
      end
    end
  end
end