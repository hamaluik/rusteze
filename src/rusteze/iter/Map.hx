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

package rusteze.iter;

/**
 An iterator that maps the values of `iter` with `f`.

 This class is created by the `map` method on `Iter`. See its documentation for more.

 @see `Iter`
 @see https://doc.rust-lang.org/std/iter/struct.Map.html
**/
#if !cpp
@:generic
#end
@:keep
@:nullSafety
class Map<T, B> extends IterBase<T> {
    final f: (item: T) -> B;

    public function new(iter: Iterator<T>, f: (item: T) -> B) {
        super(iter);
        this.f = f;
    }

    public inline function hasNext(): Bool {
        return this.iter.hasNext();
    }

    public inline function next(): B {
        return this.f(this.iter.next());
    }
}