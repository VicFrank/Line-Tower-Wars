function GameMode:OnGameRulesStateChange()
  local nNewState = GameRules:State_Get()
  if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
    print( "[PRE_GAME] in Progress" )
  elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end
end

function GameMode:OnGameInProgress()
  -- StartTestSpawning()
  GameMode:StartPayingIncome()
  GameMode:SpawnLaneTruesight()
end

function GameMode:OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)

  -- Ignore specific units
  local unitName = npc:GetUnitName()
  if unitName == "npc_dota_thinker" then return end
  if unitName == "npc_dota_units_base" then return end
  if unitName == "dotacraft_corpse" then return end
  if unitName == "" then return end

  if npc:IsCourier() then
    return
  end

  if npc:IsHero() then
    GameMode:OnHeroInGame(npc)
  end

  Timers:CreateTimer(0.1, function()
    if not IsCustomBuilding(npc) then
      npc:AddNewModifier(npc, nil, "modifier_wave_creep", {})
    else
      -- Async precach buildings when they're built
      -- Note that this crashes the game xd
      -- if not GameRules.precached[unitName] then
      --   GameRules.numToCache = GameRules.numToCache + 1
      --   PrecacheUnitByNameAsync(unitName, function(unitName)
      --     GameRules.numToCache = GameRules.numToCache - 1
      --     print(GameRules.numToCache)
      --   end)

      --   GameRules.precached[unitName] = true
      -- end
    end
  end)

  -- deactive abilities that aren't researched yet
  npc:UpdateResearchAbilitiesActive()

  for i=0,16 do
    local ability = npc:GetAbilityByIndex(i)
    if ability then
      local level = math.min(ability:GetMaxLevel(), npc:GetLevel())
      ability:SetLevel(level)
    end
  end

  Units:Init(npc)
end

function GameMode:OnHeroInGame(hero)
  InitializeLane(hero)

  hero:SetAbilityPoints(0)
  hero:ModifyIncome(STARTING_INCOME)
  GameMode:SetupShopForPlayer(hero:GetPlayerOwnerID())

  -- set the model to be the player's courier
  local player = hero:GetPlayerOwner()
  local courier = player:SpawnCourierAtPosition(hero:GetAbsOrigin())
  local model = courier:GetModelName()

  courier:RemoveSelf()

  hero:SetOriginalModel(model)
  hero:SetModel(model)

  hero.numSent = 0

  Timers:CreateTimer(.03, function()
    hero:SetCustomGold(STARTING_GOLD)
    
    for i=0,16 do
      local item = hero:GetItemInSlot(i)
      if item ~= nil then
        item:RemoveSelf()
      end
    end
  end)
end

function GameMode:OnEntityKilled(keys)
  local killed = EntIndexToHScript(keys.entindex_killed)
  local killer = nil

  if keys.entindex_attacker ~= nil then
    killer = EntIndexToHScript(keys.entindex_attacker)
  end

  if IsValidAlive(killed.sender) then
    local sender = killed.sender
    sender.numSent = sender.numSent - 1
  end
  
  local bounty = killed:GetGoldBounty()

  if killer and bounty and not (killer:GetEntityIndex() == killed:GetEntityIndex()) then
    local playerID = killer:GetPlayerOwnerID()
    if playerID >= 0 and bounty then
      ModifyCustomGold(playerID, bounty)
    end
  end

  if killed:IsRealHero() then
    GameMode:OnHeroKilled(killed)
  end
end

function GameMode:OnHeroKilled(hero)
  local playerID = hero:GetPlayerOwnerID()
  -- Destroy all their buildings
  -- get a deep copy since we'll be removing buildings from the table as we delete them
  local buildings = deepcopy(BuildingHelper:GetBuildings(playerID))

  for _,building in pairs(buildings) do
    if IsValidAlive(building) then
      -- building:AddEffects(EF_NODRAW)
      building:ForceKill(true)
    end
  end

  -- Check if we have a winner
  local numAlive = 0
  local winner
  for _,playerHero in pairs(HeroList:GetAllHeroes()) do
    if playerHero:IsAlive() then
      numAlive = numAlive + 1
      winner = playerHero
    end
  end

  if numAlive == 1 then
    GameRules:SetGameWinner(winner:GetTeam())
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

  GameRules.vUserIds = GameRules.vUserIds or {}
  GameRules.vUserIds[userID] = ply
  print(playerID .. " connected")
end

function GameMode:OnConstructionCompleted(building, ability, isUpgrade, previousIncomeValue)
  local hero = building:GetOwner()
  local playerID = building:GetPlayerOwnerID()
end