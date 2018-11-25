package minigames;

import minigames.core.Game;
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
	
	private var crosshair:NPC;
	
	private var follow_acc_scalar:Float = 200;
	
	private var cross_velocity:XYVector = {x:0, y:0};
	private var cross_acc:XYVector;
	private var change_timeout:Int;

	public function new() {
		super();
		
		the_duck = {
			position: {x: camera.width / 2, y: camera.height / 2},
			velocity: {x: X_SPEED, y: 0},
			sprite: Assets.getMovieClip("graphics:duck")
		};
		addChild(the_duck.sprite);
		
		left_right_down = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
		
		crosshair = new NPC();
		crosshair.sprite = Assets.getMovieClip("graphics:crosshair");
		addChildAt(crosshair.sprite, 0);
		
		var cross_target_x = camera.width/4 + Math.random() * camera.width/2;
		var cross_target_y = camera.height/4 + Math.random() * camera.height/2;
		var angle = Math.atan2(cross_target_y - crosshair.y, cross_target_x - crosshair.x);
		cross_acc = {x: follow_acc_scalar * Math.cos(angle), y: follow_acc_scalar * Math.sin(angle)};
		change_timeout = 1000;
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
		
		// crosshair
		crosshair.x += cross_velocity.x * seconds_time + cross_acc.x / 2 * seconds_time * seconds_time;
		crosshair.y += cross_velocity.y * seconds_time + cross_acc.y / 2 * seconds_time * seconds_time;
		cross_velocity.x += cross_acc.x * seconds_time;
		cross_velocity.y += cross_acc.y * seconds_time;
		
		change_timeout -= delta_time;
		if (change_timeout < 0 || !camera.contains(crosshair.x, crosshair.y)){
			var cross_target_x = Math.random() * camera.width;
			var cross_target_y = Math.random() * camera.height;
			var angle = Math.atan2(cross_target_y - crosshair.y, cross_target_x - crosshair.x);
			cross_acc = {x: follow_acc_scalar * Math.cos(angle), y: follow_acc_scalar * Math.sin(angle)};
			cross_velocity.x = -cross_velocity.x / 2; // cross_velocity = {x:0, y:0};
			cross_velocity.y = -cross_velocity.y / 2;
			change_timeout = 1000;			
		}
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		the_duck.sprite.x = the_duck.position.x - camera.x;
		the_duck.sprite.y = the_duck.position.y - camera.y;
		
		crosshair.sprite.x = crosshair.x - 40 - camera.x;
		crosshair.sprite.y = crosshair.y - 40 - camera.y;
	}
	
	override function handleKeyboardEvent(event:KeyboardEvent):Void {
		super.handleKeyboardEvent(event);
		
		if (event.keyCode == Keyboard.SPACE && event.type == KeyboardEvent.KEY_DOWN){
			the_duck.velocity.y += -600; // up
		}
		
		if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT){
			left_right_down.set(event.keyCode, event.type == KeyboardEvent.KEY_DOWN);
		}
	}
	
}