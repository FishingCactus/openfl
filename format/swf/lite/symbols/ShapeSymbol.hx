package format.swf.lite.symbols;


import format.swf.exporters.core.ShapeCommand;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.events.Event;
import haxe.io.Int32Array;

class ShapeSymbol extends SWFSymbol {

	@:s public var bounds:Rectangle;
	@:s public var graphics:Graphics;
	private var activeGraphicsTable:Array<Graphics> = new Array<Graphics>();

	private var __cachePrecision:Null<Int> = null;
	private var __translationCachePrecision:Null<Int> = null;
	private var cachedTable:Array<CacheEntry>;

	public var useBitmapCache(default, set):Bool = false;
	public var cachePrecision(get, set):Int;
	public var translationCachePrecision(get, set):Int;
	public var forbidClearCacheOnResize:Bool = false;

	public var snapCoordinates:Bool = false;

	static private var defaultCachePrecision:Int = 100;
	static private var defaultTranslationCachePrecision:Int = 100;
	static private var lastStageWidth:Float;
	static private var lastStageHeight:Float;
	static private var eventIsListened:Bool = false;

	static public var shapeSymbolsUsingBitmapCacheMap = new Map<Int, ShapeSymbol>();

	public function new () {

		super ();

	}

	public static function processCommands(graphics:Graphics, shapeCommands:Array<ShapeCommand>) {
		for (command in shapeCommands) {

			switch (command) {

				case BeginFill (color, alpha):

					graphics.beginFill (color, alpha);

				case BeginBitmapFill (bitmapID, matrix, repeat, smooth):

					graphics.beginBitmapFillWithId (bitmapID, matrix, repeat, smooth);

				case BeginGradientFill (fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):

					graphics.beginGradientFill (fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

				case CurveTo (controlX, controlY, anchorX, anchorY):

					graphics.curveTo (controlX, controlY, anchorX, anchorY);

				case DrawImage (bitmapID, matrix, smooth):

					graphics.drawImageWithId (bitmapID, matrix, smooth);

				case EndFill:

					graphics.endFill ();

				case LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):

					if (thickness != null) {

						graphics.lineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);

					} else {

						graphics.lineStyle ();

					}

				case LineGradientStyle (type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):

					graphics.lineGradientStyle (type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

				case LineBitmapStyle (bitmapID, matrix, repeat, smooth):

					graphics.lineBitmapStyleWithId (bitmapID, matrix, repeat, smooth);

				case LineTo (x, y):

					graphics.lineTo (x, y);

				case MoveTo (x, y):

					graphics.moveTo (x, y);

			}
		}
	}

	public function set_useBitmapCache (useBitmapCache:Bool):Bool {

		if (useBitmapCache && cachedTable == null) {
			cachedTable = new Array<CacheEntry> ();
			shapeSymbolsUsingBitmapCacheMap.set(id, this);

			if(!eventIsListened) {
				var stage = openfl.Lib.current.stage;
				lastStageWidth = stage.width;
				lastStageHeight = stage.height;
				stage.addEventListener(Event.RESIZE, __clearCachedTables);
				eventIsListened = true;
			}
		} else if ( !useBitmapCache ) {
			shapeSymbolsUsingBitmapCacheMap.remove(id);
		}

		return this.useBitmapCache = useBitmapCache;
	}

	public function getCacheEntry(renderTransform:Matrix):CacheEntry{

		var hash = CacheEntry.getHash(renderTransform, cachePrecision, translationCachePrecision);
		for (entry in cachedTable) {
			if (entry.hash == hash) {
				return entry;
			}
		}

		return null;
	}

	public function getCachedBitmapData (renderTransform:Matrix):BitmapData {

		if (useBitmapCache) {

			var entry = getCacheEntry(renderTransform);
			if(entry != null) {
				return entry.bitmapData;
			}

			if (forbidCachedBitmapUpdate && cachedTable.length > 0) {
				return cachedTable[0].bitmapData;
			}

			#if profile
				var missedCount = missedCountCachedMap[id];
				missedCount = missedCount != null ? missedCount : 0;
				++missedCount;
				missedCountCachedMap.set (id, missedCount);
			#end
		}

		#if profile
			var missedCount = missedCountMap[id];
			missedCount = missedCount != null ? missedCount : 0;
			++missedCount;
			missedCountMap.set (id, missedCount);

			if (continuousLogEnabled) {

				untyped console.log('Shape id:$id; useBitmapCache: $useBitmapCache; Missed count: $missedCount;');

			}
		#end

		return null;

	}


	public function setCachedBitmapData (bitmapData:BitmapData, renderTransform:Matrix) {

		if (!useBitmapCache) {

			return ;

		}

		cachedTable.push (new CacheEntry (bitmapData, CacheEntry.getHash(renderTransform, cachePrecision, translationCachePrecision)));

	}

	public function fillDrawCommandBuffer(shapeCommands:Array<ShapeCommand>)
	{
		graphics = @:privateAccess new Graphics();
		@:privateAccess graphics.__symbol = this;

		processCommands(graphics, shapeCommands);

		graphics.readOnly = true;
	}

	#if profile
		private static var missedCountMap = new Map<Int, Int> ();
		private static var missedCountCachedMap = new Map<Int, Int> ();
		private static var continuousLogEnabled:Bool = false;

