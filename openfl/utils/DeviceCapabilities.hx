package openfl.utils;

#if (js && html5)
import js.Browser;
#end

class DeviceCapabilities
{

    private static var isIOsValue = false;
    private static var isIOsValueAlreadyChecked = false;
    private static var isMobileBrowserValue = false;
    private static var isMobileBrowserValueAlreadyChecked = false;

    public static function isIOs(): Bool
    {
        if (!isIOsValueAlreadyChecked)
        {
            #if (js && html5)
                var navigator = Browser.navigator;
                if (navigator == null)
                {
                    return false;
                }

                var ua = navigator.userAgent;
                var iOS = ua.indexOf("iPad") != -1 || ua.indexOf("iPhone") != -1;
                isIOsValue = iOS;
                isIOsValueAlreadyChecked = true;
            #else
            isIOsValueAlreadyChecked = true;
            isIOsValue = false;
            #end

        }

        return isIOsValue;
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