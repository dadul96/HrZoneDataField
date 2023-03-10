import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class HrZoneDataFieldView extends WatchUi.DataField {

    private const refreshDelaySeconds = 4 as Lang.Number;

    private var hrZones as HrZoneHandler = new HrZoneHandler() as HrZoneHandler;
    private var refreshCounter as Lang.Number = refreshDelaySeconds as Lang.Number;
    private var percentages as Lang.Array<Lang.Number> = [0, 0, 0, 0, 0, 0] as Lang.Array<Lang.Number>;

    function initialize() {
        DataField.initialize();
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var screenHeight = dc.getHeight().toFloat() as Lang.Float;
        var fontHeight = dc.getFontHeight(Graphics.FONT_TINY).toFloat() as Lang.Float;
        var screenToFontRatio = screenHeight/fontHeight as Lang.Float;
        var screenToFontRatioInstinct2s = 156.0/19.0 as Lang.Float; //screen height of Instinct 2s [pixel] / FONT_TINY height [pixel]
        var scalingFactor = screenToFontRatio/screenToFontRatioInstinct2s as Lang.Float;
        var drawableIds = ["zone0_text_id", "zone1_text_id", "zone2_text_id", "zone3_text_id", "zone4_text_id", "zone5_text_id"] as Lang.Array<Lang.String>;

        View.setLayout(Rez.Layouts.MainLayout(dc));

        for (var i = 0 as Lang.Number; i < drawableIds.size(); i += 1) {
            var labelView = View.findDrawableById(drawableIds[i]) as WatchUi.Drawable or Null;
            if (labelView != null) {
                labelView.locX = 15.0*scalingFactor;
                labelView.locY = (screenHeight/2.0) - (fontHeight*scalingFactor*(i+1-drawableIds.size()/2).toFloat());
            }
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if (info has :currentHeartRate) {
            if (info.currentHeartRate != null) {
                hrZones.addNewHrValue(info.currentHeartRate as Lang.Number);
            }
        }
        return;
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color

        if (refreshCounter >= refreshDelaySeconds) {
            refreshCounter = 0;
            hrZones.calculatePercentages();
            percentages = hrZones.getPercentages();
        }
        else {
            refreshCounter += 1;
        }

        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        var zone0_text = View.findDrawableById("zone0_text_id") as Text;
        var zone1_text = View.findDrawableById("zone1_text_id") as Text;
        var zone2_text = View.findDrawableById("zone2_text_id") as Text;
        var zone3_text = View.findDrawableById("zone3_text_id") as Text;
        var zone4_text = View.findDrawableById("zone4_text_id") as Text;
        var zone5_text = View.findDrawableById("zone5_text_id") as Text;

        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            zone0_text.setColor(Graphics.COLOR_WHITE);
            zone1_text.setColor(Graphics.COLOR_WHITE);
            zone2_text.setColor(Graphics.COLOR_WHITE);
            zone3_text.setColor(Graphics.COLOR_WHITE);
            zone4_text.setColor(Graphics.COLOR_WHITE);
            zone5_text.setColor(Graphics.COLOR_WHITE);
        } else {
            zone0_text.setColor(Graphics.COLOR_BLACK);
            zone1_text.setColor(Graphics.COLOR_BLACK);
            zone2_text.setColor(Graphics.COLOR_BLACK);
            zone3_text.setColor(Graphics.COLOR_BLACK);
            zone4_text.setColor(Graphics.COLOR_BLACK);
            zone5_text.setColor(Graphics.COLOR_BLACK);
        }

        zone0_text.setText("Zone0: " + percentages[0] + "%");
        zone1_text.setText("Zone1: " + percentages[1] + "%");
        zone2_text.setText("Zone2: " + percentages[2] + "%");
        zone3_text.setText("Zone3: " + percentages[3] + "%");
        zone4_text.setText("Zone4: " + percentages[4] + "%");
        zone5_text.setText("Zone5: " + percentages[5] + "%");

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
}
