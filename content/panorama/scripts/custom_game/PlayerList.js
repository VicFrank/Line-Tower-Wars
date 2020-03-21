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

UpdateGold();

function UpdateGold() {
  for (var i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
    if (Game.GetPlayerInfo(i)) {
      $("#gold_text" + i).text = Players.GetGold(i);
    }
  }

  $.Schedule(0.1, UpdateGold);
}

function UpdateIncomes() {
  $.Msg("Update Incomes")
  for (var i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
    if (Game.GetPlayerInfo(i)) {
      var data = CustomNetTables.GetTableValue("player_stats", i);
      if (data) {
        var income = data.income;
        $("#interest_text" + i).text = "(+" + income + ")";
      }
    }
  }  
}

function OnIncomeChanged(table_name, key, data) {
  var playerID = key;
  var income = data.income;

  $("#interest_text" + playerID).text = "(+" + income + ")";
}

(function () {
  UpdateIncomes();

  CustomNetTables.SubscribeNetTableListener("player_stats", OnIncomeChanged);
})();