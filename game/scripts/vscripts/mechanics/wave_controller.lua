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

  -- Spawn the creep
  local waveUnit = CreateUnitByName(unitname, spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
  waveUnit.lane = laneToSend.laneNumber

  -- Increase income
  hero:ModifyIncome(income)

  return waveUnit
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

function StartSpawning()
  if GameRules.SpawningWaves then return end
  GameRules.SpawningWaves = true

  local waveDelay = 30

  Timers:CreateTimer(function()
    SpawnWave("radiant_creep", 5)

    return waveDelay
  end)
end

function SpawnWave(creepName, count)
  local spawnDelay = 0.2
  local count = count or 1

  if not creepName then return end

  for i = 1,GameRules.numLanes do
    local numToSpawn = count
    local spawnLocation = Entities:FindByName(nil, "wave_spawner" .. i):GetAbsOrigin()

    Timers:CreateTimer(function()
      local waveUnit = CreateUnitByName(creepName, spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
      waveUnit.lane = i

      numToSpawn = numToSpawn - 1
      if numToSpawn == 0 then return end

      return spawnDelay
    end)
  end
end