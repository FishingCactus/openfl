package openfl.display.api;

interface ISpritesheet
{
    function getBitmapDataByFrameName(frameName:String): IBitmapData;
    function getDisplayObjectByFrameName(frameName:String) : DisplayObject;
    function isBitmapExcluded(frameName:String) : Bool;
}
