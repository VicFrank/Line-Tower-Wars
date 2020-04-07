LinkLuaModifier("modifier_spell_mastery", "abilities/buildings/spell_mastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spell_mastery_slow", "abilities/buildings/spell_mastery.lua", LUA_MODIFIER_MOTION_NONE)

spell_mastery = class({})
function spell_mastery:GetIntrinsicModifierName() return "modifier_spell_mastery" end

modifier_spell_mastery = class({})

function modifier_spell_mastery:IsHidden() return true end

function modifier_spell_mastery:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.nova_aoe_damage_percent = self.ability:GetSpecialValueFor("nova_aoe_damage_percent")
  self.slow_duration = self.ability:GetSpecialValueFor("slow_duration")
  self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
  self.aoe_slow_percent = self.ability:GetSpecialValueFor("aoe_slow_percent")
  self.nova_radius = self.ability:GetSpecialValueFor("nova_radius")
  self.blizzard_radius = self.ability:GetSpecialValueFor("blizzard_radius")
  self.blizzard_aoe_damage_percent = self.ability:GetSpecialValueFor("blizzard_aoe_damage_percent")
  self.arcane_barrage_targets = self.ability:GetSpecialValueFor("arcane_barrage_targets")
  self.arcane_barrage_damage_percent = self.ability:GetSpecialValueFor("arcane_barrage_damage_percent")

  self:StartIntervalThink(0.3)
end

function modifier_spell_mastery:OnIntervalThink()
  if not IsServer() then return end

  if self.parent:GetManaPercent() == 100 then
    local enemies = FindEnemiesInRadius(self.parent, 800)
    local target

    for _,enemy in pairs(enemies) do
      if not enemy:IsMagicImmune() then
        target = enemy
        break
      end
    end

    if not target then return end

    local randomInt = RandomInt(1, 100)

    -- Cast random spell on target
    if randomInt < 33 then
      -- Frost Nova
      local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"

      local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, nil)
      ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
      ParticleManager:SetParticleControl(particle, 1, Vector(self.nova_radius, self.slow_duration, self.nova_radius))
      ParticleManager:ReleaseParticleIndex(particle)

      EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Crystal.CrystalNova", self:GetCaster())

      enemies = FindAllEnemiesInRadius(self.parent, self.nova_radius, self.target:GetAbsOrigin())

      for _,enemy in pairs(enemies) do
        ApplyDamage({
          attacker = self.parent,
          victim = enemy,
          ability = self.ability,
          damage = self.parent:GetAttackDamage() * self.nova_aoe_damage_percent / 100,
          damage_type = DAMAGE_TYPE_MAGICAL,
        })

        enemy:AddNewModifier(self.parent, self.ability, "modifier_spell_mastery_slow", {duration = self.slow_duration})
      end

    else if randomInt < 66 then
      -- Blizzard
      local particleName = "particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf"

      local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, nil)
      ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
      -- ParticleManager:SetParticleControl(particle, 1, Vector(self.blizzard_radius, self.slow_duration, self.nova_radius))
      ParticleManager:ReleaseParticleIndex(particle)

      EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster())

      enemies = FindAllEnemiesInRadius(self.parent, self.blizzard_radius, self.target:GetAbsOrigin())

      for _,enemy in pairs(enemies) do
        ApplyDamage({
          attacker = self.parent,
          victim = enemy,
          ability = self.ability,
          damage = self.parent:GetAttackDamage() * self.blizzard_aoe_damage_percent / 100,
          damage_type = DAMAGE_TYPE_MAGICAL,
        })
      end
    else
      -- Cast Arcane Barrage
      self.parent:EmitSound("Hero_SkywrathMage.ArcaneBolt.Cast")

      ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = self.parent,
        Ability = self.ability,
        EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
        iMoveSpeed = 900,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false,
      })
    end

    self.parent:SetMana(0)
  end
end

function modifier_spell_mastery:OnProjectileHit(target, location)
  target:EmitSound("Hero_SkywrathMage.ArcaneBolt.Impact")

  ApplyDamage({
    attacker = self.parent,
    victim = target,
    ability = self.ability,
    damage = self.parent:GetAttackDamage() * self.arcane_barrage_damage_percent / 100,
    damage_type = DAMAGE_TYPE_PHYSICAL,
  })

  target:AddNewModifier(self.parent, self.ability, "modifier_stunned", {duration = self.stun_duration})
end

-------------------------------

modifier_spell_mastery_slow = class({})

function modifier_spell_mastery_slow:IsHidden() return true end

function modifier_spell_mastery_slow:OnCreated()
  self.nova_slow_percent = self.ability:GetSpecialValueFor("nova_slow_percent")
end

function modifier_spell_mastery_slow:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_spell_mastery_slow:GetModifierMoveSpeedBonus_Percentage()
  return -self.nova_slow_percent
end

function modifier_spell_mastery_slow:GetStatusEffectName()
  return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_spell_mastery_slow:StatusEffectPriority()
  return FX_PRIORITY_CHILLED
end

function modifier_spell_mastery_slow:GetEffectName()
  return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_spell_mastery_slow:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end
