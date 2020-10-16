function OnStartTouch(trigger)
  local activator = trigger.activator

  OnCreepReachedGoal(activator)

  return true
end