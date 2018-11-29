package minigames;

import minigames.core.Game;
import minigames.core.GameEvent;
import minigames.npcs.Duckling;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.geom.Point;

using Lambda;

/**
 * ...
 * @author Dimitar
 */
enum Direction {
	Left;
	Right;
	Up;
	Down;
	None;
}
class SnakeingGame extends Game {
	
	private var duck:Duckling; // the Duck is part of the 'snake'
	
	private var walk_speed:Float;
	
	private var duck_direction:Direction;
	private var input_direction:Direction;
	
	private static var WALK_SPEED_MIN:Float = 3;
	private static var WALK_SPEED_MAX:Float = 10;
	
	private static var GRID_WIDTH:Int = 13;
	private static var GRID_HEIGHT:Int = 11;
	
	private static var CELL_SIZE:Int = 50;
	
	private var origin_x:Float;
	private	var origin_y:Float;
	
	private var ducklings:Array<Duckling>;
	
	private var spawn_countdown_timer:Int;
	private var spawn_timeout:Int;
	
	private var collectable_ducklings:Array<Duckling>;
	
	private var back_green:Sprite;
	private var field:Sprite;
	
	private var duck_sprites:Map<Direction, Sprite>;
	

	public function new() {
		super();
		
		duck = new Duckling();
		
		origin_x = Std.int((camera.width - GRID_WIDTH * CELL_SIZE) / 2);
		origin_y = Std.int((camera.height - GRID_HEIGHT * CELL_SIZE) / 2);
		
		duck_sprites = [Left => Assets.getMovieClip("graphics:duck_walking_left"),
				Right => Assets.getMovieClip("graphics:duck_walking_right"),
				Down => Assets.getMovieClip("graphics:duck_walking_down"),
				Up => Assets.getMovieClip("graphics:duck_walking_up")];
		
		duck.sprite = duck_sprites.get(Up);
		addChild (duck.sprite);
		
		ducklings = [duck];
		
		spawn_timeout = 2000; // 2 sec.
		
		collectable_ducklings = [];
		
		reset();
			
		back_green = Assets.getMovieClip("graphics:green");
		addChildAt(back_green, 0);
		
		field = Assets.getMovieClip("graphics:checkerfield");
		addChildAt(field, 1);
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var millisec_delta:Float = delta_time / 1000;
		
		var remaining_distance = (duck.target_x - duck.x) + (duck.target_y - duck.y); // one is always 0
		var traverse = duck.speed_x * millisec_delta + duck.speed_y * millisec_delta; // one is always 0
		var reached_target = Math.abs(remaining_distance) <= Math.abs(traverse);
		
		if (reached_target) {
			
			// proccess user input, if any
			// new direction from controls
			if (input_direction != None && duck_direction != input_direction && input_direction != opositeDirection(duck_direction)) {
				// direction changed
				
				duck_direction = input_direction;
				input_direction = None;
			}
			
			// set new speed
			switch (duck_direction) {
				case Left:						
					duck.speed_x =-walk_speed;
					duck.speed_y =  0;
				case Right:						
					duck.speed_x = walk_speed;
					duck.speed_y = 0;
				case Up:						
					duck.speed_x = 0;
					duck.speed_y = -walk_speed;
				case Down:						
					duck.speed_x = 0;
					duck.speed_y = walk_speed;
				case None:
					throw "Error";
			}
			
			// new target
			var _target_x = duck.target_x;
			var _target_y = duck.target_y;
			switch (duck_direction) {
				case Left: _target_x -= 1;
				case Right: _target_x += 1;
				case Up: _target_y -= 1;
				case Down: _target_y += 1;
				case None:
					throw "Error";
			}
			
			// check collisions
			
			var out_of_bounds = _target_x < 0 || _target_x >= GRID_WIDTH || _target_y < 0 || _target_y >= GRID_HEIGHT;
			var hit_snake = [for (i in 1...(ducklings.length - 1)) ducklings[i]].exists(function (duckling) { return duckling.target_x == _target_x && duckling.target_y == _target_y; });
			var injured = hit_snake || out_of_bounds;
			var was_duckling_added = false;
			
			if (!injured) {
				var foundling = collectable_ducklings.find(function (duckling) return duckling.x == _target_x && duckling.y == _target_y );
				was_duckling_added = (foundling != null);
				if (was_duckling_added) {
					foundling.setNewTarget(duck.target_x, duck.target_y);// current, before update
					
					collectable_ducklings.remove(foundling);
				
					ducklings.insert(1, foundling);
					
				}
			}
			
			
			// 'snap' exactly to target - all ducks
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];				
				
				duckling.x = duckling.target_x;
				duckling.y = duckling.target_y;				
			}
			
			
			if (!(was_duckling_added || injured)){
				// just ducklings, last to first
				// inherit new target
				for (i in 1...ducklings.length) {
					var duckling = ducklings[ducklings.length - i];	
					var predecessor = ducklings[ducklings.length - i - 1];
					
					duckling.setNewTarget(predecessor.target_x, predecessor.target_y);					
				}
			} else if (injured) {
				// all ducklings
				// go back one block, i.e. get last previous target
				for (i in 0...ducklings.length) {
					var duckling = ducklings[i];	
					duckling.rewindTaget();			
				}
			}
			
