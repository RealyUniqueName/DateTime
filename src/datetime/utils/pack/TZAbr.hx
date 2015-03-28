package datetime.utils.pack;


/**
* Timezone abbreviation structure for encoding timezones
*
*/
class TZAbr {
    /** abbreviation */
    public var name (default,null) : String;
    /** abbreviation index in abbreviations dictionary */
    public var idx (default,null) : Int;
    // * whether this abbreviation is for DST or not
    // public var isDst (default,null) : Bool;


    /**
    * Constructor
    *
    */
    public function new (name:String, idx:Int /*, isDst:Bool */) : Void {
        this.name  = name;
        this.idx   = idx;
        // this.isDst = isDst;
    }//function new()

}//class TZAbr