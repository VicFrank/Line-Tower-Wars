LinkLuaModifier("modifier_lunar_strike", "abilities/buildings/lunar_strike.lua", LUA_MODIFIER_MOTION_NONE)

lunar_strike = class({})
function lunar_strike:GetIntrinsicModifierName() return "modifier_lunar_strike" end

-----------------------------

modifier_lunar_strike = class({})

function modifier_lunar_strike:IsHidden() return true end

function modifier_lunar_strike:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.chance = self.ability:GetSpecialValueFor("chance")
  self.radius = self.ability:GetSpecialValueFor("radius")
  self.percent_damage = self.ability:GetSpecialValueFor("percent_damage")
  self.max_stacks = 4

  self:SetStackCount(1)
end

function modifier_lunar_strike:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_FIXED_ATTACK_RATE
  }
  return funcs
end

function modifier_lunar_strike:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.caster then
    self:IncrementStackCount()
    if self:GetStackCount() > self.max_stacks then
      self:SetStackCount(1)
    end

    if RollPercentage(self.chance) then
      -- after a 0.6 second delay, project a moonray that does 40% of damage dealt over
      -- 200 radius (and also hit flying units)
      local delay = 0.6

      Timers:CreateTimer(delay, function()
        if IsValidAlive(target) then
          self:PlayEffects2(target)

          local enemies = FindAllEnemiesInRadius(attacker, self.radius, target:GetAbsOrigin())
          local aoeDamage = damage * self.percent_damage / 100

          for _,enemy in pairs(enemies) do
            ApplyDamage({
              victim = enemy,
              attacker = self:GetParent(),
              damage = aoeDamage,
              damage_type = self:GetAbility():GetAbilityDamageType(),
              ability = self:GetAbility()
            })
          end
        end
      end)
    end
  end
end

function modifier_lunar_strike:GetModifierFixedAttackRate(keys)
  local charges = self:GetStackCount()
  local baseAttackRate = 4.0

  return baseAttackRate / charges
end

function modifier_lunar_strike:PlayEffects2( target )
  local particle_cast = "particles/units/heroes/hero_luna/luna_lucent_beam.vpcf"
  local sound_cast = "Hero_Luna.LucentBeam.Cast"
  local sound_target = "Hero_Luna.LucentBeam.Target"

  -- Create Particle
  local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
  ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
  ParticleManager:SetParticleControlEnt(
    effect_cast,
    1,
    target,
    PATTACH_ABSORIGIN_FOLLOW,
    "attach_hitloc",
    Vector(0,0,0), -- unknown
    true -- unknown, true
  )
  ParticleManager:SetParticleControlEnt(
    effect_cast,
    5,
    target,
    PATTACH_POINT_FOLLOW,
    "attach_hitloc",
    Vector(0,0,0), -- unknown
    true -- unknown, true
  )
  ParticleManager:SetParticleControlEnt(
    effect_cast,
    6,
    self:GetCaster(),
    PATTACH_POINT_FOLLOW,
    "attach_attack1",
    Vector(0,0,0), -- unknown
    true -- unknown, true
  )
  ParticleManager:ReleaseParticleIndex( effect_cast )

  -- Create Sound
  EmitSoundOn( sound_cast, self:GetCaster() )
  EmitSoundOn( sound_target, target )
end