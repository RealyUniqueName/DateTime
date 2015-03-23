package datetime.utils.pack;

import datetime.DateTime;


/**
* Time period in timezone data
*
*/
interface IPeriod {
    /** First second of this period */
    public var utc (default,null) : DateTime;


    /**
    * Check if this period contains specified `utc` time
    *
    */
    public function containts (utc:DateTime) : Bool ;


    /**
    * Get string representation of this period
    *
    */
    public function toString () : String ;


}//interface IPeriod