			if (!injured) {
				// apply head duck new target
				duck.setNewTarget(_target_x, _target_y);
			}			
			
			
			// calc speed for all ducklings
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];
				duckling.speed_x = walk_speed * (duckling.target_x - duckling.x);
				duckling.speed_y = walk_speed * (duckling.target_y - duckling.y);
			}
			
			
				
				
			// apply complete movement
			var complete = traverse - remaining_distance;
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];
				
				duckling.x += Math.max(-1, Math.min(complete, 1)) * Std.int(duckling.speed_x / duckling.speed_x);
				duckling.y += Math.max(-1, Math.min(complete, 1)) * Std.int(duckling.speed_y / duckling.speed_y);
			}
		
			if (was_duckling_added) dispatchEvent(new GameEvent(GameEvent.SCORE, duck.sprite.x, duck.sprite.y));
			if (hit_snake) dispatchEvent(new GameEvent(GameEvent.INJURY));
			
		} else {
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];
				duckling.x += duckling.speed_x * millisec_delta;
				duckling.y += duckling.speed_y * millisec_delta;
			}
		}
		
		// spawn collectable ducklings
		spawn_countdown_timer -= delta_time;
		if (spawn_countdown_timer <= 0){
			spawn_countdown_timer += spawn_timeout;
			
			// spawn
			var empties_XY = [for (x in 0...GRID_WIDTH) for (y in 0...GRID_HEIGHT) {x: x, y: y}];
			
			var empty_count = empties_XY.length;
			for (duc in ducklings.concat(collectable_ducklings)) {
				var i = Std.int(duc.target_x * GRID_HEIGHT + duc.target_y);
				var tmp = empties_XY[i];
				empties_XY[i] = empties_XY[empty_count - 1];
				empties_XY[empty_count - 1] = tmp;
				
				empty_count -= 1;
			}
			
			trace("empty_count", empty_count);
			
			var spawn_cell = empties_XY[Std.int(Math.random() * empty_count)];
			
			var new_duckling = new Duckling();
			new_duckling.x = new_duckling.target_x = spawn_cell.x;
			new_duckling.y = new_duckling.target_y = spawn_cell.y;
			
			collectable_ducklings.push(new_duckling);
		}
		
	}
	
	private function opositeDirection(d:Direction):Direction{
		return switch(d){
			case Left: Right;
			case Right: Left;
			case Up: Down;
			case Down: Up;
			case None: None;
		}
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		var sprite = duck_sprites.get(duck_direction);
		if (sprite != duck.sprite) {
			addChildAt(sprite, 2);
			removeChild(duck.sprite);
			duck.sprite = sprite;
		}
		
		duck.sprite.x = origin_x + duck.x * CELL_SIZE + (CELL_SIZE - 50)/2 - camera.x;
		duck.sprite.y = origin_y + duck.y * CELL_SIZE + (CELL_SIZE - 50) - camera.y;
		
		
		for (i in 1...ducklings.length) {
			var duckling = ducklings[i];
			duckling.sprite.x = origin_x + duckling.x * CELL_SIZE + (CELL_SIZE - 30)/2 - camera.x;
			duckling.sprite.y = origin_y + duckling.y * CELL_SIZE + (CELL_SIZE - 30) - camera.y;
		}
		
		// collecatable
		for (spawn in collectable_ducklings) {
			if (spawn.sprite == null){
				spawn.sprite = Assets.getMovieClip("graphics:duckling");
				addChild(spawn.sprite);
			}
			
			spawn.sprite.x = origin_x + spawn.x * CELL_SIZE + (CELL_SIZE - spawn.sprite.width)/2 - camera.x;
			spawn.sprite.y = origin_y + spawn.y * CELL_SIZE + (CELL_SIZE - spawn.sprite.height) - camera.y;
		}
		
		field.x = origin_x - camera.x;
		field.y = origin_y - camera.y;
	}
	
	override function handleKeyboardEvent(event:KeyboardEvent):Void {
		super.handleKeyboardEvent(event);
		
		if (event.keyCode == Keyboard.SPACE) return;
		
		if (event.type == KeyboardEvent.KEY_DOWN) {
			input_direction = switch(event.keyCode) {
				case Keyboard.LEFT:
					Left;
				case Keyboard.RIGHT:
					Right;
				case Keyboard.UP:
					Up;
				case Keyboard.DOWN:
					Down;
				default:
					None;
			}
		}
	}
	
	override public function up_the_ante():Void {
		super.up_the_ante();
		
		walk_speed = Math.max(WALK_SPEED_MIN, Math.min(walk_speed + 0.75, WALK_SPEED_MAX));
	}
	
	override public function reset():Void {
		super.reset();
		
		// initial values
		duck.x = Std.int(GRID_WIDTH / 2);
		duck.y = Std.int(GRID_HEIGHT / 2);
		
		duck.setNewTarget(duck.x, duck.y - 1);
		
		walk_speed = WALK_SPEED_MIN;
		
		duck.speed_x = 0;
		duck.speed_y = -walk_speed;
		
		duck_direction = Up;
		input_direction = None;
		
		// remove current ducklings from display
		for (i in 1...ducklings.length) { // from 1 -> skip main duck
			var duckling = ducklings[i];
			if (duckling.sprite != null && duckling.sprite.parent != null) duckling.sprite.parent.removeChild(duckling.sprite);
		}
		
		// reset ducklings snake
		ducklings = [duck];
		
		// remove collectable ducklings from display
		for (duckling in collectable_ducklings) if (duckling.sprite != null && duckling.sprite.parent != null) duckling.sprite.parent.removeChild(duckling.sprite);
		collectable_ducklings = [];
		
		// reset spawn timer
		spawn_countdown_timer = 0;		
		
	}
	
	override public function get_duck_position_on_camera():Point {
		return new Point(origin_x + duck.x * CELL_SIZE + (CELL_SIZE - duck.sprite.width)/2 - camera.x, origin_y + duck.y * CELL_SIZE + (CELL_SIZE - duck.sprite.height) - camera.y);
	}
	
}