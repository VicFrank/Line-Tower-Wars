LinkLuaModifier("modifier_torrent", "abilities/buildings/torrent.lua", LUA_MODIFIER_MOTION_NONE)

torrent = class({})
function torrent:GetIntrinsicModifierName() return "modifier_torrent" end
torrent2 = class({})
function torrent2:GetIntrinsicModifierName() return "modifier_torrent" end

modifier_torrent = class({})

function modifier_torrent:IsHidden() return true end

function modifier_torrent:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.delay = self.ability:GetSpecialValueFor("delay")
  self.radius = self.ability:GetSpecialValueFor("radius")
  self.second_delay = self.ability:GetSpecialValueFor("second_delay")
  self.second_splash_percent = self.ability:GetSpecialValueFor("second_splash_percent")
end

function modifier_torrent:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_torrent:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    local targetPosition = target:GetAbsOrigin()

    local bubbleParticleName = "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf"
    local bubbleParticle = ParticleManager:CreateParticle(bubbleParticleName, PATTACH_ABSORIGIN, self.parent)
    ParticleManager:SetParticleControl(bubbleParticle, 0, targetPosition)
    ParticleManager:SetParticleControl(bubbleParticle, 1, Vector(self.radius,0,0))

    Timers:CreateTimer(self.delay, function()
        ParticleManager:DestroyParticle(bubbleParticle, false)
        ParticleManager:ReleaseParticleIndex(bubbleParticle)

        EmitSoundOnLocationWithCaster(targetPosition, "Ability.Torrent", self.parent)
        
        local splashParticleName = "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf"
        local splashParticle = ParticleManager:CreateParticle(splashParticleName, PATTACH_CUSTOMORIGIN, self.parent)
        ParticleManager:SetParticleControl(splashParticle, 0, targetPosition)
        ParticleManager:SetParticleControl(splashParticle, 1, Vector(self.radius,0,0))
        ParticleManager:ReleaseParticleIndex(splashParticle)

        local enemies = FindAllEnemiesInRadius(attacker, self.radius, targetPosition)

        for _,enemy in pairs(enemies) do
          ApplyDamage({
            victim = enemy,
            attacker = attacker,
            damage = self.parent:GetAttackDamage(),
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self.ability
          })
        end
    end)

    if self.ability:GetAbilityName() == "torrent2" then
      Timers:CreateTimer(self.second_delay, function()
        local splashRadius = self.radius
        ParticleManager:DestroyParticle(bubbleParticle, false)
        ParticleManager:ReleaseParticleIndex(bubbleParticle)

        EmitSoundOnLocationWithCaster(targetPosition, "Ability.Torrent", self.parent)
        
        local splashParticleName = "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf"
        local splashParticle = ParticleManager:CreateParticle(splashParticleName, PATTACH_CUSTOMORIGIN, self.parent)
        ParticleManager:SetParticleControl(splashParticle, 0, targetPosition)
        ParticleManager:SetParticleControl(splashParticle, 1, Vector(splashRadius,0,0))
        ParticleManager:ReleaseParticleIndex(splashParticle)

        local enemies = FindAllEnemiesInRadius(attacker, splashRadius, targetPosition)

        for _,enemy in pairs(enemies) do
          ApplyDamage({
            victim = enemy,
            attacker = attacker,
            damage = self.parent:GetAttackDamage() * self.second_splash_percent / 100,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self.ability
          })
        end
      end)
    end

    return 0
  end
end