LinkLuaModifier("modifier_corruption", "abilities/buildings/corruption.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_corruption_debuff", "abilities/buildings/corruption.lua", LUA_MODIFIER_MOTION_NONE)

void_walker_corruption = class({})
function void_walker_corruption:GetIntrinsicModifierName() return "modifier_corruption" end

modifier_corruption = class({})

function modifier_corruption:IsHidden() return true end

function modifier_corruption:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_corruption:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_corruption:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster and not IsCustomBuilding(target) then
    local debuffName = "modifier_corruption_debuff"
    target:AddNewModifier(self.caster, self.ability, debuffName, {duration = self.duration})
  end
end

modifier_corruption_debuff = class({})

function modifier_corruption_debuff:IsDebuff()
  return true
end

function modifier_corruption_debuff:GetTexture()
  return "spawnlord_master_stomp"
end

function modifier_corruption_debuff:GetEffectName()
  return "particles/units/heroes/hero_enigma/enigma_malefice.vpcf"
end

function modifier_corruption_debuff:DeclareFunctions()
  local decFuns =
    {
      MODIFIER_EVENT_ON_DEATH
    }
  return decFuns
end

function modifier_corruption_debuff:OnCreated()
  self.damage = self:GetAbility():GetSpecialValueFor("damage")
  self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_corruption_debuff:OnDeath(keys)
  if not IsServer() then return nil end

  if keys.unit == self:GetParent() then
    local damage = self.damage
    local enemies = FindAlliesInRadius(self:GetParent(), self.radius)

    for _,enemy in pairs(enemies) do
      ApplyDamage( {
        victim = enemy,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
      })
    end

    local target = self:GetParent()
    local particleName = "particles/econ/events/ti9/blink_dagger_ti9_end.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(particle)
    target:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
  end
end