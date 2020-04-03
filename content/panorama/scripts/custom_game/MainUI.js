GameUI.SetCameraDistance( 1400 );

function OnScoreboardButtonPressed() {
	Game.EmitSound("ui_chat_slide_in")
}

function OnLeaderboardButtonPressed() {
	Game.EmitSound("ui_chat_slide_in")
}

function OnShopButtonPressed() {
  Game.EmitSound("ui_chat_slide_out")
  $("#Items").ToggleClass("ShopHidden");
}

function UIContinuePressed() {
  Game.EmitSound("ui_chat_slide_out")
  $("#PopupWindow").ToggleClass("Invisible");
}