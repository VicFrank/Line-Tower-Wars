function InitializeLane(hero)
  GameRules.numLanes = GameRules.numLanes + 1
  local lane = GameRules.numLanes

  hero.lane = lane
  hero.waveSpawner = Entities:FindByName(nil, "wave_spawner" .. lane):GetAbsOrigin()
  hero.waveTarget = Entities:FindByName(nil, "wave_target" .. lane):GetAbsOrigin()

  local startPosition = Entities:FindByName(nil, "lane_spawn" .. lane):GetAbsOrigin()

  Timers:CreateTimer(function()
    FindClearSpaceForUnit(hero, startPosition, true)
  end)

  -- Create the lane object
  table.insert(GameRules.lanes, {
    lane = lane,
    hero = hero,
    spawner = waveSpawner,
    target = waveTarget,
  })

  print("Initialized Lane " .. lane)
end

function SendCreep(hero, unitname, income)
  local lane = hero.lane
  local laneToSend = GetNextLane(lane)
  local spawnLocation = laneToSend.spawner

  -- Spawn the creep
  local waveUnit = CreateUnitByName(unitname, spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
  waveUnit.lane = i

  -- Increase income
  hero:ModifyIncome(income)
end

function GetNextLane(laneNumber)
  local numLanes = #GameRules.lanes
  for i=1,numLanes do
    -- check the next lane in order, circling around
    local laneToCheck = (laneNumber + i) % numLanes
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
    SpawnWave()

    return waveDelay
  end)
end

function SpawnWave()
  local spawnDelay = 0.2

  for i = 1,GameRules.numLanes do
    local numToSpawn = 5
    local spawnLocation = Entities:FindByName(nil, "wave_spawner" .. i):GetAbsOrigin()

    Timers:CreateTimer(function()
      local waveUnit = CreateUnitByName("spider", spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
      waveUnit.lane = i

      numToSpawn = numToSpawn - 1
      if numToSpawn == 0 then return end

      return spawnDelay
    end)
  end
end