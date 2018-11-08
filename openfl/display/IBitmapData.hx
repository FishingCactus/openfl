package openfl.display;


import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLTexture;

import openfl.display.BitmapData.TextureUvs;
import openfl.geom.Matrix;


interface IBitmapData {

	public var bd (get, null):BitmapData; // get rid of this if possible
	public var height (default, null):Float;
	public var physicalHeight (default, null):Int;
	public var physicalWidth (default, null):Int;
	public var uvData (get, set):TextureUvs;
	public var valid (get, null):Bool;
	public var width (default, null):Float;

	public function getTexture (gl:GLRenderContext):GLTexture;

	public function getLocalTransform (matrix:Matrix):Void;
}
