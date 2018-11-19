package minigames.core;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Dimitar
 */
class Game extends Sprite {
	
	public var camera:Rectangle;
	public var duck_position:Point;
	
	private var paused:Bool;
	
	private var time:Int;
	
	private var key_event_filter:Map<Int, String>;

	public function new() {
		super();
		
		camera = new Rectangle(0, 0, 800, 600);
		
		paused = false;
		
		time = Lib.getTimer();
		
		key_event_filter = new Map();
		
		addEventListener(Event.ADDED_TO_STAGE, function (event:Event) {
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
		});
		
		addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event) {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
		});
	}
	
	public function pause(val:Bool):Void{
		paused = val;
	}
	
	private function onEnterFrame(event:Event):Void{
		var current_time:Int = Lib.getTimer();
		var delta:Int = current_time - time;
		
		loop(delta);
		
		time = current_time;
	}
	
	private function loop(delta_time:Int):Void{
		if (!paused) update(delta_time);
		render(delta_time);
	}
	
	private function update(delta_time:Int):Void{
		
	}
	
	private function render(delta_time:Int):Void{
		
	}
	
	private function onKeyboardEvent(event:KeyboardEvent):Void{
		switch(event.keyCode){
			case Keyboard.LEFT | Keyboard.RIGHT | Keyboard.UP | Keyboard.DOWN | Keyboard.SPACE:
				if (key_event_filter.get(event.keyCode) != event.type){
					handleKeyboardEvent(event);
					key_event_filter.set(event.keyCode, event.type);
				}
			default:
				return;
		}
	}
	
	private function handleKeyboardEvent(event:KeyboardEvent): Void{
		
	}
	
}