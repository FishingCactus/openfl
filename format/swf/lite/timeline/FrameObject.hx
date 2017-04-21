package format.swf.lite.timeline;


import format.swf.exporters.core.FilterType;
import flash.geom.ColorTransform;
import flash.geom.Matrix;


class FrameObject {


	public var cacheAsBitmap:Bool = false;
	public var clipDepth:Int;
	public var colorTransform:ColorTransform;
	public var depth:Int;
	public var filters:Array<FilterType>;
	public var id:Int;
	public var matrix:Matrix;
	public var name:String;
	public var symbol:Int;
	public var type:FrameObjectType;
	public var blendMode: openfl.display.BlendMode;
	public var ratio:Null<Float>;


	public function new () {

	}

	public function copyFrom(other:FrameObject) {
		id = other.id;
		type = other.type;

		merge(other);
	}

	public function merge(other:FrameObject) {
		if ( id != other.id ) {
			throw "Cannot merge 2 unrelated symbols!";
		}
		if ( other.cacheAsBitmap != null ) cacheAsBitmap = other.cacheAsBitmap;
		if ( other.clipDepth != null ) clipDepth = other.clipDepth;
		if ( other.colorTransform != null ) colorTransform = other.colorTransform;
		if ( other.depth != null ) depth = other.depth;
		if ( other.filters != null ) filters = other.filters.copy();
		if ( other.matrix != null ) matrix = other.matrix;
		if ( other.name != null ) name = other.name;
		if ( other.symbol != null ) symbol = other.symbol;
		if ( other.blendMode != null ) blendMode = other.blendMode;
		if ( other.ratio != null ) ratio = other.ratio;
	}


}
