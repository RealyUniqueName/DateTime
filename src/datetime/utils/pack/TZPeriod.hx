package datetime.utils.pack;

import datetime.DateTime;


/**
* Each line from zdump can be represented by this structure
*
*/
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
    public function new (utc:DateTime, abr:String, isDst:Bool, offset:Int) : Void {
        this.utc    = utc;
        this.abr    = abr;
        this.isDst  = isDst;
        this.offset = offset;
    }//function new()


    /**
    * Check if this period contains specified `utc` time
    *
    */
    public function containts (utc:DateTime) : Bool {
        return false;
    }//function containts()


    /**
    * Get string representation of this period
    *
    */
    public function toString () : String {
        return '{ isDst => ' + (isDst ? 'true' : 'false') + ', offset => $offset, abr => $abr, utc => "$utc" }';
    }//function toString()

}//class TZPeriod