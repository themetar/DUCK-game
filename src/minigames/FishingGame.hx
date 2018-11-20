package minigames;

import minigames.core.Game;
import minigames.core.GameEvent;
import minigames.core.NPC;
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
	
	private static var SWIM_ACCELERATION:Float = 100;
	private static var RESISTANCE_COEFICIENT:Float = -0.4;
	private static var DIVE_SPEED:Float = 800;
	private static var BUOYANCY:Float = - 800;
	
	private static var WATER_SURFACE_Y = 150;
	
	private var fishes:Array<NPC>;
	private var spawn_timer:Int;
	private static var SPAWN_TIMEOUT:Int = 1000;
	private static var FISH_SPEED:Float = -100;
	

	public function new() {
		super();
		
		duck_graphic = Assets.getMovieClip ("graphics:duck");
		addChild (duck_graphic);
		
		duck_speed = new Point(0, 0);
		duck_position = new Point(0, 110);
		
		spawn_timer = 0;
		fishes = new Array<NPC>();
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var millisec_delta = delta_time / 1000;
		
		var swim_acc:Float = keys_down.get(Keyboard.RIGHT) ? SWIM_ACCELERATION : keys_down.get(Keyboard.LEFT) ? -SWIM_ACCELERATION : 0;
		
		var resistance_decceleration:Float = keys_down.get(Keyboard.RIGHT) || keys_down.get(Keyboard.RIGHT) ? 0 : duck_speed.x * RESISTANCE_COEFICIENT;
		
		duck_speed.x += (swim_acc + resistance_decceleration) * millisec_delta;
		
		duck_position.x += duck_speed.x * millisec_delta + (swim_acc + resistance_decceleration) / 2 * millisec_delta * millisec_delta;
		
		// bump duck from borders
		if (duck_position.x < 0 || duck_position.x > camera.width - 50) {
			duck_speed.x = -duck_speed.x;
		}
		
		// vertical - diving - motion
		if (is_diving){
			duck_position.y += duck_speed.y * millisec_delta + BUOYANCY / 2 * millisec_delta * millisec_delta;
			
			duck_speed.y += BUOYANCY * millisec_delta;
			
			
			if (duck_position.y < WATER_SURFACE_Y - 40) {
				duck_position.y = WATER_SURFACE_Y - 40;
				is_diving = false;
			}
		}
		
		// spawn fishes
		if (spawn_timer <= 0){
			var fish = new NPC();
			fish.x = camera.width;
			fish.y = 200 + Math.random() * 300;
			fishes.push(fish);
			
			spawn_timer = SPAWN_TIMEOUT;
		}
		spawn_timer -= delta_time;
		
		for (fish in fishes) {
			fish.x += FISH_SPEED * millisec_delta;
		}
		
		// test collision
		for (fish in fishes) {
			if (duck_graphic.hitTestObject(fish.sprite)) {
				fish.to_remove = true;
				dispatchEvent(new GameEvent(GameEvent.SCORE));
			}
		}
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		graphics.clear();
		graphics.lineStyle(1, 0xffffff);
		
		graphics.moveTo(0, WATER_SURFACE_Y - camera.y);
		graphics.lineTo(camera.width, WATER_SURFACE_Y - camera.y);
		
		graphics.moveTo(0 - camera.x, 0); // left border
		graphics.lineTo(0 - camera.x, camera.height);
		
		graphics.moveTo(camera.width - camera.x, 0); // right border
		graphics.lineTo(camera.width - camera.x, camera.height);
		
		duck_graphic.x = duck_position.x - camera.x;
		duck_graphic.y = duck_position.y - camera.y;
		
		for (fish in fishes) {
			if (fish.sprite == null){
				fish.sprite = Assets.getMovieClip("graphics:fish");
				addChild(fish.sprite);
			}
			fish.sprite.x = fish.x - camera.x;
			fish.sprite.y = fish.y - camera.y;
		}
		
		fishes = fishes.filter(function (f):Bool {
			var test = f.x > camera.x && !f.to_remove;
			if (!test) removeChild(f.sprite);
			return test;	
		});
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