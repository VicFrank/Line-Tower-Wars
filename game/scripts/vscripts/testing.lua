function GameMode:OnScriptReload()
  print("Script Reload")

  for _,hero in pairs(HeroList:GetAllHeroes()) do
  end
end

function KillAllUnits()
  for _,unit in pairs(FindAllUnits()) do
    if not IsCustomBuilding(unit) and not unit:IsHero() then
      unit:ForceKill(false)
    end
  end
end

function KillAllBuildings()
  for _,unit in pairs(FindAllUnits()) do
    if IsCustomBuilding(unit) and unit:GetUnitName() ~= "castle" then
      unit:ForceKill(false)
    end
  end
end

function KillEverything()
  for _,unit in pairs(FindAllUnits()) do
    if not unit:IsHero() and unit:GetUnitName() ~= "castle" then
      unit:ForceKill(false)
    end
  end
end

function GameMode:GreedIsGood(playerID, value)
  value = tonumber(value) or 500
  for _,hero in pairs(HeroList:GetAllHeroes()) do
    if hero:IsAlive() then
      hero:ModifyCustomGold(value)
    end
  end
end

function GameMode:GiveGold(playerID, value)
  value = tonumber(value) or 0
  ModifyCustomGold(playerID, value)
end

function GameMode:Spawn(playerID, unitname, count)
  SpawnWave(unitname, count)
end

function GameMode:Reset()
  GameRules.leftRoundsWon = 0
  GameRules.rightRoundsWon = 0
  GameRules.roundCount = 0
  GameMode:EndRound(DOTA_TEAM_NEUTRALS)
end


CHEAT_CODES = {
  ["greedisgood"] = function(...) GameMode:GreedIsGood(...) end,   -- "Gives you X gold or 500"
  ["gold"] = function(...) GameMode:GiveGold(...) end,             -- "Gives you X gold"
  ["killallunits"] = function(...) KillAllUnits() end,             -- "Kills all units"
  ["killallbuildings"] = function(...) KillAllBuildings() end,     -- "Kills all buildings"
  ["spawn"] = function(...) GameMode:Spawn(...) end,               -- "Spawns units in each lane"
}

function GameMode:OnPlayerChat(keys)
  local text = keys.text
  local userID = keys.userid
  local playerID = self.vUserIds[userID] and self.vUserIds[userID]:GetPlayerID()
  if not playerID then return end

  -- Cheats are only available in the tools
  if not GameRules:IsCheatMode() then return end

  -- Handle '-command'
  if StringStartsWith(text, "-") then
    text = string.sub(text, 2, string.len(text))
  end

  local input = split(text)
  local command = input[1]
  if CHEAT_CODES[command] then
    CHEAT_CODES[command](playerID, input[2], input[3], input[4], input[5])
  end
end