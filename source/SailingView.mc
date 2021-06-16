using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.Timer;
using Toybox.Attention;

class SailingView extends WatchUi.View {
    var mps_to_kts = 1.943844492;
    var m_to_nm = 0.000539957;
    var update_timer = null;

    var countdownDefault = 300; // 5 min
    var countdownRemaining = 0;
    var countdownTimer = null;

    var lapTime = 0;


    function initialize() {
        System.println("Start position request");
        View.initialize();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, self.method(:onPosition));
        update_timer = new Timer.Timer();
        // onUpdate every 500ms
        update_timer.start(method(:refreshView), 500, true);
        countdownTimer = new Timer.Timer();
    }

    function onPosition(info) {
        if (info == null || info.accuracy == null) {
            return;
        }

        if (info.accuracy != Position.QUALITY_GOOD) {
            return;
        }

        if ($.session == null) {
            System.println("Position usable. Start recording.");
            $.session = ActivityRecording.createSession({
                         :name=>"Sailing",
                         :sport=>32, // SPORT_SAILING 32
                        });
            $.session.start();
        }
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        return true;
    }

    function refreshView() {
        try {
            WatchUi.requestUpdate();
        } catch (ex) {
            System.println("Error.. Activity Info not available. " + ex.getErrorMessage());
        }
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        var height = dc.getHeight();
        var width = dc.getWidth();


        // Fill the entire background with Black.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, width, height);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var battery = System.getSystemStats().battery;
        if (battery <= 30) {
            if (battery <= 10) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(width * 0.30 ,(height * 0.05), Graphics.FONT_MEDIUM, "B", Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var clockTime = System.getClockTime();
        var time = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");
        dc.drawText(width * 0.50 ,(height * 0.05), Graphics.FONT_MEDIUM, time, Graphics.TEXT_JUSTIFY_CENTER);

        try {
            if ($.session != null && $.session.isRecording()) {
                drawSailInfo(dc);
            } else {
				dc.drawText(width * 0.50 ,(height * 0.50), Graphics.FONT_SMALL, "Waiting for GPS", Graphics.TEXT_JUSTIFY_CENTER);
            }
        } catch (ex) {
            System.println("Error.. Activity Info not available. " + ex.getErrorMessage());
        }
    }

    function drawSailInfo(dc) {
        var height = dc.getHeight();
        var width = dc.getWidth();
        var activity = Activity.getActivityInfo();

        // Activity.Info maxSpeed in m/s
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        var maxSpeed = activity.maxSpeed;
        if (maxSpeed == null) { maxSpeed = 0; }
        maxSpeed = maxSpeed * mps_to_kts;
        maxSpeed = maxSpeed.format("%02.1f");
        dc.drawText(width * 0.88 ,(height * 0.43), Graphics.FONT_XTINY, maxSpeed, Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (isCountdownRunning()) {
            // do not show the speed but the remaining time
            var time = (countdownRemaining / 60).format("%d") + ":" + (countdownRemaining % 60).format("%02d");
            dc.drawText(width * 0.70 ,(height * 0.50), Graphics.FONT_NUMBER_THAI_HOT, time, Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            // Activity.Info currentSpeed in m/s
            var speed = activity.currentSpeed;
            if (speed == null) { speed = 0; }
            var knots = (speed * mps_to_kts).format("%02.1f");
            dc.drawText(width * 0.70 ,(height * 0.50), Graphics.FONT_NUMBER_THAI_HOT, knots, Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(width * 0.90 ,(height * 0.57), Graphics.FONT_LARGE, "kts", Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Activity.Info elapsedDistance in meters
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var distance = activity.elapsedDistance;
        if (distance == null) { distance = 0; }
        distance = distance * m_to_nm;
        distance = distance.format("%02.2f");
        dc.drawText(width * 0.62, (height * 0.73), Graphics.FONT_TINY, distance, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width * 0.62, (height * 0.73), Graphics.FONT_TINY, " nm", Graphics.TEXT_JUSTIFY_LEFT);

        // Activity.Info elapsedTime in ms
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timer = activity.elapsedTime;
        if (timer == null) { timer = 0; }
        timer = timer / 1000;
        timer = ((timer / 60) / 60).format("%d") + ":" + ((timer / 60) % 60).format("%02d")
				+ ":" + (timer % 60).format("%02d");
        dc.drawText(width * 0.62, (height * 0.83), Graphics.FONT_TINY, timer, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width * 0.62, (height * 0.83), Graphics.FONT_TINY, " h", Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // Countdown handling
    function isCountdownRunning() {
        return (countdownRemaining > 0);
    }

    var countdownStep = 30;
    function fixTimeUp() {
        if (isCountdownRunning()) {
            // connect iq does not support (-countdownRemaining % contdownStep) to return
            // the proper value, thus this workaround must be used
            var modify = (countdownRemaining % countdownStep) - countdownStep;
            countdownRemaining -= modify;
            System.println("fixTimeUp " + countdownRemaining);
        }
    }

    function fixTimeDown() {
        if (isCountdownRunning() and countdownRemaining > countdownStep) {
            var modify = (countdownRemaining % countdownStep);
            if (modify == 0) { modify = countdownStep; }
            countdownRemaining -= modify;
            if (countdownRemaining < 0) {
                countdownRemaining = 0;
            }
            System.println("fixTimeUpDown " + countdownRemaining);
        }
    }

    function startCountdown() {
        countdownRemaining = countdownDefault;
        countdownTimer.start( method(:countdownCallback), 1000, true );
    }

    function countdownCallback()
    {
        if(countdownRemaining > 0){
            if(countdownRemaining <= 10){
                ring(1);
            }
            if((countdownRemaining - 1) == 30){
                ring(3);
            }
            if((countdownRemaining - 1) == 60){
                    ring(1);
            }
            countdownRemaining -= 1;
        } else {
            endCountdown();
        }
    }

    function endCountdown() {
        if ($.session != null && $.session.isRecording()) {
            $.session.addLap();
            lapTime = Activity.getActivityInfo().elapsedTime;
        }
        countdownRemaining = 0;
        countdownTimer.stop();
    }

    function ring(loops){
        if (loops > 4) {
            System.println("The vibrate profile only supprts 8");
            loops = 4;
        }
        System.println("Ring ring");
        if (Attention has :vibrate) {
            var vibeData = new [loops * 2];
            for (var i = 0; i < loops * 2; i += 2) {
                vibeData[i] = new Attention.VibeProfile(100, 450); // On for mseconds
                vibeData[i+1] = new Attention.VibeProfile(0, 450); // Off for mseconds
            }
            Attention.vibrate(vibeData);
        }
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_ALARM);
        }
    }

}

class SailingInputDelegate extends WatchUi.BehaviorDelegate {
    var sailView = null;
    function initialize(sv) {
        BehaviorDelegate.initialize();
        sailView = sv;
    }

    function onSelect(){
        System.println("select pressed");
        sailView.startCountdown();
    }

    function onPreviousPage(){
        System.println("up pressed");
        sailView.fixTimeUp();
    }

    function onNextPage(){
        System.println("down pressed");
        sailView.fixTimeDown();
    }


}
