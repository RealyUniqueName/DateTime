package datetime.utils.pack;

import datetime.DateTime;


/**
* Each line from zdump can be represented by this structure
*
*/
@:allow(datetime.utils.pack)
@:allow(TZBUilder)
class TZPeriod implements IPeriod {
    /** utc time to switch to new time offset */
    public var utc (default,null) : DateTime;
    /** Timezone abbreviation in effect during this offset */
    public var abr (default,null) : String;
    /** Whether this period is DST */
    public var isDst (default,null) : Bool;
    /** Time offset in seconds relative to utc */
    public var offset (default,null) : Int;


    /**
    * Constructor
    *
    */
    public function new () : Void {
    }//function new()


    /**
    * Get string representation of this period
    *
    */
    public function toString () : String {
        return '{ isDst => ' + (isDst ? 'true' : 'false') + ', offset => $offset, abr => $abr, utc => "$utc" }';
    }//function toString()

}//class TZPeriod