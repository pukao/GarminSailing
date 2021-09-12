using Toybox.Application;
using Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Application.Properties;

var session = null;

var setting_regatta_mode = false;
var setting_lap_time = true;

var setting_experimental_heading = false;

class SailingApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        self.onSettingsChanged();
    }

    function onSettingsChanged() {
        if (Toybox.Application has :Storage ) {
            // use Application.Storage and Application.Properties methods
            System.println("Read settings - Storage");

            setting_regatta_mode = Properties.getValue("regattaMode") == null ? false : Properties.getValue("regattaMode");
            setting_lap_time = Properties.getValue("lapTime") == null ? false : Properties.getValue("lapTime");
            setting_experimental_heading = Properties.getValue("heading") == null ? false : Properties.getValue("heading");
        } else {
            System.println("Read settings - getProperty");

            var app = Application.getApp();
            setting_regatta_mode = app.getProperty("regattaMode") == null ? false : app.getProperty("regattaMode");
            setting_lap_time = app.getProperty("lapTime") == null ? false : app.getProperty("lapTime");
            setting_experimental_heading = app.getProperty("heading") == null ? false : app.getProperty("heading");
        }
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
        var sv = new SailingView();
        return [ sv, new SailingInputDelegate(sv)];
    }

}
