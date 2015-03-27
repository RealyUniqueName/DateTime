package datetime.utils.pack;

import datetime.DateTime;
import datetime.utils.pack.TZPeriod;


/**
* Time period in timezone data
*
*/
@:allow(datetime.utils.pack)
@:allow(TZBuilder)
interface IPeriod {
    /** First second of this period */
    public var utc (default,null) : DateTime;


    /**
    * Get period from one time switch to another switch, which contains `utc`
    *
    */
    public function getTZPeriod (utc:DateTime) : TZPeriod ;


    /**
    * Get time offset at the first second of this period
    *
    */
    public function getStartingOffset () : Int ;


    /**
    * Get string representation of this period
    *
    */
    public function toString () : String ;


}//interface IPeriod