package openfl.display; #if !openfl_legacy

import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import openfl.utils.UnshrinkableArray;

@:access(openfl.display.Graphics)

class Shape extends DisplayObject {


	public var graphics (get, null):Graphics;


	public function new () {

		super ();

	}




	// Get & Set Methods


	private function get_graphics ():Graphics {

		if (__graphics == null) {

			__graphics = new Graphics ();
			__graphics.__owner = this;

		}

		return __graphics;

	}

	private override function __getRenderBounds (rect:Rectangle):Void {

		super.__getRenderBounds (rect);

		rect.x -= __graphics.__padding / renderScaleX;
		rect.y -= __graphics.__padding / renderScaleY;

	}

    private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:UnshrinkableArray<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {
        if ( !parent.mouseEnabled && interactiveOnly ) {
            return false;
        }
        return super.__hitTest(x,y,shapeFlag,stack,interactiveOnly,hitObject);
    }

}


#else
typedef Shape = openfl._legacy.display.Shape;
#end
