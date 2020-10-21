function GetLaneNumberForTeam(team)
  if team == DOTA_TEAM_GOODGUYS then return 1
  elseif team == DOTA_TEAM_BADGUYS then return 2
  elseif team == DOTA_TEAM_CUSTOM_1 then return 3
  elseif team == DOTA_TEAM_CUSTOM_2 then return 4
  elseif team == DOTA_TEAM_CUSTOM_3 then return 5
  elseif team == DOTA_TEAM_CUSTOM_4 then return 6
  elseif team == DOTA_TEAM_CUSTOM_5 then return 7
  elseif team == DOTA_TEAM_CUSTOM_6 then return 8
  end

  print("Invalid team for lane ", team)
end

function InitializeLane(hero)
  GameRules.numLanes = GameRules.numLanes + 1

  local lane = GetLaneNumberForTeam(hero:GetTeam())

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
  local laneData = {
    laneNumber = lane,
    hero = hero,
    spawner = hero.waveSpawner,
    target = hero.waveTarget,
  }

  GameRules.lanes[lane] = laneData

  print("Initialized Lane " .. lane)
end

function GameMode:SpawnLaneTruesight()
  -- truesight appears to work for all teams
  -- for _,hero in pairs(HeroList:GetAllHeroes()) do
  --   local team = hero:GetTeam()
  --   for _,lane in pairs(GameRules.lanes) do
  --     if lane.laneNumber ~= hero.laneNumber then
  --       local position1 = lane.spawner
  --       local position2 = lane.target
  --       CreateUnitByName("truesight_dummy_unit", position1, true, nil, nil, team)
  --       CreateUnitByName("truesight_dummy_unit", position2, true, nil, nil, team)
  --     end
  --   end
  -- end
end

function SendCreep(hero, unitname, income)
  local laneNumber = hero.lane
  local laneToSend = GetNextLane(laneNumber)
  local goal = laneToSend.target
  local spawnLocation = laneToSend.spawner

  -- In tools, send to sender's lane
  if IsInToolsMode() then
    local senderLane = GetLane(laneNumber)
    local senderSpawn = senderLane.spawner

    local waveUnit = CreateUnitByName(unitname, senderSpawn, true, nil, nil, DOTA_TEAM_NEUTRALS)
    waveUnit.lane = laneNumber
    waveUnit:SetGoal(senderLane.target)
  end

  -- Spawn the creep
  local team = hero:GetTeam()
  if TableCount(GameRules.vUserIds) == 1 then team = DOTA_TEAM_NEUTRALS end
  local waveUnit = CreateUnitByName(unitname, spawnLocation, true, nil, nil, team)
  waveUnit.lane = laneToSend.laneNumber
  waveUnit.sender = hero
  waveUnit:SetGoal(goal)

  hero.numSent = hero.numSent + 1

  -- Increase income
  hero:ModifyIncome(income)

  return waveUnit
end

function OnCreepReachedGoal(creep)
  local lane = GetLane(creep.lane)
  local hero = lane.hero
  local laneNumber = lane.laneNumber -- current lane

  -- This should only be true when testing in tools mode and spawning test waves
  if not creep.sender then
    creep:ForceKill(false)
    creep:AddNoDraw()
    return
  end

  local nextLane = GetNextLane(laneNumber)
  local nextLaneNumber = nextLane.laneNumber -- next lane
  local sender = creep.sender
  local senderLaneNumber = sender.lane -- lane of the sender

  local damage = 1
  if TableCount(GameRules.vUserIds) == 1 then damage = 0 end

  if senderLaneNumber == nextLaneNumber then
    -- If we've looped all the way around, just kill the creep
    creep:ForceKill(false)
    creep:AddNoDraw()
  else
    -- Move the creep to the next lane
    local spawnLocation = nextLane.spawner
    FindClearSpaceForUnit(creep, spawnLocation, true)
    creep.lane = nextLaneNumber
    creep:SetGoal(nextLane.target)
  end

  -- Damage the hero on this lane
  if IsValidAlive(hero) then
    local player = PlayerResource:GetPlayer(hero:GetPlayerID())
    EmitSoundOnClient("General.CompendiumLevelUpMinor", player)

    hero:ModifyHealth(hero:GetHealth() - damage, nil, true, 0)
    -- if hero:GetHealth() <= 0 then
    --   hero:ForceKill(true)
    --   hero:AddNoDraw()
    --   GameMode:OnHeroKilled(hero)
    -- end

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
  local numLanes = 8
  for i=0,numLanes-1 do
    -- check the next lane in order, circling around
    local laneToCheck = ((laneNumber + i) % numLanes) + 1
    local lane = GetLane(laneToCheck)

    if lane and IsValidAlive(lane.hero) then
      -- We found the lane
      return lane
    end
  end
end

function GetLane(laneNumber)
  return GameRules.lanes[laneNumber]
end