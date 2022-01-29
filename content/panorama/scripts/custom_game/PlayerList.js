"use strict";

var rootPanel = $("#Avatars");

var LocalPlayerID = Players.GetLocalPlayer();
var playerPanels = [];

function Initialize() {
  // Delete existing player panels
  rootPanel.RemoveAndDeleteChildren();
  playerPanels = [];

  let players = [];

  for (let i = 0; i < 8; i++){
    if (Game.GetPlayerInfo(i)) {
      let steam_id = Game.GetPlayerInfo(i).player_steamid;
      let team = Players.GetTeam(i);

      players.push({
        steam_id,
        playerID: i,
        team,
      })
    }
  }

  players.sort(function(a,b) {
    return a.team - b.team;
  });

  players.forEach(function(playerInfo) {
    let steam_id = playerInfo.steam_id;
    let playerID = playerInfo.playerID;

    let playerPanel = CreatePlayerPanel(playerID, steam_id);
    playerPanels.push(playerPanel);
  });
}

function CreatePlayerPanel(id, steam_id) {
  // $.Msg("Creating Panel " + id);
  let isLocal = id == LocalPlayerID;

  let playerPanel = $.CreatePanel("Panel", rootPanel, "PlayerPanel");
  playerPanel.SetHasClass("IsLocalPlayer", isLocal);
  playerPanel.playerID = id;

  let AvatarContainer = $.CreatePanel("Panel", playerPanel, "");
  AvatarContainer.AddClass("AvatarContainer");

  $.CreatePanelWithProperties(
    "DOTAAvatarImage",
    AvatarContainer,
    `player_avatar_${id}`,
    {
      hittest: false,
      class: "UserAvatar"
    }
  );

  let AvatarPanel = $("#player_avatar_" + id);
  AvatarPanel.steamid = steam_id;

  let DisconnectedIcon = $.CreatePanel("Panel", AvatarContainer, "DisconnectedIcon");
  // DisconnectedIcon.AddClass("DisconnectedIcon");

  let UserInfoContainer = $.CreatePanel("Panel", playerPanel, "user_info" + id);
  UserInfoContainer.AddClass("UserInfoContainer");

  let usernamePanel = $.CreatePanel("DOTAUserName", UserInfoContainer, "Username");
  usernamePanel.steamid = steam_id;

  let HealthContainer = $.CreatePanel("Panel", UserInfoContainer, "health_panel" + id);
  HealthContainer.AddClass("HealthContainer");
  
  let HealthIconPanel = $.CreatePanel("Panel", HealthContainer, "health_icon" + id);
  HealthIconPanel.AddClass("HealthIcon");
  
  let HealthIconText = $.CreatePanel("Label", HealthContainer, "health_text" + id);
  HealthIconText.AddClass("HealthText");
  HealthIconText.text = "25"

  let GoldContainer = $.CreatePanel("Panel", UserInfoContainer, "gold_container" + id);
  GoldContainer.AddClass("GoldContainer");
  
  let GoldIconPanel = $.CreatePanel("Panel", GoldContainer, "gold_icon" + id);
  GoldIconPanel.AddClass("GoldIcon");
  
  let GoldIconText = $.CreatePanel("Label", GoldContainer, "gold_text" + id);
  GoldIconText.AddClass("GoldText");
  GoldIconText.text = Players.GetGold(id);
  
  let InterestText = $.CreatePanel("Label", GoldContainer, "interest_text" + id);
  InterestText.AddClass("InterestText");

  return playerPanel;
}

function RoundToK(number) {
  let roundedNumber = number;

  if (roundedNumber > 10000) {
    roundedNumber = Math.floor(roundedNumber / 1000);
    roundedNumber = roundedNumber + "k";
  } else {
    roundedNumber = Math.floor(number);
  }

  return roundedNumber;
}

function UpdateGold(playerID, gold) {
  $("#gold_text" + playerID).text = RoundToK(gold);
}

function UpdateIncomes() {
  for (let i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
    if (Game.GetPlayerInfo(i)) {
      let data = CustomNetTables.GetTableValue("player_stats", i);
      if (data) {
        let income = data.income;
        $("#interest_text" + i).text = "(+" +  RoundToK(income) + ")";
      }
    }
  }
}

function OnIncomeChanged(table_name, key, data) {
  let playerID = key;
  let income = data.income;

  $("#interest_text" + playerID).text = "(+" + RoundToK(income) + ")";
}

function OnGoldUpdated(table_name, key, data) {
  if (key.startsWith("gold")) {
    let playerID = key.substring(4);
    let gold = data.gold;
    UpdateGold(playerID, gold);
  }
}

function ResetGold() {
  for (let i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
    if (Game.GetPlayerInfo(i)) {
      let data = CustomNetTables.GetTableValue("custom_shop", "gold" + i);
      if (data) {
        let gold = data.gold;
        UpdateGold(i, gold);
      }
    }
  }
}

function UpdatePanels() {
  for(let i=0; i<playerPanels.length; i++) {
    let panel = playerPanels[i];
    const playerID = panel.playerID;
    
    let connectionState = Game.GetPlayerInfo(playerID).player_connection_state;
    let isDisconnected = connectionState != DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED

    panel.SetHasClass("Disconnected", isDisconnected);

    if (Game.GetPlayerInfo(playerID)) {
      let hero = Players.GetPlayerHeroEntityIndex(playerID);
      let HealthIconText = $("#health_text" + playerID);
      const health = Entities.GetHealth(hero);

      HealthIconText.text = health;

      panel.SetHasClass("IsDead", health <= 0);
    }
  }

  $.Schedule(1.0/30.0, UpdatePanels);
}

(function () {
  Initialize();
  UpdateIncomes();
  UpdatePanels();
  ResetGold();

  CustomNetTables.SubscribeNetTableListener("player_stats", OnIncomeChanged);
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnGoldUpdated);
})();