package minigames;

import minigames.core.Game;
import minigames.npcs.Duckling;
import openfl.display.MovieClip;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

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
	
	private static var WALK_SPEED_MIN:Float = 2;
	private static var WALK_SPEED_MAX:Float = 10;
	
	private static var GRID_WIDTH:Int = 13;
	private static var GRID_HEIGHT:Int = 12;
	
	private static var CELL_SIZE:Int = 50;
	
	private var origin_x:Float;
	private	var origin_y:Float;
	
	private var ducklings:Array<Duckling>;

	public function new() {
		super();
		
		duck = new Duckling();
		
		duck.x = Std.int(GRID_WIDTH / 2);
		duck.y = Std.int(GRID_HEIGHT / 2);
		
		duck.target_x = duck.x;
		duck.target_y = duck.y - 1;
		
		walk_speed = WALK_SPEED_MIN;
		
		duck.speed_x = 0;
		duck.speed_y = -walk_speed;
		
		duck_direction = Up;
		input_direction = None;
		
		origin_x = Std.int((camera.width - GRID_WIDTH * CELL_SIZE) / 2);
		origin_y = Std.int((camera.height - GRID_HEIGHT * CELL_SIZE) / 2);
		
		duck.sprite = Assets.getMovieClip ("graphics:duck");
		addChild (duck.sprite);
		
		ducklings = [duck];
		
		for (i in 0...7) {
			var duckling = new Duckling();
			duckling.sprite = Assets.getMovieClip("graphics:duckling");
			duckling.target_y = duck.target_y + i + 1;
			duckling.target_x = duck.target_x;
			duckling.speed_y = duck.speed_y;
			duckling.x = duck.x;
			duckling.y = duck.y + i +1;
			
			ducklings.push(duckling);
			
			addChild(duckling.sprite);
		}
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
			// TODO
			var out_of_bounds = _target_x < 0 || _target_x >= GRID_WIDTH || _target_y < 0 || _target_y >= GRID_HEIGHT;
			var hit_snake = [for (i in 1...(ducklings.length - 1)) ducklings[i]].exists(function (duckling) { return duckling.target_x == _target_x && duckling.target_y == _target_y; });
			
			
			// 'snap' exactly to target - all ducks
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];				
				
				duckling.x = duckling.target_x;
				duckling.y = duckling.target_y;				
			}
			
			// just ducklings, last to first
			// inherit new target
			// calc new direction (speed_x, speed_y)
			for (i in 1...ducklings.length) {
				var duckling = ducklings[ducklings.length - i];	
				var predecessor = ducklings[ducklings.length - i - 1];
				
				duckling.target_x = predecessor.target_x;
				duckling.target_y = predecessor.target_y;
				
				duckling.speed_x = walk_speed * (duckling.target_x - duckling.x);
				duckling.speed_y = walk_speed * (duckling.target_y - duckling.y);
			}	
			
			
			
			// apply head duck new target
			duck.target_x = _target_x;
			duck.target_y = _target_y;
			
			// apply complete movement
			var complete = traverse - remaining_distance;
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];
				
				duckling.x += complete * Std.int(duckling.speed_x / duckling.speed_x);
				duckling.y += complete * Std.int(duckling.speed_y / duckling.speed_y);
			}
			
		} else {
			for (i in 0...ducklings.length) {
				var duckling = ducklings[i];
				duckling.x += duckling.speed_x * millisec_delta;
				duckling.y += duckling.speed_y * millisec_delta;
			}
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
		
		graphics.clear();
		graphics.lineStyle(1, 0xffffff);
		for (r in 0...GRID_HEIGHT)
			for (c in 0...GRID_WIDTH) {
				graphics.drawRect(origin_x + c * CELL_SIZE, origin_y + r * CELL_SIZE, CELL_SIZE, CELL_SIZE);
			}
		
		for (duckling in ducklings) {
			duckling.sprite.x = origin_x + duckling.x * CELL_SIZE + (CELL_SIZE - duckling.sprite.width)/2 - camera.x;
			duckling.sprite.y = origin_y + duckling.y * CELL_SIZE + (CELL_SIZE - duckling.sprite.height) - camera.y;
		}
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
	
}