package openfl.utils;

#if (js && html5)
import js.Browser;
#end

class DeviceCapabilities
{

    private static var isMobileSafariValue = false;
    private static var isMobileSafariValueAlreadyChecked = false;
    private static var isMobileBrowserValue = false;
    private static var isMobileBrowserValueAlreadyChecked = false;

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

    public static function isMobileBrowser(): Bool
    {
        if (!isMobileBrowserValueAlreadyChecked)
        {
            #if (js && html5)

               var ua = Browser.navigator.userAgent;

                isMobileBrowserValue = ua.indexOf("Android") != -1
                || ua.indexOf("webOS") != -1
                || ua.indexOf("iPhone") != -1
                || ua.indexOf("iPad") != -1
                || ua.indexOf("iPod") != -1
                || ua.indexOf("BlackBerry") != -1
                || ua.indexOf("Windows Phone") != -1;

            #else
                isMobileBrowserValue = false;
            #end
            isMobileBrowserValueAlreadyChecked = true;
        }
        return isMobileBrowserValue;
    }
}