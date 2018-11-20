package minigames.core;

import openfl.events.Event;

/**
 * ...
 * @author Dimitar
 */
class GameEvent extends Event {
	
	public static var SCORE = "score";
	public static var INJURY = "injury";

	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
		super(type, bubbles, cancelable);
		
	}
	
}