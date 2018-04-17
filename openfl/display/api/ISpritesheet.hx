package openfl.display.api;

interface ISpritesheet
{
    function getBitmapDataByFrameName(frameName:String): BitmapData;
    function getDisplayObjectByFrameName(frameName:String) : DisplayObject;
}
