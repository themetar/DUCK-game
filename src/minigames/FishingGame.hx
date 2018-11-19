package minigames;

import minigames.core.Game;
import openfl.display.MovieClip;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Dimitar
 */
class FishingGame extends Game {
	
	private var duck_graphic:MovieClip;
	
	private var keys_down:Map<Int, Bool> = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
	private var duck_speed:Point;
	private var is_diving:Bool;
	
	private static var SWIM_ACCELERATION:Float = 50;
	private static var RESISTANCE_COEFICIENT:Float = -0.3;
	private static var DIVE_SPEED:Float = 800;
	private static var BUOYANCY:Float = - 800;
	
	

	public function new() {
		super();
		
		duck_graphic = Assets.getMovieClip ("graphics:duck");
		addChild (duck_graphic);
		
		duck_speed = new Point(0, 0);
		duck_position = new Point(0, 110);
		
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var millisec_delta = delta_time / 1000;
		
		trace(millisec_delta);
		
		var swim_acc:Float = keys_down.get(Keyboard.RIGHT) ? SWIM_ACCELERATION : keys_down.get(Keyboard.LEFT) ? -SWIM_ACCELERATION : 0;
		
		var resistance_decceleration:Float = duck_speed.x * RESISTANCE_COEFICIENT;
		
		duck_speed.x += (swim_acc + resistance_decceleration) * millisec_delta;
		
		duck_position.x += duck_speed.x * millisec_delta + (swim_acc + resistance_decceleration) / 2 * millisec_delta * millisec_delta;
		
		if (duck_position.x < 0 || duck_position.x > camera.width - 50) {
			duck_speed.x = -duck_speed.x;
		}
		
		if (is_diving){
			duck_position.y += duck_speed.y * millisec_delta + BUOYANCY / 2 * millisec_delta * millisec_delta;
			
			duck_speed.y += BUOYANCY * millisec_delta;
			
			
			if (duck_position.y < 110) {
				duck_position.y = 110;
				is_diving = false;
			}
		}
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		graphics.clear();
		graphics.lineStyle(1, 0xffffff);
		graphics.drawRect(camera.x, camera.y, camera.width, camera.height);
		
		graphics.lineTo(0, camera.height / 4);
		graphics.lineTo(camera.width, camera.height / 4);
		
		getChildAt(numChildren - 1).x = duck_position.x;
		getChildAt(numChildren - 1).y = duck_position.y;
	}
	
	override function handleKeyboardEvent(event:KeyboardEvent):Void {
		super.handleKeyboardEvent(event);
		
		trace(event.keyCode, event.type);
		
		if (keys_down.exists(event.keyCode)) {
			keys_down.set(event.keyCode, event.type == KeyboardEvent.KEY_DOWN);
		}
		
		if (event.keyCode == Keyboard.SPACE && event.type == KeyboardEvent.KEY_DOWN) {
			if (!is_diving){
				is_diving = true;
				duck_speed.y = DIVE_SPEED;
			}
		}
		
	}
}