var rootPanel = $("#Avatars");

for (var i = 0; i < DOTALimits_t.DOTA_MAX_TEAM_PLAYERS; i++){
  if (Game.GetPlayerInfo(i)) {
    var steam_id = Game.GetPlayerInfo(i).player_steamid;
    var team = Players.GetTeam(i);
	var hero = Players.GetPlayerSelectedHero(i);

    createPlayerPanel(i, steam_id);
	 createPlayerPanel(i, steam_id);
	  createPlayerPanel(i, steam_id);
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

  var usernamePanel = $.CreatePanel("DOTAUserName", playerPanel, "username_player_" + id);
  usernamePanel.AddClass("Username");
  usernamePanel.steamid = steam_id;
  
  var HealthIconPanel = $.CreatePanel("Panel", playerPanel, "health_icon" + id);
  HealthIconPanel.AddClass("HealthIcon");
  
  var HealthIconText = $.CreatePanel("Label", playerPanel, "health_text" + id);
  HealthIconText.AddClass("HealthText");
  HealthIconText.text = "30"
  
  var GoldIconPanel = $.CreatePanel("Panel", playerPanel, "gold_icon" + id);
  GoldIconPanel.AddClass("GoldIcon");
  
  var GoldIconText = $.CreatePanel("Label", playerPanel, "gold_text" + id);
  GoldIconText.AddClass("GoldText");
  GoldIconText.text = "138k"
  
  var InterestText = $.CreatePanel("Label", playerPanel, "interest_text" + id);
  InterestText.AddClass("InterestText");
  InterestText.text = "(+279k)"
}