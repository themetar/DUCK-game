package minigames;

import minigames.core.Game;
import minigames.core.GameEvent;
import minigames.core.NPC;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Dimitar
 */
class FishingGame extends Game {
	
	private var duck_position:Point;
	private var duck_graphic:Sprite;
	
	private var keys_down:Map<Int, Bool>;
	private var duck_speed:Point;
	private var is_diving:Bool;
	
	private static var SWIM_ACCELERATION:Float = 200;
	private static var RESISTANCE_COEFICIENT:Float = -0.4;
	private static var DIVE_SPEED:Float = 800;
	private static var BUOYANCY:Float = - 800;
	
	private static var WATER_SURFACE_Y = 150;
	
	private var fishes:Array<NPC>;
	private var spawn_timer:Int;
	private var fish_speed:Float;
	private var spawn_timeout:Int;
	private static var SPAWN_TIMEOUT_BASELINE:Int = 1000;
	private static var FISH_SPEED_MIN:Float = -100;
	private static var FISH_SPEED_MAX:Float = -700;
	
	private var background:Sprite;
	
	private var duck_sprites:Map<String, Sprite>;
	
	private var orientation:String = "right";
	

	public function new() {
		super();
		
		duck_sprites = ["swim-left" => Assets.getMovieClip("graphics:duck_swim_left"),
				"swim-right" => Assets.getMovieClip("graphics:duck_swim_right"),
				"dive-down-left" => Assets.getMovieClip("graphics:duck_dive_down_left"),
				"dive-up-left" => Assets.getMovieClip("graphics:duck_dive_up_left"),
				"dive-down-right" => Assets.getMovieClip("graphics:duck_dive_down_right"),
				"dive-up-right" => Assets.getMovieClip("graphics:duck_dive_up_right")];
		
		duck_graphic = duck_sprites.get("swim-right");
		addChild (duck_graphic);
		
		fishes = new Array<NPC>();
		
		background = Assets.getMovieClip("graphics:fishing_background");
		addChildAt(background, 0);
		
		reset();
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var millisec_delta = delta_time / 1000;
		
		var swim_acc:Float = keys_down.get(Keyboard.RIGHT) ? SWIM_ACCELERATION : keys_down.get(Keyboard.LEFT) ? -SWIM_ACCELERATION : 0;
		
		var resistance_decceleration:Float = keys_down.get(Keyboard.RIGHT) || keys_down.get(Keyboard.RIGHT) ? 0 : duck_speed.x * RESISTANCE_COEFICIENT;
		
		duck_speed.x += (swim_acc + resistance_decceleration) * millisec_delta;
		
		duck_position.x += duck_speed.x * millisec_delta + (swim_acc + resistance_decceleration) / 2 * millisec_delta * millisec_delta;
		
		orientation = keys_down.get(Keyboard.RIGHT) ? "right" : keys_down.get(Keyboard.LEFT) ? "left" : orientation;
		
		// bump duck from borders
		if (duck_position.x < 0 || duck_position.x > camera.width - 50) {
			duck_speed.x = -duck_speed.x;
			duck_position.x = duck_position.x < 0 ? 0 : camera.width - 50;
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
			
			spawn_timer = spawn_timeout;
		}
		spawn_timer -= delta_time;
		
		for (fish in fishes) {
			fish.x += fish_speed * millisec_delta;
		}
		
		// test collision
		for (fish in fishes) {
			if (duck_graphic.hitTestObject(fish.sprite)) {
				fish.to_remove = true;
				dispatchEvent(new GameEvent(GameEvent.SCORE, fish.sprite.x, fish.sprite.y));
			}
		}
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		var sprite = if (orientation == "left") {
			if (is_diving) {
				if (duck_speed.y < 0) {
					duck_sprites.get("dive-up-left");
				} else {
					duck_sprites.get("dive-down-left");
				}
			} else {
				duck_sprites.get("swim-left");
			}
		} else {
			if (is_diving) {
				if (duck_speed.y < 0) {
					duck_sprites.get("dive-up-right");
				} else {
					duck_sprites.get("dive-down-right");
				}
			} else {
				duck_sprites.get("swim-right");
			}
		}
		
		if (sprite != duck_graphic) {
			addChildAt(sprite, 1);
			removeChild(duck_graphic);
			duck_graphic = sprite;
		}
		
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
		
		background.y = -camera.y;
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
	
	override public function up_the_ante():Void {
		super.up_the_ante();
		
		fish_speed = Math.min(FISH_SPEED_MIN, Math.max(fish_speed - 50, FISH_SPEED_MAX));
		
		var q = (fish_speed - FISH_SPEED_MIN) / (FISH_SPEED_MAX - FISH_SPEED_MIN);
		
		if (q < 0.5) spawn_timeout = Std.int(SPAWN_TIMEOUT_BASELINE * (1 - q));
	}
	
	override public function reset():Void {
		super.reset();
		
		duck_speed = new Point(0, 0);
		duck_position = new Point(camera.width / 2 - 50 / 2, 110);
		
		spawn_timer = spawn_timeout = SPAWN_TIMEOUT_BASELINE;
		fish_speed = FISH_SPEED_MIN;
		
		// clear old fish from screen
		for (fish in fishes) if (fish.sprite != null && fish.sprite.parent != null) fish.sprite.parent.removeChild(fish.sprite);
		
		// new fishes
		fishes = [for (i in 0...8) {
			var fish = new NPC();
			fish.x = camera.width + fish_speed * spawn_timeout/1000 * i;
			fish.y = 200 + Math.random() * 300;
			fish;
		}];
		
		// reset keys
		keys_down = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
		
		orientation = "right";
	}
	
	override public function resume():Void {
		super.resume();
		
		// reset keys
		keys_down = [Keyboard.LEFT => false, Keyboard.RIGHT => false];
	}
	
	override public function get_duck_position_on_camera():Point {
		return new Point(duck_position.x - camera.x, duck_position.y - camera.y);
	}
}