package format.swf.lite;

import format.swf.lite.symbols.BitmapSymbol;
import openfl.display.api.ISpritesheet;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.Assets;
import format.swf.lite.SWFLite;
import format.swf.lite.symbols.SimpleSpriteSymbol;
import openfl.utils.UnshrinkableArray;

class SimpleSprite extends flash.display.MovieClip
{
    private var _symbol:SimpleSpriteSymbol;
    public static var spritesheet: ISpritesheet;

    public function new(swf:SWFLite, symbol:SimpleSpriteSymbol)
    {
        _symbol = symbol;

        super();

        __totalFrames = 1;
        __currentFrame = 1;

        var bitmapSymbol:BitmapSymbol = cast(swf.symbols.get(symbol.bitmapID),BitmapSymbol);

        if (isSpritesheetImage(bitmapSymbol.path)) {
            // for reducing draw calls usePerFrameBitmapData should be set to false
            var displayObject:DisplayObject = spritesheet.getDisplayObjectByFrameName(bitmapSymbol.path);
            addDisplayObject(displayObject, symbol);
        } else {
            var bitmap = new Bitmap(Assets.getBitmapDataFromSymbol(bitmapSymbol));
            bitmap.smoothing = symbol.smooth;
            bitmap.pixelSnapping = NEVER;
            addDisplayObject(bitmap, symbol);
        }

    }

    private function isSpritesheetImage(frameName:String):Bool {
        return (spritesheet!= null && !spritesheet.isBitmapExcluded(frameName));
    }

    private function addDisplayObject(displayObject:DisplayObject, symbol:SimpleSpriteSymbol):Void
    {
        displayObject.__transform.copyFrom(symbol.matrix);
        addChild(displayObject);
    }

    private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:UnshrinkableArray<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {
        if ( !parent.mouseEnabled && interactiveOnly ) {
            return false;
        }
        return super.__hitTest(x,y,shapeFlag,stack,interactiveOnly,hitObject);
    }

    public override function getSymbol():format.swf.lite.symbols.SWFSymbol{
        return _symbol;
    }
}
