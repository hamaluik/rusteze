/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2020 Kenton Hamaluik
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package rusteze;

/**
 An `Option` represents an optional value: every `Option` is either `Some` and
 contains a value, or `None`, and does not. 

 See `OptionTools` documentation for details.
**/
@:nullSafety
@:generic
@:using(rusteze.OptionTools)
enum Option<T> {
    Some(v: T);
    None;
}

/**
 An `Option` represents an optional value: every `Option` is either `Some` and
 contains a value, or `None`, and does not. 
**/
//@:nullSafety
//@:generic
//@:forward
//enum abstract Option<T>(haxe.ds.Option<T>) from haxe.ds.Option<T> to haxe.ds.Option<T> {
//    static function fromNull<T>(v: Null<T>): Option<T> {
//        return
//            if(v == null) haxe.ds.Option.None;
//            else haxe.ds.Option.Some(v);
//    }
//}