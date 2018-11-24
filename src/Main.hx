package;

import minigames.EvadingGame;
import minigames.FishingGame;
import minigames.SnakeingGame;
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
	
	var snakeing_game:SnakeingGame;
	
	var evading_game:EvadingGame;

	public function new() {
		super();
		
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");
		
		//fishing_game = new FishingGame();
		//addChild(fishing_game);
		//fishing_game.addEventListener(GameEvent.SCORE, function(event) {trace("SCORE!"); });
		
		//snakeing_game = new SnakeingGame();
		//addChild(snakeing_game);
		
		evading_game = new EvadingGame();
		addChild(evading_game);
	}

}
