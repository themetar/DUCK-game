package minigames;

import minigames.core.Game;
import openfl.display.Graphics;
import openfl.display.MovieClip;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Dimitar
 */
class FishingGame extends Game {
	
	private var duck_graphic:MovieClip;

	public function new() {
		super();
		
		duck_graphic = Assets.getMovieClip ("graphics:duck");
		addChild (duck_graphic);
		
	}
	
	override function render(delta_time:Int):Void {
		super.render(delta_time);
		
		var gr:Graphics = this.graphics;
		graphics.lineStyle(1, 0xffffff);
		graphics.drawRect(camera.x, camera.y, camera.width, camera.height);
	}
	
	override function onKeyboardEvent(event:KeyboardEvent):Void {
		super.onKeyboardEvent(event);
		
		if (event.type == KeyboardEvent.KEY_DOWN && event.keyCode == Keyboard.RIGHT){
			getChildAt(numChildren - 1).x += 10;
		}
	}
}