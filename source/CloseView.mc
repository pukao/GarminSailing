using Toybox.WatchUi;
import Toybox.Lang;
using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Timer;
using Toybox.Attention;
import Toybox.Position;


class CloseInputDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack(){
        System.println("Back to sailing");
        WatchUi.popView(SLIDE_IMMEDIATE);
        return true;
    }

    function onNextPage(){
        System.println("Close app");
        System.exit();
        // return true;
    }
}

class CloseView extends WatchUi.View {

    function initialize() {
        System.println("Close view");
        View.initialize();
    }

    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc) as Void {
        setLayout($.Rez.Layouts.CloseLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("Pushed end view");
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc) as Void {
        var device = System.getDeviceSettings();

        (findDrawableById("HeaderLabel") as WatchUi.Text).setText("Close app?");

        if (device.isTouchScreen){
            (findDrawableById("TouchLabel") as WatchUi.Text).setText("On touch devices\nswipe up");
        }

        // (findDrawableById("ButtonsLabel") as WatchUi.Text).setText("Buttons");
        (findDrawableById("ConfirmLabel") as WatchUi.Text).setText("Yes");
        (findDrawableById("BackLabel") as WatchUi.Text).setText("No");


        View.onUpdate(dc);
    }

}
