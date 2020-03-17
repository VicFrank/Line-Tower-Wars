function AddNewLane(hero)
  GameRules.numLanes = GameRules.numLanes + 1
  local lane = GameRules.numLanes

  lane = 1

  hero.lane = lane
  hero.waveSpawner = Entities:FindByName(nil, "wave_spawner" .. lane):GetAbsOrigin()
  hero.waveTarget = Entities:FindByName(nil, "wave_target" .. lane):GetAbsOrigin()

  local startPosition = Entities:FindByName(nil, "lane_spawn" .. lane):GetAbsOrigin()

  FindClearSpaceForUnit(hero, startPosition, true)

  print("Initialized Lane " .. lane)
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
  local numToSpawn = 5
  local spawnDelay = 0.2

  local lane = 1
  local spawnLocation = Entities:FindByName(nil, "wave_spawner" .. lane):GetAbsOrigin()

  Timers:CreateTimer(function()
    local waveUnit = CreateUnitByName("spider", spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
    waveUnit.lane = lane

    numToSpawn = numToSpawn - 1
    if numToSpawn == 0 then return end

    return spawnDelay
  end)
end