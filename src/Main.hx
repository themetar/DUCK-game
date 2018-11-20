package;

import minigames.FishingGame;
import minigames.core.GameEvent;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Dimitar
 */
class Main extends Sprite {
	
	// just testing
	var fishing_game:FishingGame;

	public function new() {
		super();
		
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");
		
		fishing_game = new FishingGame();
		addChild(fishing_game);
		fishing_game.addEventListener(GameEvent.SCORE, function(event) {trace("SCORE!"); });
	}

}
