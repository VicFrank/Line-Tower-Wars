LinkLuaModifier("modifier_volatile_death", "abilities/creeps/volatile_death.lua", LUA_MODIFIER_MOTION_NONE)

volatile_death = class({})
function volatile_death:GetIntrinsicModifierName() return "modifier_volatile_death" end

modifier_volatile_death = class({})

function modifier_volatile_death:IsHidden() return true end

function modifier_volatile_death:OnCreated()
  local ability = self:GetAbility()

  self.damage = ability:GetSpecialValueFor("damage")
  self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_volatile_death:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_volatile_death:OnDeath(params)
  if not IsServer() then return end

  local parent = self:GetParent()

  if params.unit == parent then
    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_POINT, parent)
    ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius/2,0,0))
    ParticleManager:SetParticleControl(nfx, 2, Vector(self.radius,self.radius,1))
    ParticleManager:ReleaseParticleIndex(nfx)

    local enemies = FindEnemiesInRadius(parent, self.radius)

    for _,enemy in pairs(enemies) do
      if IsCustomBuilding(enemy) then
        local distance = GetDistanceBetweenTwoUnits(parent, enemy)
        local damage = self.damage / 2

        -- apply less damage to units further away
        if distance < self.radius / 2 then
          damage = damage * 2
        end

        ApplyDamage({
          victim = enemy,
          attacker = self:GetParent(),
          damage = damage / 2,
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self:GetAbility()
        })
      end
    end
  end
end