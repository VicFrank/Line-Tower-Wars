LinkLuaModifier("modifier_spellcast", "abilities/buildings/spellcast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellcast_slow", "abilities/buildings/spellcast.lua", LUA_MODIFIER_MOTION_NONE)

spellcast = class({})
function spellcast:GetIntrinsicModifierName() return "modifier_spellcast" end

modifier_spellcast = class({})

function modifier_spellcast:IsHidden() return true end

function modifier_spellcast:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self:StartIntervalThink(0.3)
end

function modifier_spellcast:OnIntervalThink()
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

    -- Cast random spell on target
    if RollPercentage(50) then
      -- Cast Slow
      self.parent:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")

      ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = self.parent,
        Ability = self.ability,
        EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf",
        iMoveSpeed = 900,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false,
        ExtraData = {
          spell = "slow"
        }
      })
    else
      -- Cast Fireball
      self.parent:EmitSound("Hero_Clinkz.SearingArrows")

      ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = self.parent,
        Ability = self.ability,
        EffectName = "particles/hero/clinkz/searing_flames_active/clinkz_searing_arrow.vpcf",
        iMoveSpeed = 900,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false,
        ExtraData = {
          spell = "fireball"
        }
      })
    end

    self.parent:SetMana(0)
  end
end

function spellcast:OnProjectileHit_ExtraData(target, location, extraData)
  if not IsServer() then return end

  local slow_duration = self:GetSpecialValueFor("slow_duration")
  local bonus_damage_percent = self:GetSpecialValueFor("bonus_damage_percent")
  local stun_duration = self:GetSpecialValueFor("stun_duration")

  if extraData.spell == "slow" then
    target:EmitSound("Hero_SkywrathMage.ConcussiveShot.Target")
    target:AddNewModifier(self:GetCaster(), self, "modifier_spellcast_slow", {duration = slow_duration})
  elseif extraData.spell == "fireball" then
    local damage = self:GetCaster():GetAttackDamage() * bonus_damage_percent / 100

    target:EmitSound("Hero_Clinkz.SearingArrows.Impact")

    ApplyDamage({
      attacker = self:GetCaster(),
      victim = target,
      ability = self,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
    })

    target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})
  end
end

-------------------------------

modifier_spellcast_slow = class({})

function modifier_spellcast_slow:IsHidden() return true end

function modifier_spellcast_slow:OnCreated()
  self.slow_percent = self:GetAbility():GetSpecialValueFor("slow_percent")
end

function modifier_spellcast_slow:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_spellcast_slow:GetModifierMoveSpeedBonus_Percentage()
  return -self.slow_percent
end

function modifier_spellcast_slow:GetEffectName()
  return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_slow_debuff.vpcf"
end

function modifier_spellcast_slow:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end