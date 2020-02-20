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

#if !cpp
@:generic
#end
/**
 Base functionality for all `rusteze` iterators. Essentially an abstract base class.

 @see https://doc.rust-lang.org/std/iter/trait.Iterator.html
**/
@:keep
@:nullSafety
class IterBase<T> {
    final iter: Iterator<T>;

    /**
     Construct a new iterator from an Std iterator
     @param iter 
    **/
    public function new(iter: Iterator<T>) {
        this.iter = iter;
    }

    /**
     Returns the bounds on the remaining length of the iterator.

     @see https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.size_hint
    **/
    public function size_hint(): { min: Int, max: Option<Int> } {
        return { min: 0, max: None };
    }

    /**
     Consumes the iterator, returning the last element
     @return Option<T>
    **/
    public function last(): Option<T> {
        return this.fold(None, (_: Option<T>, x: T) -> Some(x));
    }

    /**
     Consumes the iterator, counting the number of iterations and returning it.

     This method will call `hasNext` and `next` repeatedly until `hasNext` returns
     `false`. Note that `next` has to be called at least once even if the iterator
     does not have any elements.
     
     @see https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.count
    **/
    public function count(): Int {
        return this.fold(0, (count: Int, _: T) -> count + 1);
    }

    /**
     Takes a closure and creates an iterator which calls that closure on each
     element.

     `map()` transforms one iterator into another, by means of its argument: a
     callback. It produces a new iterator which calls this closure on each element
     of the original iterator.

     If you are good at thinking in types, you can think of `map()` like this:
     If you have an iterator that gives you elements of some type `A`, and you
     want an iterator of some other type `B`, you can use `map()`, passing a
     closure that takes an `A` and returns a `B`.

     `map()` is conceptually similar to a `for` loop. However, as `map()` is lazy,
     it is best used when you're already working with other iterators. If you're
     doing some sort of looping for a side effect, it's considered more idiomatic
     to use `for` than `map()`.
     
     @see https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.map
    **/
    public function map<U>(f: (item: T) -> U): Map<T, U> {
        return new Map(iter, f);
    }

    /**
     An iterator method that applies a function, producing a single, final value.
    
     `fold()` takes two arguments: an initial value, and a closure with two arguments:
     an 'accumulator', and an element. The closure returns the value that the accumulator
     should have for the next iteration.

     The initial value is the value the accumulator will have on the first call.

     After applying this closure to every element of the iterator, `fold()` returns
     the accumulator.

     This operation is sometimes called 'reduce' or 'inject'.

     Folding is useful whenever you have a collection of something, and want to
     produce a single value from it.

     Note: `fold()`, and similar methods that traverse the entire iterator, may
     not terminate for infinite iterators, even on iterators for which a result
     is determinable in finit time.
     
     @see https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.fold
    **/
    public function fold<U>(init: U, f: (accumulator: U, element: T) -> U): U {
        var accumulator: U = init;
        for(item in iter) accumulator = f(accumulator, item);
        return accumulator;
    }
}
