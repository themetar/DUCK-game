package;

import minigames.EvadingGame;
import minigames.FishingGame;
import minigames.SnakeingGame;
import minigames.core.Game;
import minigames.core.GameEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import motion.Actuate;
import motion.easing.Linear;
import util.Mask;

/**
 * ...
 * @author Dimitar
 */
class Main extends Sprite {
	
	private var intro_screen:Sprite;
	
	var fishing_game:FishingGame;
	var snakeing_game:SnakeingGame;
	var evading_game:EvadingGame;
	
	var minigames_queue:Array<Game>;
	var current_game:Int;
	
	var upped:Int;
	
	private var switch_countdown:Int;
	private static inline var SLOT_PLAYTIME:Int = 10000; // 10000 miliseconds = 10 seconds
	
	private var mask_shape:Mask;
	
	private var time:Int;
	
	private var time_display:TextField;
	private var score_display:TextField;
	private var highscore_display:TextField;
	
	private var score:Int;
	private var highscore:Int;
	
	private var info_screen:Sprite;

	public function new() {
		super();
		
		// init
		
		fishing_game = new FishingGame();
		snakeing_game = new SnakeingGame();
		evading_game = new EvadingGame();
		
		fishing_game.addEventListener(GameEvent.SCORE, onScore);
		snakeing_game.addEventListener(GameEvent.SCORE, onScore);
		evading_game.addEventListener(GameEvent.SCORE, onScore);
		
		time_display = new TextField();
		time_display.setTextFormat(new TextFormat(null, 40, 0xFFFFFF));
		time_display.x = Lib.current.stage.stageWidth / 2 - time_display.width / 2;
		time_display.autoSize = TextFieldAutoSize.CENTER;
		addChild(time_display);
		
		score_display = new TextField();
		score_display.setTextFormat(new TextFormat(null, 40, 0xFFFFFF));
		score_display.x = 20;
		score_display.autoSize = TextFieldAutoSize.LEFT;
		addChild(score_display);
		
		highscore_display = new TextField();
		highscore_display.setTextFormat(new TextFormat(null, 40, 0xFFFFFF));
		highscore_display.x = 800 - 20 - highscore_display.width;
		highscore_display.autoSize = TextFieldAutoSize.RIGHT;
		addChild(highscore_display);
				
		mask_shape = new Mask(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		
		info_screen = intro_screen = Assets.getMovieClip("graphics:intro_screen");
		addChild(intro_screen);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onSpaceKey);
		
		highscore = 0;
		highscore_display.text = Std.string(highscore);
	}
	
	private function onSpaceKey(event:KeyboardEvent):Void{
		re_play();
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onSpaceKey);
	}
	
	private function re_play():Void {
		minigames_queue = [fishing_game, snakeing_game, evading_game];
		current_game = 0;
		upped = 0;
		
		minigames_queue[current_game].pause();
		addChildAt(minigames_queue[current_game], 0);
		
		Actuate.tween(info_screen, 1, {y: -600}).onComplete(function (){
			removeChild(info_screen);
			
			switch_countdown = SLOT_PLAYTIME;
			time = Lib.getTimer();
		
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			minigames_queue[current_game].resume();
		});
		
		score = 0;
		score_display.text = Std.string(score);
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
			
			
			Actuate.tween(minigame.camera, 1, {x: -delta_x, y: -delta_y}).ease(Linear.easeNone);
			Actuate.tween(next_minigame.camera, 1, {x:0, y: 0}).ease(Linear.easeNone);
			Actuate.update(mask_shape.draw_mask, 1, [0], [1]).ease(Linear.easeNone).onComplete(function () {
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
		}
		
		time_display.text = Std.string(Math.round(switch_countdown / 1000));
		
		time = current_time;
	}
	
	private function onScore(event:GameEvent):Void{
		var text:TextField = new TextField();
		text.text = "+10";
		text.x = event.screen_x;
		text.y = event.screen_y;
		addChild(text);
		Actuate.tween(text, 1, {alpha: 0, y: text.y - 50}).onComplete(function (){
			removeChild(text);
		});
		
		score += 10;
		score_display.text = Std.string(score);
		
		if (score > highscore){
			highscore = score;
			highscore_display.text = Std.string(highscore);
		}
	}

}
