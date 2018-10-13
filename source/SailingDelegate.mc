using Toybox.WatchUi;

class SailingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
//        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }


}