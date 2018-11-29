package minigames.core;
import openfl.display.Sprite;

/**
 * ...
 * @author Dimitar
 */
class NPC {
	
	public var x:Float;
	public var y:Float;
	
	public var sprite:Sprite;
	
	public var to_remove:Bool;

	public function new() {
		x = y = 0;
		to_remove = false;
	}
	
}