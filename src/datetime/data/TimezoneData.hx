package datetime.data;


/**
* List of all timezones
*
*/
@:allow(datetime)
@:access(datetime)
class TimezoneData {

    /** IANA timezone name */
    public var name (default,null) : String = 'UTC' ;
    /** Timezone abbreviation. E.g. EST for Eastern Time or MSK for Moscow Time */
    public var abbreviation (default,null) : String = 'UTC';
    /** Time offset in seconds relative to UTC */
    public var offset : Int = 0;
    /** time offset during Daylight Saving Time */
    public var dstOffset : Int = 0;


    /**
    * Constructor
    *
    */
    private function new () : Void {
    }//function new()

}//class TimezoneData