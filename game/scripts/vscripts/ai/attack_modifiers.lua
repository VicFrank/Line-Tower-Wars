modifier_autoattack = class({})

function modifier_autoattack:IsHidden() return true end

if not IsServer() then return end

function modifier_autoattack:DeclareFunctions()
  return { 
    MODIFIER_PROPERTY_DISABLE_AUTOATTACK, 
    MODIFIER_EVENT_ON_ATTACK,
  }
end

function modifier_autoattack:GetDisableAutoAttack()
  return 1
end

function modifier_autoattack:OnCreated(keys)
  self.parent = self:GetParent()
  self.keep_target = true
  self:StartIntervalThink(0.03)
end

function modifier_autoattack:OnIntervalThink()
  local attackTarget = self.parent:GetAttackTarget()

  if self.parent:IsChanneling() then return end

  -- Find a new target, changing the target on every attack
  if self.parent:AttackReady() and not self.parent:IsAttacking() then
    local target = GetTowerTarget(self.parent)
    if target ~= attackTarget then
      self.parent:MoveToTargetToAttack(target)
    end
  end
end

function modifier_autoattack:OnAttack(keys)
  if keys.attacker == self.parent then
    if not self:ShouldContinueAttacking() then
      self.parent:Interrupt()
    end
  end
end

function modifier_autoattack:ShouldContinueAttacking()
  local unit = self.parent
  local attackTarget = unit:GetAttackTarget()

  if self.keep_target then
    return true
  end

  -- No attack target or order
  if not attackTarget or not unit.orderTable then
      return false
  end

  -- Manually ordered to attack this target
  if unit.orderTable['order_type'] == DOTA_UNIT_ORDER_ATTACK_TARGET and unit.orderTable['entindex_target'] == attackTarget:GetEntityIndex() then
      return true
  end

  return false
end

function GetTowerTarget(tower)
  local radius = tower:GetAcquisitionRange() + tower:GetHullRadius()

  local enemies = FindEnemiesInRadius(tower, radius)

  for _,enemy in pairs(enemies) do
    if tower:CanAttackTarget(enemy) then
      return enemy
    end
  end
end
