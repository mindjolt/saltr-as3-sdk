/**
 * User: daal
 * Date: 3/18/14
 * Time: 5:58 PM
 */
package sample {
import flash.display.Sprite;

import saltr.SLTError;

import saltr.SLTSaltrMobile;

public class Example extends Sprite{

    private static var instanceKey:String = "08626247-f03d-0d83-b69f-4f03f80ef555";
    private var _saltrMobile:SLTSaltrMobile;

    public function Example() {


        connectToSalt();
    }

    private function connectToSalt():void {
        _saltrMobile = new SLTSaltrMobile(instanceKey);
        _saltrMobile.initDevice("deviceId", "iphone");
        _saltrMobile.start(saltrLoadSuccessCallback, saltrLoadFailCallback);
    }


    private function saltrLoadSuccessCallback() : void {
        trace("[saltrLoadSuccessCallback]");
    }

    private function saltrLoadFailCallback(error : SLTError) : void {
        trace("[saltrLoadFailCallback]");
    }




}
}