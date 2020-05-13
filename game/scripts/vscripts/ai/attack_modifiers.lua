modifier_autoattack = class({})

function modifier_autoattack:DeclareFunctions()
  return { MODIFIER_PROPERTY_DISABLE_AUTOATTACK, }
end

function modifier_autoattack:OnCreated(params)
  if not IsServer() then return end

  local unit = self:GetParent()
  unit.attack_target = nil
  unit.disable_autoattack = 0
  self:StartIntervalThink(0.03)
end

function modifier_autoattack:GetDisableAutoAttack(params)
  local bDisabled = self:GetParent().disable_autoattack

  if bDisabled == 1 then
    if not self.thinking then
      self.thinking = true
      self:StartIntervalThink(0.1)
    end
  elseif self.thinking then
    self.thinking = false
    self:StartIntervalThink(0.03)
  end

  return bDisabled
end

function modifier_autoattack:OnIntervalThink()
  if not IsServer() then return end

  local unit = self:GetParent()
  AggroFilter(unit)
  
  -- Disabled autoattack state
  if unit.disable_autoattack == 1 then
    local enemies = FindEnemiesInRadius(unit, unit:GetAcquisitionRange())
    if #enemies > 0 then
      -- If an enemy is valid, attack it and stop the thinker
      for _,enemy in pairs(enemies) do
        if unit:CanAttackTarget(enemy) then
          -- print("[ATTACK] attacking unit from modifier_autoattack thinker")
          Attack(unit, enemy)
          return
        end
      end
    end
  end
end

function modifier_autoattack:IsHidden()
  return true
end

function modifier_autoattack:IsPurgable()
  return false
end

-------------------------------------------

function AggroFilter(unit)
  local target = unit:GetAttackTarget() or unit:GetAggroTarget()
  if not target then return end
  if unit:IsChanneling() then return end

  local bCanAttackTarget = unit:CanAttackTarget(target)
  if unit.disable_autoattack == 0 then
    -- The unit acquired a new attack target
    if target ~= unit.attack_target then
      if bCanAttackTarget then
        unit.attack_target = target --Update the target, keep the aggro
        return
      else
        -- Is there any enemy unit nearby the invalid one that this unit can attack?
        local enemies = FindEnemiesInRadius(unit, unit:GetAcquisitionRange())
        if #enemies > 0 then
          for _,enemy in pairs(enemies) do
            if unit:CanAttackTarget(enemy) then
              Attack(unit, enemy)
              return
            end
          end
        end
      end
    end
  end

  -- No valid enemies, disable autoattack. 
  if not bCanAttackTarget then
    DisableAggro(unit)
  end
end

-- Disable autoattack and stop any aggro
function DisableAggro(unit)
  unit.disable_autoattack = 1
  if unit:GetAggroTarget() then
    unit:Stop() --Unit will still turn for a frame towards its invalid target
  end

  -- Resume attack move order
  if unit.current_order == DOTA_UNIT_ORDER_ATTACK_MOVE then
    unit.skip = true
    local orderTable = unit.orderTable
    local x = tonumber(orderTable["position_x"])
    local y = tonumber(orderTable["position_y"])
    local z = tonumber(orderTable["position_z"])
    local point = Vector(x,y,z) 
    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = point, Queue = false})
  end
end

-- Aggro a target
function Attack(unit, target)
  unit:MoveToTargetToAttack(target)
  unit.attack_target = target
  unit.disable_autoattack = 0
end