"use strict";

var localPlayerID = Players.GetLocalPlayer();
var m_Item = -1;
var m_QueryUnit = -1;
var itemname = "";
var restockTime = -1;
var cooldownLength = -1;
var stock = -1;
var cost = -1;

function UpdateItem()
{
  var hotkey = "a";
  var isPassive = false;

  var cooldownReady = stock > 0;

  $.GetContextPanel().SetHasClass("no_item", (itemname == ""));
  $.GetContextPanel().SetHasClass("show_charges", true);
  $.GetContextPanel().SetHasClass("is_passive", isPassive);
  
  // $( "#HotkeyText" ).text = hotkey;
  $("#ItemImage").itemname = itemname;
  $("#ChargeCount").text = stock;
  
  if (cooldownReady)
  {
    $.GetContextPanel().SetHasClass("cooldown_ready", true);
    $.GetContextPanel().SetHasClass("in_cooldown", false);
  }
  else
  {
    $.GetContextPanel().SetHasClass("cooldown_ready", false);
    $.GetContextPanel().SetHasClass("in_cooldown", true);
    var cooldownRemaining = restockTime - Game.GetGameTime();
    var cooldownPercent = Math.ceil(100 * cooldownRemaining / cooldownLength);
    if (cooldownLength > 0) {
      $("#CooldownTimer").text = Math.ceil( cooldownRemaining );
      $("#CooldownOverlay").style.width = cooldownPercent+"%";
    }
  }
  
  $.Schedule(0.1, UpdateItem);
}

function ItemShowTooltip()
{
  if (itemname == "")
    return;

  $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", $.GetContextPanel(), itemname, m_QueryUnit);
}

function ItemHideTooltip()
{
  $.DispatchEvent("DOTAHideAbilityTooltip", $.GetContextPanel());
}

function PurchaseItem() {
  var data = CustomNetTables.GetTableValue("custom_shop", "gold" + localPlayerID);
  var gold = data.gold;
  if (stock === 0 || gold < cost || Game.IsGamePaused()) {
    // Game.EmitSound("General.SecretShopNotInRange");
  } else {
    Game.EmitSound("General.Buy");
  }

  // we need to call this even on a failed purchase to show the error messages
  GameEvents.SendCustomGameEventToServer("attempt_purchase", {itemname: itemname});
}

function SetItem(data)
{
  itemname = data.itemname;
  stock = data.stock;
  restockTime = data.restock_time;
  cooldownLength = data.cooldown_length;
  cost = data.cost;
}

(function()
{
  $.GetContextPanel().SetItem = SetItem;

  UpdateItem(); // initial update of dynamic state
})();
