"use strict";

var localPlayerID = Players.GetLocalPlayer();
var rootPanel = $("#Avatars");

for (var i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
  if (Game.GetPlayerInfo(i)) {
    var steam_id = Game.GetPlayerInfo(i).player_steamid;
    var team = Players.GetTeam(i);
    var hero = Players.GetPlayerSelectedHero(i);

    createPlayerPanel(i, steam_id);

    $("#player_avatar_" + i).steamid = steam_id;
  }
}

function createPlayerPanel(id, steam_id){
  $.Msg("Creating Panel " + id);
  var playerPanel = $.CreatePanel("Panel", rootPanel, "player_panel_" + id);
  playerPanel.AddClass("PlayerPanel");

  playerPanel.BCreateChildren(
    '<DOTAAvatarImage hittest="false" id="player_avatar_' + id + '" class="UserAvatar"/>',
    false,
    false
  );

  var UserInfoContainer = $.CreatePanel("Panel", playerPanel, "user_info" + id);
  UserInfoContainer.AddClass("UserInfoContainer");

  var usernamePanel = $.CreatePanel("DOTAUserName", UserInfoContainer, "username_player_" + id);
  usernamePanel.AddClass("Username");
  usernamePanel.steamid = steam_id;

  var HealthContainer = $.CreatePanel("Panel", UserInfoContainer, "health_panel" + id);
  HealthContainer.AddClass("HealthContainer");
  
  var HealthIconPanel = $.CreatePanel("Panel", HealthContainer, "health_icon" + id);
  HealthIconPanel.AddClass("HealthIcon");
  
  var HealthIconText = $.CreatePanel("Label", HealthContainer, "health_text" + id);
  HealthIconText.AddClass("HealthText");
  HealthIconText.text = "30"

  var GoldContainer = $.CreatePanel("Panel", UserInfoContainer, "gold_container" + id);
  GoldContainer.AddClass("GoldContainer");
  
  var GoldIconPanel = $.CreatePanel("Panel", GoldContainer, "gold_icon" + id);
  GoldIconPanel.AddClass("GoldIcon");
  
  var GoldIconText = $.CreatePanel("Label", GoldContainer, "gold_text" + id);
  GoldIconText.AddClass("GoldText");
  GoldIconText.text = Players.GetGold(id);
  
  var InterestText = $.CreatePanel("Label", GoldContainer, "interest_text" + id);
  InterestText.AddClass("InterestText");
}

function RoundToK(number) {
  var roundedNumber = number;

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
  for (var i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
    if (Game.GetPlayerInfo(i)) {
      var data = CustomNetTables.GetTableValue("player_stats", i);
      if (data) {
        var income = data.income;
        $("#interest_text" + i).text = "(+" +  RoundToK(income) + ")";
      }
    }
  }
}

function OnIncomeChanged(table_name, key, data) {
  var playerID = key;
  var income = data.income;

  $("#interest_text" + playerID).text = "(+" + RoundToK(income) + ")";
}

function OnGoldUpdated(table_name, key, data) {
  if (key.startsWith("gold")) {
    var playerID = key.substring(4);
    var gold = data.gold;
    UpdateGold(playerID, gold);
  }
}

function ResetGold() {
  for (var i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
    if (Game.GetPlayerInfo(i)) {
      var data = CustomNetTables.GetTableValue("custom_shop", "gold" + i);
      if (data) {
        var gold = data.gold;
        UpdateGold(i, gold);
      }
    }
  }
}

(function () {
  UpdateIncomes();
  ResetGold();

  CustomNetTables.SubscribeNetTableListener("player_stats", OnIncomeChanged);
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnGoldUpdated);
})();