if (!GameUI.Keybinds) GameUI.Keybinds = {};

function WrapFunction(name) {
  return function() { GameUI.Keybinds[name](); };
}

Game.AddCommand("+PurchaseSlot1", WrapFunction("PurchaseItem1"), "", 0);
Game.AddCommand("+PurchaseSlot2", WrapFunction("PurchaseItem2"), "", 0);
Game.AddCommand("+PurchaseSlot3", WrapFunction("PurchaseItem3"), "", 0);
Game.AddCommand("+PurchaseSlot4", WrapFunction("PurchaseItem4"), "", 0);
Game.AddCommand("+PurchaseSlot5", WrapFunction("PurchaseItem5"), "", 0);
Game.AddCommand("+PurchaseSlot6", WrapFunction("PurchaseItem6"), "", 0);
Game.AddCommand("+PurchaseSlot7", WrapFunction("PurchaseItem7"), "", 0);
Game.AddCommand("+PurchaseSlot8", WrapFunction("PurchaseItem8"), "", 0);
Game.AddCommand("+PurchaseSlot9", WrapFunction("PurchaseItem9"), "", 0);
Game.AddCommand("+PurchaseSlot10", WrapFunction("PurchaseItem10"), "", 0);
Game.AddCommand("+PurchaseSlot11", WrapFunction("PurchaseItem11"), "", 0);
Game.AddCommand("+PurchaseSlot12", WrapFunction("PurchaseItem12"), "", 0);

Game.AddCommand("-PurchaseSlot1", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot2", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot3", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot4", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot5", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot6", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot7", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot8", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot9", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot10", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot11", function() {}, "", 0);
Game.AddCommand("-PurchaseSlot12", function() {}, "", 0);

Game.AddCommand("+SpacePressed", WrapFunction("SpacePressed"), "", 0);
Game.AddCommand("-SpacePressed", function() {}, "", 0);