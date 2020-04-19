LinkLuaModifier("modifier_electrocute", "abilities/buildings/electrocute.lua", LUA_MODIFIER_MOTION_NONE)

electrocute = class({})
function electrocute:GetIntrinsicModifierName() return "modifier_electrocute" end

modifier_electrocute = class({})

function modifier_electrocute:IsHidden() return true end

function modifier_electrocute:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.health_as_damage = self.ability:GetSpecialValueFor("health_as_damage")
end

function modifier_electrocute:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
  }

  return funcs
end

function modifier_electrocute:GetModifierProcAttack_BonusDamage_Physical(keys)
  if IsServer() then
    local damage = keys.target:GetHealth() * self.health_as_damage / 100

    local particleName = "particles/units/heroes/hero_zuus/zuus_static_field.vpcf"
    local casterPosition = self:GetParent():GetAbsOrigin()

    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, casterPosition)   
    ParticleManager:SetParticleControl(particle, 1, casterPosition * 100) 
    ParticleManager:ReleaseParticleIndex(particle)
    
    return damage
  end
end
