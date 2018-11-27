package;

import minigames.EvadingGame;
import minigames.FishingGame;
import minigames.SnakeingGame;
import minigames.core.Game;
import minigames.core.GameEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * ...
 * @author Dimitar
 */
class Main extends Sprite {
	
	// just testing
	var fishing_game:FishingGame;
	var upped:Int = 0;
	
	var snakeing_game:SnakeingGame;
	
	var evading_game:EvadingGame;
	
	var minigames_queue:Array<Game>;
	var current_game:Int;
	
	private var switch_countdown:Int;
	private static var SLOT_PLAYTIME:Int = 20000; // 20000 miliseconds = 20 seconds
	
	private var time:Int;
	
	private var time_display:TextField;

	public function new() {
		super();
		
		fishing_game = new FishingGame();
		
		snakeing_game = new SnakeingGame();
		//addChild(snakeing_game);
		
		evading_game = new EvadingGame();
		//addChild(evading_game);
		
		minigames_queue = [fishing_game, snakeing_game, evading_game];
		current_game = 0;
		
		addChild(minigames_queue[current_game]);
		
		switch_countdown = SLOT_PLAYTIME;
		
		time = Lib.getTimer();
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		time_display = new TextField();
		time_display.setTextFormat(new TextFormat(null, 20, 0xFFFFFF));
		addChild(time_display);
	}
	
	private function onEnterFrame(event:Event):Void{
		var current_time:Int = Lib.getTimer();
		var delta:Int = current_time - time;
		
		switch_countdown -= delta;
		
		if (switch_countdown < 1000) { // "round" to zero
			var minigame = minigames_queue[current_game];
			minigame.pause();
			removeChild(minigame);
			current_game = (current_game + 1) % 3;
			minigame = minigames_queue[current_game];
			addChildAt(minigame, 0);
			minigame.resume();
			
			switch_countdown = SLOT_PLAYTIME;
		}
		
		time_display.text = Math.round(switch_countdown / 1000);
		
		time = current_time;
	}

}
