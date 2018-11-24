package minigames;

import minigames.core.Game;
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
	
	private static var X_SPEED:Float = 300;

	public function new() {
		super();
		
		the_duck = {
			position: {x: camera.width / 2, y: camera.height / 2},
			velocity: {x: X_SPEED, y: 0},
			sprite: Assets.getMovieClip("graphics:duck")
		};
		addChild(the_duck.sprite);
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var seconds_time = delta_time / 1000;
		
		the_duck.position.y += the_duck.velocity.y * seconds_time + gravity / 2 * seconds_time * seconds_time;
		the_duck.velocity.y += gravity * seconds_time;
		
		the_duck.position.x += the_duck.velocity.x * seconds_time;
		
		if (the_duck.position.y < 0 || the_duck.position.y > camera.height - 50) { // hardcoded duck sprite height
			the_duck.velocity.y = 0;
			
			the_duck.position.y = the_duck.position.y < 0 ? 0 : camera.height - 50;
			
		}
		
		the_duck.position.x = Math.max(0, Math.min(the_duck.position.x, camera.width - 50)); // hardcoded duck sprite width
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		the_duck.sprite.x = the_duck.position.x - camera.x;
		the_duck.sprite.y = the_duck.position.y - camera.y;
	}
	
	override function handleKeyboardEvent(event:KeyboardEvent):Void {
		super.handleKeyboardEvent(event);
		
		if (event.type == KeyboardEvent.KEY_DOWN){
			switch (event.keyCode) {
				case Keyboard.SPACE:
					the_duck.velocity.y += -600; // up
				case Keyboard.LEFT:
					the_duck.velocity.x = -X_SPEED;
				case Keyboard.RIGHT:
					the_duck.velocity.x = X_SPEED;
			}
		}
	}
	
}