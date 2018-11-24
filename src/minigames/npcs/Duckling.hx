package minigames.npcs;

import minigames.core.NPC;

/**
 * ...
 * @author Dimitar
 */
class Duckling extends NPC {
	
	public var target_x:Float;
	public var target_y:Float;
	
	private var prev_target_x:Float;
	private var prev_target_y:Float;
	
	public var speed_x:Float;
	public var speed_y:Float;

	public function new() {
		super();
		speed_x = speed_y = 0;
	}
	
	public function setNewTarget(x:Float, y:Float):Duckling {
		prev_target_x = target_x;
		prev_target_y = target_y;
		
		target_x = x;
		target_y = y;
		
		return this;
	}
	
	public function rewindTaget():Duckling {
		target_x = prev_target_x;
		target_y = prev_target_y;
		
		return this;
	}
	
}