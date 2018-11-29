package minigames.core;

import openfl.events.Event;

/**
 * ...
 * @author Dimitar
 */
class GameEvent extends Event {
	
	public static var SCORE = "score";
	public static var INJURY = "injury";
	
	public var screen_x:Float;
	public var screen_y:Float;

	public function new(type:String, x:Float=0, y:Float=0, bubbles:Bool=false, cancelable:Bool=false) {
		super(type, bubbles, cancelable);
		
		screen_x = x;
		screen_y = y;
	}
	
}