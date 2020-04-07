LinkLuaModifier("modifier_hurricane_storm", "abilities/buildings/hurricane_storm.lua", LUA_MODIFIER_MOTION_NONE)

hurricane_storm = class({})
function hurricane_storm:GetIntrinsicModifierName() return "modifier_hurricane_storm" end

modifier_hurricane_storm = class({})

function modifier_hurricane_storm:IsHidden() return true end

function modifier_hurricane_storm:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.max_bonus_damage = self.ability:GetSpecialValueFor("max_bonus_damage")
end

function modifier_hurricane_storm:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_hurricane_storm:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.parent then
    local maxDistance = self.parent:Script_GetAttackRange()
    local attackerPosition = attacker:GetAbsOrigin()
   
    EmitSoundOn("Hero_Kunkka.TidebringerDamage", caster)

    local enemies = FindAllEnemiesInRadius(attacker, self.radius, target:GetAbsOrigin())

    for _,enemy in pairs(enemies) do
      local particleName = "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf"

      local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, attacker)
      ParticleManager:SetParticleControlEnt(particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
      ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
      ParticleManager:SetParticleControlForward(particle, 1, attacker:GetForwardVector())
      ParticleManager:SetParticleControlEnt(particle, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
      ParticleManager:ReleaseParticleIndex(particle)

      local distance = (attackerPosition - enemy:GetAbsOrigin()):Length2D()

      if distance < maxDistance then
        local distanceMultiplier = 1 - (distance / maxDistance)
        local damageMultiplier = distanceMultiplier * self.max_bonus_damage / 100

        ApplyDamage({
          victim = enemy,
          attacker = attacker,
          damage = damage * damageMultiplier,
          damage_type = DAMAGE_TYPE_PHYSICAL,
          ability = self.ability
        })
      end
    end
  end
end