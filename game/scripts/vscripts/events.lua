function GameMode:OnGameRulesStateChange()
  local nNewState = GameRules:State_Get()
  if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
    print( "[PRE_GAME] in Progress" )
  elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end
end

function GameMode:OnGameInProgress()
  StartSpawning()
end

function GameMode:OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)

  -- Ignore specific units
  local unitName = npc:GetUnitName()
  if unitName == "npc_dota_thinker" then return end
  if unitName == "npc_dota_units_base" then return end
  if unitName == "dotacraft_corpse" then return end
  if unitName == "" then return end

  if npc:IsHero() then
    npc:SetAbilityPoints(0)

    Timers:CreateTimer(.03, function()
      for i=0,16 do
        local item = hero:GetItemInSlot(i)
        if item ~= nil then
          item:RemoveSelf()
        end
      end
    end)
  end

  for i=0,16 do
    local ability = npc:GetAbilityByIndex(i)
    if ability then
      local level = math.min(ability:GetMaxLevel(), npc:GetLevel())
      ability:SetLevel(level)
    end
  end
end

function GameMode:OnHeroInGame(hero)
end

function GameMode:OnEntityKilled(keys)
  local killed = EntIndexToHScript(keys.entindex_killed)
  local killer = nil

  if keys.entindex_attacker ~= nil then
    killer = EntIndexToHScript( keys.entindex_attacker )
  end
end

function GameMode:OnConnectFull(keys)
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
  local userID = keys.userid

  if playerID < 0 then return end

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply
  print(playerID .. " connected")
end

function GameMode:OnConstructionCompleted(building, ability, isUpgrade, previousIncomeValue)
  local buildingType = building:GetBuildingType()
  local hero = building:GetOwner()
  local playerID = building:GetPlayerOwnerID()
end