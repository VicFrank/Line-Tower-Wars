LinkLuaModifier("modifier_crushing_wave", "abilities/buildings/crushing_wave.lua", LUA_MODIFIER_MOTION_NONE)

crushing_wave = class({})
function crushing_wave:GetIntrinsicModifierName() return "modifier_crushing_wave" end

modifier_crushing_wave = class({})

function modifier_crushing_wave:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.num_attacks = self.ability:GetSpecialValueFor("num_attacks")
  self.radius = self.ability:GetSpecialValueFor("radius")
  self.distance = self.ability:GetSpecialValueFor("distance")
  self.speed = self.ability:GetSpecialValueFor("speed")

  self:SetStackCount(0)
end

function modifier_crushing_wave:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK,
  }
  return funcs
end

function modifier_crushing_wave:OnAttack(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    self:IncrementStackCount()

    if self:GetStackCount() == self.num_attacks then
      self:SetStackCount(0)

      local particleName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"

      local direction = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()

      ProjectileManager:CreateLinearProjectile({
        Ability = self:GetAbility(),
        EffectName = particleName,
        vSpawnOrigin = self:GetParent():GetAbsOrigin(),
        fDistance = self.distance,
        fStartRadius = self.radius,
        fEndRadius = self.radius,
        Source = self:GetParent(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 3.0,
        bDeleteOnHit = false,
        vVelocity = Vector(direction.x,direction.y,0) * self.speed,
        bProvidesVision = false,
      })

      return false
    end
  end
end

function crushing_wave:OnProjectileHit(target, location)
  if not IsServer() then return end

  if not IsValidAlive(target) or target:HasFlyMovementCapability() then return end

  ApplyDamage({
    victim = target,
    attacker = self:GetCaster(),
    damage = self:GetSpecialValueFor("damage"),
    damage_type = self:GetAbilityDamageType(),
    ability = self
  })
end