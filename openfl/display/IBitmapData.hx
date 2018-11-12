package openfl.display;


import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLTexture;

import openfl.geom.Matrix;


interface IBitmapData {

	public var bd (get, null):BitmapData; // get rid of this if possible
	public var height (default, null):Float;
	public var physicalHeight (default, null):Int;
	public var physicalWidth (default, null):Int;
	public var src (get, never):Dynamic;
	public var uvData (get, set):TextureUvs;
	public var valid (get, null):Bool;
	public var width (default, null):Float;

	public function getTexture (gl:GLRenderContext):GLTexture;

	public function getLocalTransform (matrix:Matrix):Void;
}

class TextureUvs {

	public static var pool: ObjectPool<TextureUvs>	= new ObjectPool<TextureUvs>( function() { return new TextureUvs(); } );

	public var x0:Float = 0;
	public var x1:Float = 0;
	public var x2:Float = 0;
	public var x3:Float = 0;
	public var y0:Float = 0;
	public var y1:Float = 0;
	public var y2:Float = 0;
	public var y3:Float = 0;

	public inline function reset():Void {
		x0 = x1 = x2 = x3 = y0 = y1 = y2 = y3 = 0;
	}

	public function new () {
	}
}