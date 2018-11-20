package minigames.core;
import openfl.display.MovieClip;

/**
 * ...
 * @author Dimitar
 */
class NPC {
	
	public var x:Float;
	public var y:Float;
	
	public var sprite:MovieClip;
	
	public var to_remove:Bool;

	public function new() {
		x = y = 0;
		to_remove = false;
	}
	
}