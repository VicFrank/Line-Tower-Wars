const LANE_Y_POSITION = 1200;

function MoveCameraToNextLane() {
  const currentPosition = GameUI.GetCameraPosition();
  const lerp = 0.1;
  const current_x = currentPosition[0];

  let first_lane_x;

  for (let i = 1; i <= 8; i++) {
    const laneData = CustomNetTables.GetTableValue("player_stats", "lane" + i);

    if (!laneData) continue;
    if (!laneData.active) continue;

    const x_position = laneData.x_position;

    if (!first_lane_x) first_lane_x = x_position;

    if (current_x < x_position) {
      const position = [
        x_position,
        LANE_Y_POSITION,
        0
      ];

      GameUI.SetCameraTargetPosition(position, lerp); 
      return;
    }
  }

  // we've gone all the way to the end, so it must be the first lane
  const position = [
    first_lane_x,
    LANE_Y_POSITION,
    0
  ];

  GameUI.SetCameraTargetPosition(position, lerp); 
}

(function () {
  if (!GameUI.Keybinds) GameUI.Keybinds = {};

  GameUI.Keybinds.NextLane = function() { MoveCameraToNextLane() };
})();