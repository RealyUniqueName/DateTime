package datetime.utils.pack;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import haxe.zip.Uncompress;



/**
* Uncompress tz data compressed with tools/TZBuilder
*
*/
class Decoder {


    /**
    * Decode string to Bytes
    *
    */
    static public function decode (data:String) : Bytes {
        var bytes : Bytes = Base64.decode(data);

        return Uncompress.run(bytes);
    }//function decode()


    /**
    * Build map of timezones stored in `bytes` to be able to quickly find any timezone
    *
    */
    static public function getTzMap (bytes:Bytes) : Map<String,Int> {
        var pos = 0;
        var length : Int;
        var name   : String;

        var map = new Map<String,Int>();

        while (pos < bytes.length)
        {
trace(pos);
            length = bytes.get(pos);
            pos ++;

            name = bytes.getString(pos, length);
            pos += length;
trace(name);
            length = Std.int(bytes.getFloat(pos));
            map.set(name, pos + 1);

            pos += length;
            // if (pos < 0) trace(name);
        }

        return map;
    }//function getTzMap()

}//class Decoder