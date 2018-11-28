package util;

import openfl.display.Shape;

/**
 * ...
 * @author Dimitar
 */
class Mask extends Shape {

	private var _width:Float;
	private var _height:Float;

	public function new(width, height) {
		super();
		_width = width;
		_height = height;
		
		draw_mask(0);
	}
	
	public function draw_mask(value:Float):Void{
		trace(value);
		graphics.clear();
		graphics.beginFill(0xffff00);
		graphics.drawRect((1 - value) * _width, 0, value * _width, _height);
		graphics.endFill();		
	}
}