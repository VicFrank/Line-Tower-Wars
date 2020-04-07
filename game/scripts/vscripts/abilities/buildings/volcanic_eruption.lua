LinkLuaModifier("modifier_volcanic_eruption", "abilities/buildings/volcanic_eruption.lua", LUA_MODIFIER_MOTION_NONE)

volcanic_eruption = class({})
function volcanic_eruption:GetIntrinsicModifierName() return "modifier_volcanic_eruption" end

modifier_volcanic_eruption = class({})

function modifier_volcanic_eruption:IsHidden() return true end

function modifier_volcanic_eruption:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.chance = self.ability:GetSpecialValueFor("chance")
  self.aoe_damage_multiplier = self.ability:GetSpecialValueFor("aoe_damage_multiplier")
  self.num_enemies = self.ability:GetSpecialValueFor("num_enemies")
  self.attack_speed_bonus = self.ability:GetSpecialValueFor("attack_speed_bonus")
  self.enemy_health_threshold = self.ability:GetSpecialValueFor("enemy_health_threshold")
end

function modifier_volcanic_eruption:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end

function modifier_volcanic_eruption:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.caster then
    if target:GetHealthPercent() < self.enemy_health_threshold then
      self.attack_faster = true
    end

    if RollPercentage(self.chance) then
      -- 5 creeps near the target takes 160% of damage dealt
      local enemies = FindAllEnemiesInRadius(attacker, self.radius, target:GetAbsOrigin())
      local enemiestoHit = self.num_enemies

      for _,enemy in pairs(enemies) do
        ApplyDamage({
          victim = enemy,
          attacker = self:GetParent(),
          damage = damage * self.aoe_damage_multiplier / 100,
          damage_type = self:GetAbility():GetAbilityDamageType(),
          ability = self:GetAbility()
        })

        enemiestoHit = enemiestoHit - 1
        if enemiestoHit == 0 then
          return
        end
      end
    end
  end
end

function modifier_volcanic_eruption:GetModifierAttackSpeedBonus_Constant(keys)
  if self.attack_faster then
    return self.attack_speed_bonus
  end

  return 0
end