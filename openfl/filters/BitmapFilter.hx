package openfl.filters; #if !openfl_legacy


import openfl._internal.renderer.opengl.utils.RenderTexture;
import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.commands.*;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if (js && html5)
import js.html.ImageData;
#end

@:access(openfl.display.BitmapData)
@:access(openfl.geom.Rectangle)

class BitmapFilter {

	private var __dirty:Bool = true;
	private var __passes:Int = 0;

	public function new () {



	}


	public function clone ():BitmapFilter {

		return new BitmapFilter ();

	}

	public function dispose():Void{

	}

	#if (js && html5)
	public function __applyFilter (sourceData:ImageData, targetData:ImageData, sourceRect:Rectangle, destPoint:Point):Void {
	}
	#end


	private static function __applyFilters (filters:Array<BitmapFilter>, renderSession:RenderSession, bitmap:BitmapData) {

		if (!bitmap.__usingPingPongTexture) {
			throw ":TODO: unsupported mode";
		}


		for (filter in filters) {
			var useLastFilter = false;

			var commands = filter.__getCommands (bitmap);

			for (command in commands) {
				switch (command) {
					case Blur1D (target, source, blur, horizontal, strength, distance, angle) :
						Blur1DCommand.apply (renderSession, target, source, blur, horizontal, strength, distance, angle);

					case Offset (target, source, strength, distance, angle) :
						OffsetCommand.apply (renderSession, target, source, strength, distance, angle);

					case Colorize (target, source, color, alpha) :
						ColorizeCommand.apply (renderSession, target, source, color, alpha);

					case ColorLookup (target, source, colorLookup) :
						ColorLookupCommand.apply (renderSession, target, source, colorLookup);

					case ColorTransform (target, source, colorMatrix) :
						ColorTransformCommand.apply (renderSession, target, source, colorMatrix);

					case CombineInner (target, source1, source2) :
						CombineInnerCommand.apply (renderSession, target, source1, source2);

					case Combine (target, source1, source2) :
						CombineCommand.apply (renderSession, target, source1, source2);

					case InnerKnockout (target, source1, source2) :
						InnerKnockoutCommand.apply(renderSession, target, source1, source2);

					case OuterKnockout (target, source1, source2) :
						OuterKnockoutCommand.apply(renderSession, target, source1, source2);

					case OuterKnockoutTransparency (target, source1, source2, allowTransparency) :
						OuterKnockoutCommand.apply(renderSession, target, source1, source2, allowTransparency);

					case DestOut (target, source1, source2) :
						DestOutCommand.apply(renderSession, target, source1, source2);

					default :
						throw("Unsupported command!");
				}

			}

		}


	}


	private static function __expandBounds (filters:Array<BitmapFilter>, rect:Rectangle) {

		for (filter in filters) {

			filter.__growBounds (rect);

		}

	}


	private function __growBounds (rect:Rectangle) {



	}


	private function __getCommands (bitmap:BitmapData):Array<CommandType> {

		return [];

	}

}


#else
typedef BitmapFilter = openfl._legacy.filters.BitmapFilter;
#end
