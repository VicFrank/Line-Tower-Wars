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

require("testing")
require("events")
require("constants")
require("triggers")
require("utility_functions")

function Precache( context )
  --[[
  PrecacheResource( "model", "*.vmdl", context )
  PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheModel("models/heroes/viper/viper.vmdl", context)

  PrecacheResource( "soundfile", "*.vsndevts", context )
  PrecacheResource( "particle", "*.vpcf", context )
  PrecacheResource( "particle_folder", "particles/folder", context )

  Entire items can be precached by name
  Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("item_rune_heal", context)

  Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  ]]

  PrecacheResource("particle_folder", "particles/buildinghelper", context)

  -- General Precaches
  PrecacheResource("particle", "particles/custom/construction_dust.vpcf", context)

  PrecacheUnitByNameSync("archer_tower_1", context)
  
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
  print("Castle Fight has loaded.")

  LimitPathingSearchDepth(0.5)

  GameRules:SetCustomGameAllowMusicAtGameStart(true)
  GameRules:SetCustomGameAllowBattleMusic(true)
  GameRules:SetCustomGameAllowHeroPickMusic(false)
  GameRules:EnableCustomGameSetupAutoLaunch(true)
  GameRules:SetSameHeroSelectionEnabled(false)
  GameRules:SetHideKillMessageHeaders(true)
  GameRules:SetUseUniversalShopMode(false)
  GameRules:SetHeroRespawnEnabled(false)
  GameRules:SetSafeToLeave(true)
  GameRules:SetCustomGameSetupAutoLaunchDelay(30)
  GameRules:SetCustomGameEndDelay(0)
  GameRules:SetHeroSelectionTime(0)
  GameRules:SetPreGameTime(0)
  GameRules:SetStrategyTime(0)
  GameRules:SetShowcaseTime(0)
  GameRules:SetGoldTickTime(0)
  GameRules:SetStartingGold(65)
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

  -- Filters
  -- mode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)

  -- Lua Modifiers
  LinkLuaModifier("modifier_disable_turning", "libraries/modifiers/modifier_disable_turning", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_under_construction", "libraries/modifiers/modifier_under_construction", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("income_modifier", "abilities/generic/income_modifier", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_hide_hero", "abilities/modifiers/modifier_hide_hero", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_stunned_custom", "abilities/modifiers/modifier_stunned_custom", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_end_round", "abilities/modifiers/modifier_end_round", LUA_MODIFIER_MOTION_NONE)

  self.vUserIds = {}

  GameRules.roundStartTime = 0
  GameRules.playerIDs = {}
  GameRules.numToCache = 0
  GameRules.precached = {}
  GameRules.income = {}

  GameRules.numLanes = 0

  -- Modifier Applier
  GameRules.Applier = CreateItem("item_apply_modifiers", nil, nil)
end