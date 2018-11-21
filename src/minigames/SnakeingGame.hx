package minigames;

import minigames.core.Game;
import minigames.npcs.Duckling;
import openfl.display.MovieClip;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

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
	
	private var duck_grid_x:Float;
	private var duck_grid_y:Float;
	
	private var duck_target_x:Float;
	private var duck_target_y:Float;	
	
	private var duck_speed_x:Float;
	private var duck_speed_y:Float;
	
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
	
	private var duck_graphic:MovieClip;
	
	private var ducklings:Array<Duckling>;

	public function new() {
		super();
		
		duck_grid_x = Std.int(GRID_WIDTH / 2);
		duck_grid_y = Std.int(GRID_HEIGHT / 2);
		
		duck_target_x = duck_grid_x;
		duck_target_y = duck_grid_y - 1;
		
		walk_speed = WALK_SPEED_MIN;
		
		duck_speed_x = 0;
		duck_speed_y = -walk_speed;
		
		duck_direction = Up;
		input_direction = None;
		
		origin_x = Std.int((camera.width - GRID_WIDTH * CELL_SIZE) / 2);
		origin_y = Std.int((camera.height - GRID_HEIGHT * CELL_SIZE) / 2);
		
		duck_graphic = Assets.getMovieClip ("graphics:duck");
		addChild (duck_graphic);
		
		ducklings = new Array<Duckling>();
		for (i in 0...2) {
			var duckling = new Duckling();
			duckling.sprite = Assets.getMovieClip("graphics:duckling");
			duckling.target_y = duck_target_y + i + 1;
			duckling.speed_y = duck_speed_y;
			duckling.x = duck_grid_x;
			duckling.y = duck_grid_y + i +1;
			
			ducklings.push(duckling);
			
			addChild(duckling.sprite);
		}
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var millisec_delta:Float = delta_time / 1000;
		
		var remaining_distance = (duck_target_x - duck_grid_x) + (duck_target_y - duck_grid_y); // one is always 0
		
		var traverse = duck_speed_x * millisec_delta + duck_speed_y * millisec_delta; // one is always 0
		
		if (Math.abs(traverse) < Math.abs(remaining_distance)) {
			duck_grid_x += duck_speed_x * millisec_delta;
			duck_grid_y += duck_speed_y * millisec_delta;
		} else {
			var traverse_before = traverse - remaining_distance;
			
			var traverse_after = traverse - traverse_before;
			
			if (input_direction != None && duck_direction != input_direction) {
				// change of direction
				switch (duck_direction) {
					case Up | Down :
						duck_grid_x += traverse_after;
						duck_grid_y = duck_target_y;
					case Left | Right :
						duck_grid_x = duck_target_x;
						duck_grid_y += traverse_after;
					case None:
						None;
				}
				
				duck_direction = input_direction;
			}
			input_direction = None;
			
			switch (duck_direction) {
				case Left:
					duck_target_x -= 1;
					duck_speed_x =-walk_speed; duck_speed_y =  0;
				case Right:
					duck_target_x += 1;
					duck_speed_x = walk_speed; duck_speed_y = 0;
				case Up:
					duck_target_y -= 1;
					duck_speed_x = 0; duck_speed_y = -walk_speed;
				case Down:
					duck_target_y += 1;
					duck_speed_x = 0; duck_speed_y = walk_speed;
				case None:
					throw "Error";
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
		
		duck_graphic.x = origin_x + duck_grid_x * CELL_SIZE - camera.x;
		duck_graphic.y = origin_y + duck_grid_y * CELL_SIZE - camera.y;
		
		for (duckling in ducklings) {
			duckling.sprite.x = origin_x + duckling.x * CELL_SIZE - camera.x;
			duckling.sprite.y = origin_y + duckling.y * CELL_SIZE - camera.y;
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