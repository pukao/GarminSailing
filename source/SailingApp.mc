using Toybox.Application;
using Toybox.WatchUi;
using Toybox.ActivityRecording;

var session = null;

class SailingApp extends Application.AppBase {
    var session = null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        $.session = ActivityRecording.createSession({
                         :name=>"Sailing",
                         :sport=>32, // SPORT_SAILING 32
                         :subSport=>ActivityRecording.SUB_SPORT_GENERIC
                        });
        $.session.start();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        if ($.session.isRecording()) {
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
