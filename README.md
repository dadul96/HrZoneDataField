# HrZoneDataField
I realy like that the Garmin app shows how many percent you have spent in each heart rate zone during an activity:

![](/doc/garmin_app_hr_zones.png)

However, you can only see this information after you have finished your workout and synced it with your phone. Reason enough for me to create this data field:

![](/doc/garmin_data_field_hr_zones.png)

### Installation
As of now, this data field is not in the Connec IQ store (this might change in the future). Therefore, you have to manually copy the [HrZoneDataField.prg](/_BINARY_OUTPUT_/HrZoneDataField.prg) file onto your smartwatch.

### Built With
* [Visual Studio Code](https://code.visualstudio.com/) - IDE used for programming
* [Garmin ConnectIQ / Monkey C](https://developer.garmin.com/connect-iq/overview/) - Garmin SDK

### Note
* Currently this data field is only available for:
  * Garmin Instinct 2
  * Garmin Instinct 2s
* In order to fit the whole text on the screen you have to choose a 2 field layout and place this data field in the larger field:

![](/doc/data_field_layout.png)

### Author
**Daniel Duller** - [dadul96](https://github.com/dadul96)

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
