using Toybox.UserProfile as UserProfile;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time;
using Toybox.System;
import Toybox.Lang;

/*
    Formula for maximum heart rate:

    [1] Shargal, E et al. “Age-related maximal heart rate: examination and refinement of prediction equations.” 
    The Journal of sports medicine and physical fitness vol. 55,10 (2015): 1207-18. (https://pubmed.ncbi.nlm.nih.gov/25389634/)
*/

class HrZoneHandler {

    // properties:
    private var hrZoneThresholds as Lang.Array<Lang.Number>;
    private var secondsInZones as Lang.Array<Lang.Number> = [0, 0, 0, 0, 0, 0] as Lang.Array<Lang.Number>;
    private var percentInZones as Lang.Array<Lang.Number> = [0, 0, 0, 0, 0, 0] as Lang.Array<Lang.Number>;
    private var totalSeconds = 0 as Lang.Number;

    // constructor:
    public function initialize() {
        hrZoneThresholds = calculateZoneThresholds();
    }

    // methods:
    private function calculateZoneThresholds() as Lang.Array<Lang.Number> {

        var profileThresholds = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC) as Lang.Array<Lang.Number>;

        if (profileThresholds != null) {
            /*
                The returned Array contains zone values as follows:

                    min zone 1 -> will be used as max Hr for "zone 0"
                    max zone 1
                    max zone 2
                    max zone 3
                    max zone 4
                    max zone 5 -> can be removed
            */
            return profileThresholds.slice(0, 5);
        }
        else {
            var profile = UserProfile.getProfile() as UserProfile.Profile;
            var HrMax = 0 as Lang.Number;

            if ((profile != null) && (profile.birthYear != null)) {
                var age = (Gregorian.info(Time.today(), Time.FORMAT_SHORT).year - profile.birthYear) as Lang.Number; // calculate the age
                
                if (profile.gender == UserProfile.GENDER_FEMALE) {
                    // formula for female depending on age [1]:
                    HrMax = (209.273 - (0.804 * age)).toNumber();
                }
                else {
                    // formula for male depending on age [1]:
                    HrMax = (208.609 - (0.716 * age)).toNumber();
                }

                return getThresholdsFromHrMax(HrMax);
            } 
            else {
                // formula for "neutral" gender and age assumed to be 35 years [1]:
                HrMax = (208.852 - (0.741 * 35)).toNumber();

                return getThresholdsFromHrMax(HrMax);
            }
        }
    }
    
    private function getThresholdsFromHrMax(HrMax as Lang.Number) as Lang.Array<Lang.Number> {
        /*
        - zone 0 = rest <= 49% of HRmax (no garmin official zone)
        - zone 1 = warm-up 50-59% of HRmax
        - zone 2 = easy 60-69% of HRmax
        - zone 3 = aerobic 70-79% of HRmax
        - zone 4 = threshold 80-89% of HRmax
        - zone 5 = maximum 90-100% of HRmax
        */
    	var thresholds = [
            (HrMax * 0.49).toNumber(),
            (HrMax * 0.59).toNumber(),
            (HrMax * 0.69).toNumber(),
            (HrMax * 0.79).toNumber(),
            (HrMax * 0.89).toNumber()
        ] as Lang.Array<Lang.Number>;

        return thresholds;
    }

    public function addNewHrValue(value as Lang.Number) as Void {
        totalSeconds += 1;

        // REMARK: intentional loop unrolling for optimization
        if (value >= hrZoneThresholds[4]) {
            secondsInZones[5] = secondsInZones[5] + 1;
        }
        else if (value >= hrZoneThresholds[3]) {
            secondsInZones[4] = secondsInZones[4] + 1;
        }
        else if (value >= hrZoneThresholds[2]) {
            secondsInZones[3] = secondsInZones[3] + 1;
        }
        else if (value >= hrZoneThresholds[1]) {
            secondsInZones[2] = secondsInZones[2] + 1;
        }
        else if (value >= hrZoneThresholds[0]) {
            secondsInZones[1] = secondsInZones[1] + 1;
        }
        else {
            secondsInZones[0] = secondsInZones[0] + 1;
        }

        return;
    }

    public function calculatePercentages() as Void {
        if (totalSeconds > 0) // to prevent divided by 0 error
        {
            // REMARK: intentional loop unrolling for optimization
            percentInZones[0] = ((secondsInZones[0].toFloat()/totalSeconds.toFloat())*100.0).toNumber();
            percentInZones[1] = ((secondsInZones[1].toFloat()/totalSeconds.toFloat())*100.0).toNumber();
            percentInZones[2] = ((secondsInZones[2].toFloat()/totalSeconds.toFloat())*100.0).toNumber();
            percentInZones[3] = ((secondsInZones[3].toFloat()/totalSeconds.toFloat())*100.0).toNumber();
            percentInZones[4] = ((secondsInZones[4].toFloat()/totalSeconds.toFloat())*100.0).toNumber();
            percentInZones[5] = ((secondsInZones[5].toFloat()/totalSeconds.toFloat())*100.0).toNumber();
        }
        return;
    }

    public function getPercentages() as Lang.Array<Lang.Number> {
        return percentInZones;
    }

}