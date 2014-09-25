package datetime.utils;

import haxe.macro.Context;
import haxe.macro.Expr;



/**
* Various macro utilities
*
*/
class MacroUtils {

    /**
    * Embed content of specified `file` as plain Haxe code
    *
    */
    macro static public function embedCode (file:String) : Expr {
        var selfPath : String = Context.getPosInfos(Context.currentPos()).file;

        file = selfPath.split('/').slice(0, -1).join('/') + '/$file';
        var content : String = sys.io.File.getContent(file);

        return Context.parseInlineString(content, Context.currentPos());
    }//function embedCode()


}//class MacroUtils