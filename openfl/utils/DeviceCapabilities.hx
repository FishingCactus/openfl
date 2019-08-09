package openfl.utils;

#if (js && html5)
import js.Browser;
#end

class DeviceCapabilities
{

    private static var isMobileSafariValue = false;
    private static var isMobileSafariValueAlreadyChecked = false;

    public static function isMobileSafari(): Bool
    {
        if (!isMobileSafariValueAlreadyChecked)
        {
            #if (js && html5)
                var navigator = Browser.navigator;
                if (navigator == null)
                {
                    return false;
                }

                var ua = navigator.userAgent;
                var iOS = ua.indexOf("iPad") != -1 || ua.indexOf("iPhone") != -1;
                var webkit = ua.indexOf("WebKit") != -1;
                var iOSSafari = iOS && webkit && ua.indexOf("CriOS") == -1;
                isMobileSafariValue = iOSSafari;
                isMobileSafariValueAlreadyChecked = true;
            #else
            isMobileSafariValueAlreadyChecked = true;
            isMobileSafariValue = false;
            #end

        }

        return isMobileSafariValue;
    }

}