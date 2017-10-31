package format.swf.lite.symbols;

import openfl.ObjectPool;
import openfl.display.DisplayObject;
import openfl.display.BitmapData;

@:keepSub class SWFSymbol implements hxbit.Serializable {


	@:s public var className:String = "";
	@:s public var id:Int = -1;

	public var poolable(default, set):Bool = false;
	public var pool:ObjectPool<DisplayObject>;
	public var useUniqueSharedBitmapCache = false;
	public var uniqueSharedCachedBitmap:BitmapData = null;
	public var pixelPerfectHitTest:Bool = true;
	public var forbidCachedBitmapUpdate:Bool = false;

	public function new () {

	}

	public function set_poolable(value:Bool):Bool {

		if (value && pool == null) {
			pool = new ObjectPool<DisplayObject>( function() { throw "Forbidden"; return null; } );
		}

		return poolable = value;
	}

	public function initPool(swflite:format.swf.lite.SWFLite, count:Int):Void {
		#if dev
			if (pool != null) throw ":TODO: support pool resize";
		#end

		pool = new ObjectPool<DisplayObject>( function() { throw "Forbidden"; return null; } );

		for (i in 0...count) {
			var instance = swflite.createMovieClip (className);
			pool.put (instance);
		}

		poolable = true;
	}

	public function toString():String {
		return 'SWFSymbol[id: $id, name: $className] ';
	}

}
