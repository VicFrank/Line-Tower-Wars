if GameMode == nil then
  _G.GameMode = class({})
end

require('libraries/timers')
require('libraries/notifications')
require('libraries/selection')
require("libraries/buildinghelper")
require("libraries/animations")

require("mechanics/units")
require("mechanics/wave_controller")
require("mechanics/income")
require("mechanics/resources")

require("shop/custom_shop")

require("filters/damage_filter")
require("filters/order_filter")

local PrecacheTables = require("tables/precache_tables")

require("testing")
require("events")
require("constants")
require("triggers")
require("utility_functions")

function Precache( context )
  PrecacheResource("particle_folder", "particles/buildinghelper", context)

  -- General Precaches
  PrecacheResource("particle", "particles/custom/construction_dust.vpcf", context)
  
  -- Sounds
  -- PrecacheResource( "soundfile", "soundevents/game_sounds.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_main.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_greevils.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_items.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_ambient.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_cny.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_creeps.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_frostivus.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_hero_pick.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_roshan_halloween.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/game_sounds_ui_imported.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/soundevents_dota.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/soundevents_dota_ui.vsndevts", context )
  -- PrecacheResource( "soundfile", "soundevents/soundevents_minigames.vsndevts", context )

  -- Precache all towers
  -- for _,tower in pairs(PrecacheTables.towers) do
  --   PrecacheUnitByNameSync(tower, context)
  -- end

  -- Precache all creeps
  for _,tier in pairs(PrecacheTables.creeps) do
    for _,creep in pairs(tier) do
      PrecacheUnitByNameSync(creep, context)
    end
  end
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
  GameMode.Initialized = true

  if IsInToolsMode() then
    Timers:CreateTimer(1, function()
      Tutorial:AddBot("npc_dota_hero_kunkka", "", "", false)
    end)
  end
end

-- Runs this code on every script reload
if GameMode.Initialized then
  GameMode:OnScriptReload()
end

function GameMode:InitGameMode()
  GameMode = self

  LimitPathingSearchDepth(0.25)

  GameRules:SetCustomGameAllowMusicAtGameStart(true)
  GameRules:SetCustomGameAllowBattleMusic(true)
  GameRules:SetCustomGameAllowHeroPickMusic(false)
  GameRules:EnableCustomGameSetupAutoLaunch(true)
  GameRules:SetSameHeroSelectionEnabled(false)
  GameRules:SetHideKillMessageHeaders(true)
  GameRules:SetUseUniversalShopMode(false)
  GameRules:SetHeroRespawnEnabled(false)
  GameRules:SetSafeToLeave(true)
  GameRules:SetCustomGameSetupAutoLaunchDelay(25)
  GameRules:SetCustomGameEndDelay(0)
  GameRules:SetHeroSelectionTime(0)
  GameRules:SetPreGameTime(0)
  GameRules:SetStrategyTime(0)
  GameRules:SetShowcaseTime(0)
  GameRules:SetGoldTickTime(0)
  GameRules:SetStartingGold(STARTING_GOLD)
  GameRules:SetGoldPerTick(0)

  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,  1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_3, 1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_4, 1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_5, 1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_6, 1)

  self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }		--		Yellow
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"

  -- -- Set game mode rules
  mode = GameRules:GetGameModeEntity()
  mode:DisableHudFlip(true)
  mode:SetBuybackEnabled(false)
  mode:SetFogOfWarDisabled(true)
  mode:SetLoseGoldOnDeath(false)
  mode:SetAnnouncerDisabled(true)
  mode:SetDeathOverlayDisabled(true)
  mode:SetDaynightCycleDisabled(true)
  mode:SetWeatherEffectsDisabled(true)
  mode:SetUnseenFogOfWarEnabled(false)
  mode:SetRemoveIllusionsOnDeath(true)
  mode:SetStashPurchasingDisabled(true)
  mode:SetTopBarTeamValuesVisible(false)
  mode:SetTopBarTeamValuesOverride(true)
  mode:SetRecommendedItemsDisabled(true)
  mode:SetSelectionGoldPenaltyEnabled(false)
  mode:SetKillingSpreeAnnouncerDisabled(true)
  mode:SetCustomGameForceHero("npc_dota_hero_kunkka")

  -- Event Hooks
  ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, 'OnConnectFull'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('player_chat', Dynamic_Wrap(GameMode, 'OnPlayerChat'), self)

  -- Custom Event Hooks
  CustomGameEventManager:RegisterListener('attempt_purchase', OnAttemptPurchase)
  CustomGameEventManager:RegisterListener('attempt_research_purchase', OnAttemptResearch)
  CustomGameEventManager:RegisterListener('buy_research_point', BuyResearchPoint)

  -- Filters
  mode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
  mode:SetDamageFilter(Dynamic_Wrap(GameMode, "FilterDamage"), self)

  -- Lua Modifiers
  LinkLuaModifier("modifier_disable_turning", "libraries/modifiers/modifier_disable_turning", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_under_construction", "libraries/modifiers/modifier_under_construction", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_wave_creep", "libraries/modifiers/modifier_wave_creep", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("income_modifier", "abilities/modifiers/income_modifier", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_splash", "abilities/modifiers/modifier_splash", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_autoattack", "ai/attack_modifiers", LUA_MODIFIER_MOTION_NONE)

  GameRules.vUserIds = {}

  GameRules.roundStartTime = 0
  GameRules.playerIDs = {}
  GameRules.numToCache = 0
  GameRules.precached = {}
  GameRules.income = {}

  GameRules.numLanes = 0
  GameRules.lanes = {}

  -- Modifier Applier
  GameRules.Applier = CreateItem("item_apply_modifiers", nil, nil)

  GameRules.Damage = LoadKeyValues("scripts/kv/damage_table.kv")
  GameRules.ConstructionAbilities = LoadKeyValues("scripts/npc/buildings/construction_abilities.kv")

  GameMode:InitializeShopData()
  GameMode:InitializeAttacks()
  GameMode:SetupCustomAbilityCosts()
end

function GameMode:InitializeAttacks()
  for name,values in pairs(GameRules.UnitKV) do
    if type(values)=="table" and values['AttacksEnabled'] then
      CustomNetTables:SetTableValue("attacks_enabled", name, {enabled = values['AttacksEnabled']})
    end
  end
end

function GameMode:SetupCustomAbilityCosts()
  for abilityName, abilityKeys in pairs(GameRules.ConstructionAbilities) do
    if abilityKeys and type(abilityKeys) == "table" then
      local gold = tonumber(abilityKeys.GoldCost) or 0
      CustomNetTables:SetTableValue("building_settings", abilityName, {
        goldCost = gold,
      })
    end
  end

  CustomGameEventManager:Send_ServerToAllClients("init_ability_prices", {})
end