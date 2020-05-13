LinkLuaModifier("modifier_electrocute", "abilities/buildings/electrocute.lua", LUA_MODIFIER_MOTION_NONE)

electrocute = class({})
function electrocute:GetIntrinsicModifierName() return "modifier_electrocute" end

modifier_electrocute = class({})

function modifier_electrocute:IsHidden() return true end

function modifier_electrocute:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  print("electrocute created")

  self.health_as_damage = self.ability:GetSpecialValueFor("health_as_damage")
end

function modifier_electrocute:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }

  return funcs
end

function modifier_electrocute:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.parent then
    local damage = keys.target:GetHealth() * self.health_as_damage / 100

    local particleName = "particles/units/heroes/hero_zuus/zuus_static_field.vpcf"
    local casterPosition = self:GetParent():GetAbsOrigin()

    self.caster:EmitSound("Hero_Zuus.StaticField")

    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControl(particle, 0, casterPosition)   
    ParticleManager:SetParticleControl(particle, 1, casterPosition * 100) 
    ParticleManager:ReleaseParticleIndex(particle)

    ApplyDamage({
      attacker = attacker,
      victim = target,
      ability = self.ability,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
    })
  end
end