using Toybox.WatchUi;

class SailingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
//        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == KEY_ENTER) {
            System.println("The button was pressed");
        }
        return true;
    }

}