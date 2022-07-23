import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.ActivityRecording;
import Toybox.Application.Storage;

using Toybox.Application.Properties;

var session as Session? = null;

var setting_regatta_mode as Boolean? = false;
var setting_lap_time as Boolean? = true;

var setting_experimental_heading as Boolean? = false;
var setting_developer as Boolean? = false;

class SailingApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        self.onSettingsChanged();
    }

    function onSettingsChanged() {
        if (Toybox.Application has :Properties ) {
            // use Application.Storage and Application.Properties methods
            System.println("Read settings - Properties");

            setting_regatta_mode = Properties.getValue("regattaMode");
            setting_lap_time = Properties.getValue("lapTime");
            setting_experimental_heading = Properties.getValue("heading");
            setting_developer = Properties.getValue("developer");
        } else {
            System.println("Read settings - getProperty");

            var app = Application.getApp();
            setting_regatta_mode = app.getProperty("regattaMode") == null ? setting_regatta_mode : app.getProperty("regattaMode");
            setting_lap_time = app.getProperty("lapTime") == null ? setting_lap_time : app.getProperty("lapTime");
            setting_experimental_heading = app.getProperty("heading") == null ? setting_experimental_heading : app.getProperty("heading");
            setting_developer = app.getProperty("developer") == null ? setting_developer : app.getProperty("developer");
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        if ($.session != null) {
            if($.session.isRecording()) {
                $.session.stop();
                $.session.save();
                $.session = null;
                System.println("Session saved");
            }
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        var sv = new SailingView();
        return [ sv, new SailingInputDelegate(sv)] as Array<Views or InputDelegates>;
    }

}
