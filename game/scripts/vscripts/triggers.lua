function OnStartTouch(trigger)
  local activator = trigger.activator

  if activator:IsRealHero() then return end
  if not activator.lane then return end

  OnCreepReachedGoal(activator)

  return true
end