		public static function __init__ () {

			#if js
				var tool = new lime.utils.ProfileTool("Shape");
				tool.reset = resetStatistics;
				tool.log = logStatistics;
				tool.count = enableContinuousLog;

				tool = new lime.utils.ProfileTool("ShapeCache");
				tool.reset = resetStatisticsCached;
				tool.log = logStatisticsCached;
				untyped tool.logCachedSymbolInfo = logCachedSymbolInfo;
				untyped tool.logAllCachedSymbolInfo = logAllCachedSymbolInfo;
			#end

		}

		public static function resetStatistics () {

			missedCountMap = new Map<Int, Int> ();

		}

		public static function resetStatisticsCached () {

			missedCountCachedMap = new Map<Int, Int> ();

		}

		public static function logStatistics (?threshold = 0) {

			for( id in missedCountMap.keys () ) {
				var value = missedCountMap[id];
				if(value < threshold) {
					continue;
				}
				untyped console.log('Shape id:$id; Create count: ${value}');
			}

		}

		public static function logStatisticsCached (?threshold = 0) {

			for( id in missedCountCachedMap.keys () ) {
				var value = missedCountCachedMap[id];
				if(value < threshold) {
					continue;
				}
				untyped console.log('Shape id:$id; Cache Miss count: ${value}');
			}

		}

		private static inline function _logCachedSymbolInfo (symbol:ShapeSymbol) {

			untyped console.log('Shape id:${symbol.id} (cached count:${symbol.cachedTable.length})');

			#if js
				var console =  untyped __js__("window.console");

				for( cached in symbol.cachedTable ) {
						console.debug('    hash:${cached.hash}');
				}
			#end

		}

		public static function logCachedSymbolInfo (symbolId:Int) {

			var symbol = shapeSymbolsUsingBitmapCacheMap[symbolId];
			_logCachedSymbolInfo (symbol);

		}

		public static function logAllCachedSymbolInfo (?threshold = 0) {

			var totalCached = 0;
			var approximateSize = 0;

			for(symbol in shapeSymbolsUsingBitmapCacheMap) {
				var count = symbol.cachedTable.length;

				totalCached += count;

				if ( count >= threshold) {
					_logCachedSymbolInfo (symbol);
				}

				for( cached in symbol.cachedTable ) {
					approximateSize += cached.bitmapData.physicalWidth * cached.bitmapData.physicalHeight * 4;
				}
			}

			untyped console.log('Total cached: $totalCached ; Approximate memory used: $approximateSize');

		}

		public static function enableContinuousLog (value:Bool) {

			continuousLogEnabled = value;

		}

	#end


	private function __clearCachedTable() {
		for( g in activeGraphicsTable ) {
			g.dispose(false);
		}

		for ( cache in cachedTable ) {
			if ( cache.bitmapData != null ) {
				cache.bitmapData.dispose();
			}
		}

		if ( cachedTable.length > 0 ) {
			cachedTable.splice(0, cachedTable.length);
		}
	}

	private static function __clearCachedTables(e:openfl.events.Event) {
		var width = Reflect.getProperty (e.currentTarget, "width");
		var height = Reflect.getProperty (e.currentTarget, "height");

		if(lastStageWidth != width || lastStageHeight != height) {
			for(s in shapeSymbolsUsingBitmapCacheMap) {
				if(!s.forbidClearCacheOnResize) {
					s.__clearCachedTable();
				}
			}

			lastStageWidth = width;
			lastStageHeight = height;
		}
	}

	public function get_cachePrecision ():Int {
		if (__cachePrecision == null) {
			__cachePrecision = defaultCachePrecision;
		}

		return __cachePrecision;
	}

	public function set_cachePrecision (value:Int):Int {
		#if dev
			if (__cachePrecision != null && __cachePrecision != value) {
				trace (':WARNING: ignoring cache precision change for symbol($id) from $__cachePrecision to $value');
			}
		#end

		return __cachePrecision = value;
	}

	public function get_translationCachePrecision ():Int {
		if (__translationCachePrecision == null) {
			__translationCachePrecision = defaultTranslationCachePrecision;
		}

		return __translationCachePrecision;
	}

	public function set_translationCachePrecision (value:Int):Int {
		#if dev
			if (__translationCachePrecision != null && __translationCachePrecision != value) {
				trace (':WARNING: ignoring cache precision change for symbol($id) from $__translationCachePrecision to $value');
			}
		#end

		return __translationCachePrecision = value;
	}

	public function registerGraphics(graphics:Graphics) {
		if(activeGraphicsTable.indexOf(graphics) != -1) {
			return;
		}
		activeGraphicsTable.push(graphics);
	}

	public function unregisterGraphics(graphics:Graphics) {
		activeGraphicsTable.remove(graphics);
	}
}

private class CacheEntry {

	public var bitmapData:BitmapData;
	public var hash:Int;

	public function new (bitmapData:BitmapData, hash:Int) {
		this.bitmapData = bitmapData;
		this.hash = hash;
	}

	static private var __buffer = new Int32Array(6);

	static public function getHash(matrix:Matrix, cachePrecision:Int, translationCachePrecision):Int {
		var buffer = __buffer;

		buffer[0] = Std.int(matrix.a * cachePrecision);
		buffer[1] = Std.int(matrix.b * cachePrecision);
		buffer[2] = Std.int(matrix.c * cachePrecision);
		buffer[3] = Std.int(matrix.d * cachePrecision);
		buffer[4] = Std.int((matrix.tx - Math.ffloor(matrix.tx)) * translationCachePrecision);
		buffer[5] = Std.int((matrix.ty - Math.ffloor(matrix.ty)) * translationCachePrecision);

		return haxe.crypto.Crc32.make(buffer.view.buffer);
	}
}
