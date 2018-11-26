package minigames;

import minigames.core.Game;
import minigames.core.GameEvent;
import minigames.core.NPC;
import openfl.Assets;
import openfl.display.MovieClip;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Dimitar
 */

typedef XYVector = {x:Float, y:Float}
typedef Duck = {
	 position:XYVector,
	 velocity: XYVector,
	 sprite: MovieClip
}

class EvadingGame extends Game {
	
	private var the_duck:Duck;
	
	private var gravity:Float = 900;
	
	private var lift:Float = -400;
	
	private static var X_SPEED:Float = 300;
	
	private var left_right_down:Map<Int, Bool>;
	
	private var flap_countdown:Int = 0;
	private static var FLAP_TIMEOUT:Int = 300;
	
	private var crosshair_array:Array<NPC>;
	
	private var follow_speed:Float = 300;
	
	private var cross_velocities:Array<XYVector>;
	
	private static var CROSS_RADIUS:Float = 35;

	public function new() {
		super();
		
		the_duck = {
			position: {x: camera.width / 2, y: camera.height / 2},
			velocity: {x: X_SPEED, y: 0},
			sprite: Assets.getMovieClip("graphics:duck")
		};
		addChild(the_duck.sprite);
		
		left_right_down = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
		
		crosshair_array = [new NPC()];
		crosshair_array[0].sprite = Assets.getMovieClip("graphics:crosshair");
		addChildAt(crosshair_array[0].sprite, 0);
		
		var cross_target_x = the_duck.position.x + 50 / 2; // hardcoded duck graphic width
		var cross_target_y = the_duck.position.x + 50 / 2;
		var angle = Math.atan2(cross_target_y - crosshair_array[0].y, cross_target_x - crosshair_array[0].x);
		cross_velocities = [{x: follow_speed * Math.cos(angle), y: follow_speed * Math.sin(angle)}];
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var seconds_time = delta_time / 1000;
		
		// controls
		the_duck.velocity.x = left_right_down.get(Keyboard.LEFT) ? -X_SPEED : left_right_down.get(Keyboard.RIGHT) ? X_SPEED : 0;
		
		var y_acceleration = gravity + (left_right_down.get(Keyboard.LEFT) || left_right_down.get(Keyboard.RIGHT) ? lift : 0);
		
		the_duck.position.y += the_duck.velocity.y * seconds_time + y_acceleration / 2 * seconds_time * seconds_time;
		the_duck.velocity.y += y_acceleration * seconds_time;
		
		the_duck.position.x += the_duck.velocity.x * seconds_time;
		
		if (the_duck.position.y < 0 || the_duck.position.y > camera.height - 50) { // hardcoded duck sprite height
			the_duck.velocity.y = 0;
			
			the_duck.position.y = the_duck.position.y < 0 ? 0 : camera.height - 50;
			
		}
		
		the_duck.position.x = Math.max(0, Math.min(the_duck.position.x, camera.width - 50)); // hardcoded duck sprite width
		
		flap_countdown -= delta_time;
		
		// crosshair
		for (i in 0...crosshair_array.length) {
			var crosshair = crosshair_array[i];
			var cross_velocity = cross_velocities[i];
			var cross_hair_delta_x = cross_velocity.x * seconds_time;
			var cross_hair_delta_y = cross_velocity.y * seconds_time;
			crosshair.x += cross_hair_delta_x;
			crosshair.y += cross_hair_delta_y;
			
			if (0 > crosshair.x || crosshair.x > camera.width || 0 > crosshair.y || crosshair.y > camera.height){
				crosshair.x -= cross_hair_delta_x;
				crosshair.y -= cross_hair_delta_y;
				var cross_target_x = the_duck.position.x + 50 / 2; // hardcoded duck graphic width
				var cross_target_y = the_duck.position.y + 50 / 2;
				var angle = Math.atan2(cross_target_y - crosshair.y, cross_target_x - crosshair.x);
				cross_velocity.x = follow_speed * Math.cos(angle);
				cross_velocity.y = follow_speed * Math.sin(angle);			
			}
			
			// hit
			var distance = Math.sqrt(Math.pow(crosshair.x - the_duck.position.x + 50 / 2, 2) + Math.pow(crosshair.y - the_duck.position.y + 50 / 2, 2));
			if (distance <= CROSS_RADIUS) {
				// shot
				dispatchEvent(new GameEvent(GameEvent.INJURY));
			} else if (CROSS_RADIUS < distance && distance < CROSS_RADIUS + 20) {
				// near miss, get points
				dispatchEvent(new GameEvent(GameEvent.SCORE));
			}
		}
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		the_duck.sprite.x = the_duck.position.x - camera.x;
		the_duck.sprite.y = the_duck.position.y - camera.y;
		
		for (crosshair in crosshair_array) {
			crosshair.sprite.x = crosshair.x - 40 - camera.x;
			crosshair.sprite.y = crosshair.y - 40 - camera.y;
		}
	}
	
	override function handleKeyboardEvent(event:KeyboardEvent):Void {
		super.handleKeyboardEvent(event);
		
		if (event.keyCode == Keyboard.SPACE && event.type == KeyboardEvent.KEY_DOWN){
			if (flap_countdown < 0) {
				the_duck.velocity.y += -600; // up
				flap_countdown = FLAP_TIMEOUT;
			}
		}
		
		if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT){
			left_right_down.set(event.keyCode, event.type == KeyboardEvent.KEY_DOWN);
		}
	}
	
}