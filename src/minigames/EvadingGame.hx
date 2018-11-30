package minigames;

import minigames.core.Game;
import minigames.core.GameEvent;
import minigames.core.NPC;
import openfl.Assets;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Dimitar
 */

typedef XYVector = {x:Float, y:Float}
typedef Duck = {
	 position:XYVector,
	 velocity: XYVector,
	 sprite: Sprite
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
	
	private var follow_speed:Float;
	private static var FOLLOW_SPEED:Float = 300;
	
	private var cross_velocities:Array<XYVector>;
	
	private static var CROSS_RADIUS:Float = 35;
	
	private var background:Sprite;
	
	private var duck_sprites:Map<String, Sprite>;
	
	private var orientation = "right";

	public function new() {
		super();
		
		duck_sprites = ["fly-left" => Assets.getMovieClip("graphics:duck_fly_left"),
				"fly-right" => Assets.getMovieClip("graphics:duck_fly_right"),
				"walk-left" => Assets.getMovieClip("graphics:duck_walking_left"),
				"walk-right" => Assets.getMovieClip("graphics:duck_walking_right")];
		
		the_duck = {
			position: {x: camera.width / 2, y: camera.height / 2},
			velocity: {x: X_SPEED, y: 0},
			sprite: duck_sprites.get("walk-right")
		};
		addChild(the_duck.sprite);
		
		crosshair_array = [];
		
		reset();
		
		background = Assets.getMovieClip("graphics:evading_background");
		addChildAt(background, 0);
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var seconds_time = delta_time / 1000;
		
		// controls
		the_duck.velocity.x = left_right_down.get(Keyboard.LEFT) ? -X_SPEED : left_right_down.get(Keyboard.RIGHT) ? X_SPEED : 0;
		
		var y_acceleration = gravity + (left_right_down.get(Keyboard.LEFT) || left_right_down.get(Keyboard.RIGHT) ? lift : 0);
		
		orientation = left_right_down.get(Keyboard.LEFT) ? "left" : left_right_down.get(Keyboard.RIGHT) ? "right" : orientation;
		
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
		
		var sprite_name:String = the_duck.velocity.y < 0 || (left_right_down.get(Keyboard.LEFT) || left_right_down.get(Keyboard.RIGHT)) && the_duck.position.y > camera.height - 50 ? "fly" : "walk";
		sprite_name += "-" + orientation;
		var sprite = duck_sprites.get(sprite_name);
		
		if (sprite != the_duck.sprite) {
			addChild(sprite);
			removeChild(the_duck.sprite);
			the_duck.sprite = sprite;
		}
		
		the_duck.sprite.x = the_duck.position.x - camera.x;
		the_duck.sprite.y = the_duck.position.y - camera.y;
		
		for (crosshair in crosshair_array) {
			crosshair.sprite.x = crosshair.x - 40 - camera.x;
			crosshair.sprite.y = crosshair.y - 40 - camera.y;
		}
		
		background.y = -camera.y;
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
	
	override public function up_the_ante():Void {
		super.up_the_ante();
		
		var rand_x = Math.random() * (camera.width - 250);
		if (rand_x > the_duck.position.x - 100) rand_x = rand_x + 250;
		
		var rand_y = Math.random() * camera.height;
		
		var c = new NPC();
		c.x = rand_x;
		c.y = rand_y;
		c.sprite = Assets.getMovieClip("graphics:crosshair");
		crosshair_array.push(c);
		addChildAt(c.sprite, 1);
		
		var angle = Math.random() * 2 * Math.PI;
		cross_velocities.push({x: follow_speed * Math.cos(angle), y: follow_speed * Math.sin(angle)});
		
		follow_speed += 50;
		
		trace(crosshair_array.length);
		trace(crosshair_array.map(function (item) {return [item.x, item.y]; } ));
	}
	
	override public function reset():Void {
		super.reset();
		
		follow_speed = FOLLOW_SPEED;
		
		left_right_down = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
		
		// remove crosshairs from display list
		for (c in crosshair_array) if (c.sprite != null && c.sprite.parent != null) c.sprite.parent.removeChild(c.sprite);
		
		// add first crosshair
		crosshair_array = [new NPC()];
		crosshair_array[0].sprite = Assets.getMovieClip("graphics:crosshair");
		addChildAt(crosshair_array[0].sprite, 0);
		
		var cross_target_x = the_duck.position.x + 50 / 2; // hardcoded duck graphic width
		var cross_target_y = the_duck.position.x + 50 / 2;
		var angle = Math.atan2(cross_target_y - crosshair_array[0].y, cross_target_x - crosshair_array[0].x);
		cross_velocities = [{x: follow_speed * Math.cos(angle), y: follow_speed * Math.sin(angle)}];
	}
	
	override public function resume():Void {
		super.resume();
		
		// reset keys
		left_right_down = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
	}
	
	override public function get_duck_position_on_camera():Point {
		return new Point(the_duck.position.x - camera.x, the_duck.position.y - camera.y);
	}
}