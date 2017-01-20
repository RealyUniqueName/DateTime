package datetime.utils;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
* Various macro utilities
*
*/
class MacroUtils {
    static inline var CONST_STRING_MAX_LENGTH = 16000;

    /**
    * Embed content of specified `file` as plain Haxe code
    *
    */
    macro static public function embedCode (file:String) : Expr {
        var selfPath : String = Context.getPosInfos(Context.currentPos()).file;

        file = selfPath.split('/').slice(0, -1).join('/') + '/$file';
        if (!sys.FileSystem.exists(file)) {
            Context.warning('Can\'t find file: $file', Context.currentPos());
            return macro null;

        } else {
            var content : String = sys.io.File.getContent(file);
            return Context.parseInlineString(content, Context.currentPos());
        }
    }//function embedCode()


    /**
    * Embed content of specified `file` as a string
    *
    */
    macro static public function embedString (file:String) : ExprOf<Array<String>> {
        var selfPath : String = Context.getPosInfos(Context.currentPos()).file;

        var dir : String = selfPath.split('/').slice(0, -1).join('/');
        if (dir.length == 0) {
            dir = '.';
        }

        file = dir + '/$file';
        if (!sys.FileSystem.exists(file)) {
            Context.warning('Can\'t find file: $file', Context.currentPos());
            return macro null;

        } else {
            var content : String = sys.io.File.getContent(file);

            if (content.length <= CONST_STRING_MAX_LENGTH) {
                return macro [$v{content}];
            } else {
                var parts : Array<Expr> = [];
                var str   : String;
                while (content.length > CONST_STRING_MAX_LENGTH) {
                    str = content.substr(0, CONST_STRING_MAX_LENGTH);
                    parts.push(macro $v{str});
                    content = content.substr(CONST_STRING_MAX_LENGTH);
                }
                parts.push(macro $v{content});

                return macro $a{parts};
            }
        }
    }//function embedString()


    /**
    * Get a value of flag defined with `-D` cli argument
    *
    */
    macro static public function getDefined (defineName:String) : ExprOf<String> {
        var value = Context.definedValue(defineName);

        return macro $v{value};
    }//function getDefined()

}//class MacroUtils