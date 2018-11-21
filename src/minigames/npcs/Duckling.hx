package minigames.npcs;

import minigames.core.NPC;

/**
 * ...
 * @author Dimitar
 */
class Duckling extends NPC {
	
	public var target_x:Float;
	public var target_y:Float;
	
	public var speed_x:Float;
	public var speed_y:Float;

	public function new() {
		super();
		speed_x = speed_y = 0;
	}
	
}