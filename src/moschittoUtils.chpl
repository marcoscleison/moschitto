/*
 * Copyright (C) 2018 Marcos Cleison Silva Santana
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module moschittoUtils{

use Random;


proc randomString(size:int, dicts:string="01234567890abcdefghijklmnopqrstuwvxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"){
    ///var randCh: [1..#size] uint(8);
    var randStream:RandomStream(real) = new RandomStream(real);
    var str:string;
    var i=1;
    while (i<=size ) {
        var nextRand = randStream.getNext();
        var idx = (nextRand*(dicts.length-1)+1):int;
        str += dicts[idx];
         i+=1;
    }
    return str;
}

proc jsonToObject(str:string, type eltType):eltType{
    try{
        var obj = new eltType();
        var mem = openmem();
        var writer = mem.writer().write(str);
        var reader = mem.reader();
        reader.readf("%jt", obj);
        return obj;

    }catch{
        writeln("Could not convert json to object");
        
        writeln("++++++++++++++++++++++++++++");
        writeln(str);
        writeln("^^^^^^^^^");

        return new eltType();
    }

}

proc objectToJson(obj):string{
    try{
        var jsonstr:string = "%jt".format(obj);
        return jsonstr;

    }catch{
        writeln("Could not convert object to json");
        writeln("++++++++++++++++++++++++++++");
        writeln(obj);
        writeln("^^^^^^^^^");

        return "";
    }

}


}