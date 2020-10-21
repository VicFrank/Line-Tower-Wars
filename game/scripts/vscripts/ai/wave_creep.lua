function Spawn(keys)
  -- Wait one frame to do logic on a spawned unit
  Timers:CreateTimer(.1, function()
    Timers:CreateTimer(function() return thisEntity:AIThink() end)
  end)
end

function thisEntity:AIThink()
  if self:IsNull() then return end
  if not self:IsAlive() then return end

  if GameRules:IsGamePaused() then
    return 0.1
  end

  return self:MoveTowardsGoal()
end

function thisEntity:SetGoal(goal)
  self.goal = goal
  self:MoveTowardsGoal()
end

function thisEntity:MoveTowardsGoal()
  if not self.goal then return 1 end

  self:MoveToPositionAggressive(self.goal)

  return 1
end