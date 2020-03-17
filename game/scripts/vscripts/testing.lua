function GameMode:OnScriptReload()
  print("Script Reload")

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
      hero:ModifyGold(value, false, DOTA_ModifyGold_CheatCommand)
    end
  end
end

function GameMode:SpawnUnits(playerID, unitname, count)
  local position = Vector(0,0,0)
  local team = PlayerResource:GetTeam(playerID)

  count = tonumber(count) or 1

  if count < 0 then
    count = count * -1
    team = GetOpposingTeam(team)
  end

  unitname = UnitTypeToUnitName(unitname)

  for i=1,count do
    CreateUnitByName(unitname, position, true, nil, nil, team)
  end
end

function GameMode:Reset()
  GameRules.leftRoundsWon = 0
  GameRules.rightRoundsWon = 0
  GameRules.roundCount = 0
  GameMode:EndRound(DOTA_TEAM_NEUTRALS)
end


CHEAT_CODES = {
  ["greedisgood"] = function(...) GameMode:GreedIsGood(...) end,           -- "Gives you X gold and lumber"
  ["killallunits"] = function(...) KillAllUnits() end,                     -- "Kills all units"
  ["killallbuildings"] = function(...) KillAllBuildings() end,             -- "Kills all buildings"
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