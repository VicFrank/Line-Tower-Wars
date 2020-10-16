function InitializeLane(hero)
  GameRules.numLanes = GameRules.numLanes + 1
  local lane = GameRules.numLanes

  hero.lane = lane
  hero.waveSpawner = Entities:FindByName(nil, "wave_spawner" .. lane):GetAbsOrigin()
  hero.waveTarget = Entities:FindByName(nil, "wave_target" .. lane):GetAbsOrigin()

  local startPosition = Entities:FindByName(nil, "lane_spawn" .. lane):GetAbsOrigin()

  Timers:CreateTimer(function()
    FindClearSpaceForUnit(hero, startPosition, true)

    -- Move the camera to the player
    PlayerResource:SetCameraTarget(hero:GetPlayerID(), hero)
    Timers:CreateTimer(0.1, function()
      PlayerResource:SetCameraTarget(hero:GetPlayerID(), nil)
    end)
  end)

  -- Create the lane object
  table.insert(GameRules.lanes, {
    laneNumber = lane,
    hero = hero,
    spawner = hero.waveSpawner,
    target = hero.waveTarget,
  })

  print("Initialized Lane " .. lane)
end

function SendCreep(hero, unitname, income)
  local laneNumber = hero.lane
  local laneToSend = GetNextLane(laneNumber)
  local spawnLocation = laneToSend.spawner

  -- In tools, send to sender's lane
  if IsInToolsMode() then
    local senderLane = GetLane(laneNumber)
    local senderSpawn = senderLane.spawner

    local waveUnit = CreateUnitByName(unitname, senderSpawn, true, nil, nil, DOTA_TEAM_NEUTRALS)
    waveUnit.lane = laneNumber
  end

  -- Spawn the creep
  local waveUnit = CreateUnitByName(unitname, spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
  waveUnit.lane = laneToSend.laneNumber
  waveUnit.sender = hero

  hero.numSent = hero.numSent + 1

  print(hero.numSent)

  -- Increase income
  hero:ModifyIncome(income)

  return waveUnit
end

function OnCreepReachedGoal(creep)
  local lane = GetLane(creep.lane)
  local hero = lane.hero
  local laneNumber = lane.laneNumber

  -- This should only be true when testing in tools mode and spawning test waves
  if not creep.sender then
    creep:ForceKill(false)
    creep:AddNoDraw()
    return
  end

  local nextLane = GetNextLane(laneNumber)
  local nextLaneNumber = nextLane.laneNumber
  local sender = creep.sender
  local senderLaneNumber = sender.lane

  local damage = 1
  if IsInToolsMode() then damage = 0 end

  -- Move the creep to the next lane
  if senderLaneNumber == nextLaneNumber then
    -- If we've looped all the way around, just kill the creep
    creep:ForceKill(false)
    creep:AddNoDraw()
  else
    local spawnLocation = nextLane.spawner
    FindClearSpaceForUnit(creep, spawnLocation, true)
    creep.lane = nextLaneNumber
  end

  -- Damage the hero on this lane
  if IsValidAlive(hero) then
    local player = PlayerResource:GetPlayer(hero:GetPlayerID())
    EmitSoundOnClient("General.CompendiumLevelUpMinor", player)

    hero:SetHealth(hero:GetHealth() - damage)
    if hero:GetHealth() <= 0 then
      hero:ForceKill(true)
      hero:AddNoDraw()
      GameMode:OnHeroKilled(hero)
    end

    SendOverheadEventMessage(hero, OVERHEAD_ALERT_LAST_HIT_MISS, hero, damage, nil)
    ScreenShake(hero:GetAbsOrigin(), 5, 150, 0.25, 2000, 0, true)

    -- Heal the sender, only if the player we're damaging is still alive
    if IsValidAlive(sender) then
      sender:AddHealth(damage)
      SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, sender, damage, nil) 
    end
  end
end

function GetNextLane(laneNumber)
  local numLanes = #GameRules.lanes
  for i=0,numLanes-1 do
    -- check the next lane in order, circling around
    local laneToCheck = ((laneNumber + i) % numLanes) + 1
    local lane = GameRules.lanes[laneToCheck]

    if IsValidAlive(lane.hero) then
      -- We found the lane
      return lane
    end
  end
end

function GetLane(laneNumber)
  return GameRules.lanes[laneNumber]
end