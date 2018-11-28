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
import motion.Actuate;
import motion.easing.Linear;
import util.Mask;

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
	private static var SLOT_PLAYTIME:Int = 10000; // 10000 miliseconds = 10 seconds
	
	private var mask_shape:Mask;
	
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
		time_display.setTextFormat(new TextFormat(null, 30, 0xFFFFFF));
		addChild(time_display);
		
		mask_shape = new Mask(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
	}
	
	private function onEnterFrame(event:Event):Void{
		var current_time:Int = Lib.getTimer();
		var delta:Int = current_time - time;
		
		switch_countdown -= delta;
		
		if (switch_countdown < 500) { // "round" to zero
			var minigame = minigames_queue[current_game];
			current_game = (current_game + 1) % 3;
			var next_minigame = minigames_queue[current_game];
			minigame.pause();
			next_minigame.pause();
			
			
			
			var cam_A_position = minigame.duck_position_on_camera;
			var cam_B_position = next_minigame.duck_position_on_camera;
			
			trace(minigame, next_minigame);
			trace(minigame.camera, next_minigame.camera);
			trace(cam_A_position, cam_B_position);
			
			var delta_x = cam_B_position.x - cam_A_position.x;
			var delta_y = cam_B_position.y - cam_A_position.y;
			
			next_minigame.camera.x = delta_x;
			next_minigame.camera.y = delta_y;
			
			next_minigame.up_the_ante();
			addChildAt(next_minigame, 1);
			
			
			mask_shape.draw_mask(0);
			addChildAt(mask_shape, 2);
			next_minigame.mask = mask_shape;
			
			
			Actuate.tween(minigame.camera, 5, {x: -delta_x, y: -delta_y}).ease(Linear.easeNone);
			Actuate.tween(next_minigame.camera, 5, {x:0, y: 0}).ease(Linear.easeNone);
			Actuate.update(mask_shape.draw_mask, 5, [0], [1]).ease(Linear.easeNone).onComplete(function () {
				removeChild(minigame);
				minigame.camera.x = minigame.camera.y = 0; // reset from previous transition 
				next_minigame.resume();
				time = Lib.getTimer();
				switch_countdown = SLOT_PLAYTIME;
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				
				removeChild(mask_shape);
				next_minigame.mask = null;
				addChildAt(next_minigame, 0);
			});
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			
			/*;
			
			minigame.resume();
			
			*/
		}
		
		time_display.text = Math.round(switch_countdown / 1000);
		
		time = current_time;
	}

}
