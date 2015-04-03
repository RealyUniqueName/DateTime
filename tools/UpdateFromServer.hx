package tools;

import haxe.Http;
import neko.vm.Module;
import sys.FileSystem;
import sys.io.File;


using StringTools;


/**
* Utility to download fresh compiled TZDatabase from doc.stablex.ru server
*
*/
class UpdateFromServer {

    /**
    * Entry point
    *
    */
    static public function main () : Void {
        var url : String = 'http://doc.stablex.ru/tz.dat';

        Sys.println('Downloading from $url ...');
        var tzdata : String = Http.requestUrl('$url');

        var file   : String = FileSystem.fullPath(Module.local().name);
        file = file.replace('run.n', '') + 'src/datetime/data/tz.dat';

        Sys.println('Saving to $file');
        File.saveContent(file, tzdata);

        Sys.println('Done!');
    }//function main()

}//class UpdateFromServer