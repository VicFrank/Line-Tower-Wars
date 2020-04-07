LinkLuaModifier("modifier_volatile_arcane", "abilities/buildings/volatile_arcane.lua", LUA_MODIFIER_MOTION_NONE)

volatile_arcane = class({})
function volatile_arcane:GetIntrinsicModifierName() return "modifier_volatile_arcane" end

function volatile_arcane:BounceAttack(target, source, extraData)
  local caster = self:GetCaster()
  local hSource = source or caster

  extraData[tostring(target:GetEntityIndex())] = 1

  local projectile = {
    Target = target,
    Source = hSource,
    Ability = self, 
    EffectName = caster:GetRangedProjectileName(),
    iMoveSpeed = caster:GetProjectileSpeed(),
    vSourceLoc= hSource:GetAbsOrigin(),
    bDrawsOnMinimap = false,
    bDodgeable = false,
    bIsAttack = true,
    bVisibleToEnemies = true,
    bReplaceExisting = false,
    bProvidesVision = false,
    iVisionTeamNumber = caster:GetTeamNumber(),
    iSourceAttachment =  0,
    ExtraData = extraData
  }

  ProjectileManager:CreateTrackingProjectile(projectile)
end

function volatile_arcane:OnProjectileHit_ExtraData(target, position, extraData)
  if not IsServer() then return end

  if target then
    local caster = self:GetCaster()
    local ability = self
    
    local damage = tonumber(extraData.damage)
    local bounces = tonumber(extraData.bounces) or 0
    local targets = extraData.targets

    local damageTable = {
      victim = target,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      damage_flags = DOTA_DAMAGE_FLAG_NONE,
      attacker = caster,
      ability = ability
    }

    ApplyDamage(damageTable)

    if bounces > 0 then
      local radius = ability:GetSpecialValueFor("range")
      local damage_reduction_percent = ability:GetSpecialValueFor("damage_reduction_percent")

      local reduction = (100 - damage_reduction_percent) / 100
      local enemies = FindEnemiesInRadius(caster, radius, target:GetAbsOrigin())

      for _,enemy in pairs(enemies) do
        if not extraData[tostring(enemy:GetEntityIndex())] and not IsCustomBuilding(enemy) then
          local extraData = {
            damage =  damage * reduction,
            bounces = bounces - 1
          }

          self:BounceAttack(enemy, target, extraData)
          break
        end
      end
    end
  end
end

modifier_volatile_arcane = class({})

function modifier_volatile_arcane:IsHidden() return false end

function modifier_volatile_arcane:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.bounces = self.ability:GetSpecialValueFor("bounces")
  self.mana_gained = self.ability:GetSpecialValueFor("mana_gained")
  self.attack_rate_reduction = self.ability:GetSpecialValueFor("attack_rate_reduction")
  self.min_attack_rate = self.ability:GetSpecialValueFor("min_attack_rate")
  self.range = 300
end

function modifier_volatile_arcane:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
  }
end

function modifier_volatile_arcane:GetModifierFixedAttackRate(keys)
  local charges = self:GetStackCount()
  local baseAttackRate = 0.5
  local attackRate = math.max(self.min_attack_rate, baseAttackRate - self.attack_rate_reduction * charges)

  return attackRate
end

function modifier_volatile_arcane:OnTakeDamage(keys)
  local attacker = keys.attacker
  local target = keys.unit

  if attacker == self.parent and 
    keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and 
    self.parent:GetHealth() > 0 and 
    not keys.inflictor then

    self.parent:GiveMana(self.mana_gained)

    if self.parent:GetManaPercent() == 100 then
      self.parent:SetMana(0)
      self:IncrementStackCount()
    end

    local enemies = FindEnemiesInRadius(self.parent, self.range, target:GetAbsOrigin())
    for _, enemy in ipairs(enemies) do
      if enemy ~= target then
        local extraData = {
          damage =  keys.damage,
          bounces = self.bounces - 1
        }

        extraData[tostring(target:GetEntityIndex())] = 1

        self.ability:BounceAttack(enemy, target, extraData)
        break
      end
    end
  end
end