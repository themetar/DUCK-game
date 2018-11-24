package minigames;

import minigames.core.Game;
import openfl.Assets;
import openfl.display.MovieClip;

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

	public function new() {
		super();
		
		the_duck = {
			position: {x: camera.width / 2, y: camera.height / 2},
			velocity: {x: 0, y: 0},
			sprite: Assets.getMovieClip("graphics:duck")
		};
		addChild(the_duck.sprite);
	}
	
	override function update(delta_time:Int):Void {
		super.update(delta_time);
		
		var seconds_time = delta_time / 1000;
		
		the_duck.position.y += the_duck.velocity.y * seconds_time + gravity / 2 * seconds_time * seconds_time;
		the_duck.velocity.y += gravity * seconds_time;
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		the_duck.sprite.x = the_duck.position.x - camera.x;
		the_duck.sprite.y = the_duck.position.y - camera.y;
	}
	
}