using Toybox.Application;
using Toybox.WatchUi;
using Toybox.ActivityRecording;

var session = null;

class SailingApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        if ($.session != null && $.session.isRecording()) {
            $.session.stop();
            $.session.save();
            $.session = null;
            System.println("Session saved");
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new SailingView(), new SailingDelegate() ];
    }

}
