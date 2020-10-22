LinkLuaModifier("modifier_ogre_splash_attack", "abilities/buildings/ogre_splash_attack.lua", LUA_MODIFIER_MOTION_NONE)

ogre_splash_attack = class({})
function ogre_splash_attack:GetIntrinsicModifierName() return "modifier_ogre_splash_attack" end


modifier_ogre_splash_attack = class({})

function modifier_ogre_splash_attack:IsHidden() return true end

function modifier_ogre_splash_attack:OnCreated()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.radius = self.parent:GetSplashRadius()
end

function modifier_ogre_splash_attack:DeclareFunctions()
  return { 
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
end

function modifier_ogre_splash_attack:OnAttackLanded(keys)
  if not IsServer() then return end
  
  if keys.attacker == self:GetParent() then
    local target = keys.target
    local position = target:GetAbsOrigin()

    local nFXIndex = ParticleManager:CreateParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN, self.parent)
    ParticleManager:SetParticleControl(nFXIndex, 0, position)
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(nFXIndex)
  end
end
