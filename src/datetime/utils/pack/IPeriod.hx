package datetime.utils.pack;

import datetime.DateTime;


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
    * Get string representation of this period
    *
    */
    public function toString () : String ;


}//interface IPeriod