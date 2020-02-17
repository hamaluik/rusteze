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

@:nullSafety
class ResultTools {
    @:generic
    public inline static function unwrap<V, E>(x: Result<V, E>): V {
        return switch(x) {
            case Ok(v): v;
            case Err(e): throw 'unwrapped result is err: ${Std.string(e)}';
        };
    }

    @:generic
    public inline static function expect<V, E>(x: Result<V, E>, msg: String): V {
        return switch(x) {
            case Ok(v): v;
            case Err(_): throw msg;
        };
    }
}