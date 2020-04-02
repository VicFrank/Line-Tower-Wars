LinkLuaModifier("modifier_overcharge", "abilities/buildings/overcharge.lua", LUA_MODIFIER_MOTION_NONE)

overcharge = class({})
function overcharge:GetIntrinsicModifierName() return "modifier_overcharge" end

modifier_overcharge = class({})

function modifier_overcharge:IsHidden() return true end

function modifier_overcharge:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.chance = self.ability:GetSpecialValueFor("chance")
  self.damage = self.ability:GetSpecialValueFor("damage")
  self.radius = self.ability:GetSpecialValueFor("radius")
  self.targets = self.ability:GetSpecialValueFor("targets")
end

function modifier_overcharge:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_overcharge:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    if RollPercentage(self.chance) then
      OnLightningProc(self, target)
    end
  end
end

function OnLightningProc(modifier, target)
  modifier.caster:EmitSound("Item.Maelstrom.Chain_Lightning")

  local hit = {}
  hit[target] = true

  local lastBounce = modifier.caster
  local nextBounce = target
  local bounces = 1
  local damage = modifier.damage

  Timers:CreateTimer(function()
    if not nextBounce or bounces >= modifier.targets then return end

    -- Apply the lightning
    nextBounce:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")

    local particleName = "particles/items_fx/chain_lightning.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, nextBounce)
    ParticleManager:SetParticleControlEnt(particle, 0, lastBounce, PATTACH_POINT_FOLLOW, "attach_hitloc", lastBounce:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, nextBounce, PATTACH_POINT_FOLLOW, "attach_hitloc", nextBounce:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particle, 2, Vector(1, 1, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    ApplyDamage({
      attacker = modifier.caster, 
      victim = nextBounce,
      ability = modifier.ability,
      damage = damage, 
      damage_type = DAMAGE_TYPE_MAGICAL
    })

    -- Find the next bounce target
    lastBounce = nextBounce
    nextBounce = nil

    local nearbyEnemies = FindEnemiesInRadius(modifier.caster, modifier.radius, lastBounce:GetAbsOrigin())
    for _,enemy in pairs(nearbyEnemies) do
      if not hit[enemy] and not enemy:IsMagicImmune() then
        nextBounce = enemy
      end
    end

    if nextBounce then
      hit[nextBounce] = true
    end

    bounces = bounces + 1

    return .25
  end)
end