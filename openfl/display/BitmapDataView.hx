package openfl.display;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLTexture;

import openfl._internal.renderer.RenderSession;
import openfl.display.IBitmapData;
import openfl.geom.Matrix;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;

class BitmapDataView implements IBitmapDrawable implements IBitmapData {

	public var bd(get, null):BitmapData;
	public var height (default, null):Float;
	public var physicalHeight (default, null):Int;
	public var physicalWidth (default, null):Int;
	public var src (get, never):Dynamic;
	public var uvData (get, set):TextureUvs;
	public var valid (get, null):Bool;
	public var width (default, null):Float;

	public var __worldTransform:Matrix;

	private var __bd:BitmapData;
	private var __uvData:TextureUvs;
	private var __blendMode:BlendMode;
	private var __resolvedCacheAsBitmap:Bool;

	private static var canvas:CanvasElement = cast Browser.document.createElement ("canvas");
	private static var ctx:CanvasRenderingContext2D = canvas.getContext ("2d");

	public function new (bd:BitmapData, uv:TextureUvs, width:Int, height:Int) {

		this.__bd = bd;
		__createUVs(uv.x0, uv.y0, uv.x1, uv.y1, uv.x2, uv.y2, uv.x3, uv.y3);

		this.height = this.physicalHeight = height;
		this.width = this.physicalWidth = width;
	}

	public function get_bd() {
		return __bd;
	}

	public function get_src() {
		canvas.width = Math.round (width);
		canvas.height = Math.round(height);

		ctx.setTransform (width, 0, 0, height, 0, 0);
		var w:Int = __bd.physicalWidth;
		var h:Int = __bd.physicalHeight;
		var x = __uvData.x0 * w;
		var y = __uvData.y0 * h;
		ctx.drawImage (__bd.src, x, y, width, height, 0.0, 0.0, 1.0, 1.0);

		return canvas;
	}

	public function get_uvData() {
		return __uvData;
	}

	public function get_valid() {
		return __bd.valid;
	}

	public function set_uvData(uv:TextureUvs):TextureUvs {
		__createUVs(uv.x0, uv.y0, uv.x1, uv.y1, uv.x2, uv.y2, uv.x3, uv.y3);

		return uv;
	}

	// public function dispose ():Void {
	// throw ":TODO:";
	// }


	public function getTexture (gl:GLRenderContext):GLTexture {

		return __bd.getTexture( gl );

	}

	public function getLocalTransform (matrix:Matrix):Void {
		matrix.identity();
	}

	public function __renderGL (renderSession:RenderSession):Void {
		throw ":TODO:";
	}

	public function __updateChildren (transformOnly:Bool):Void {
		throw ":TODO:";
	}

	public function __updateTransforms ():Void {
		throw ":TODO:";
	}

	private function __createUVs (	x0:Float = 0, y0:Float = 0, x1:Float = 1, y1:Float = 0, x2:Float = 1, y2:Float = 1, x3:Float = 0, y3:Float = 1):Void {

		if (__uvData == null) __uvData = TextureUvs.pool.get();

		__uvData.x0 = x0;
		__uvData.y0 = y0;
		__uvData.x1 = x1;
		__uvData.y1 = y1;
		__uvData.x2 = x2;
		__uvData.y2 = y2;
		__uvData.x3 = x3;
		__uvData.y3 = y3;

	}
}
