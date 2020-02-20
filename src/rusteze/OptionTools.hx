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

import haxe.ds.Option;

/**
 OptionTools are automatic static extensions on the `Option` enum providing numerous
 convenience functions such as `unwrap`, `is_some`, etc
**/
@:nullSafety
class OptionTools {
    /**
     Utility to convert a `ruzteze.Option<T>` into a `haxe.ds.Option<T>`
     @param self 
     @return Bool
    **/
    @:generic
    public inline static function into_std<T>(self: Option<T>): haxe.ds.Option<T> {
        return switch(self) {
            case Some(v): haxe.ds.Option.Some(v);
            case None: haxe.ds.Option.None;
        };
    }

    /**
     Utility to convert a `haxe.ds.Option<T>` into a `rusteze.Option<T>`
     @param self 
     @return Bool
    **/
    @:generic
    public inline static function from_std<T>(self: haxe.ds.Option<T>): Option<T> {
        return switch(self) {
            case haxe.ds.Option.Some(v): Some(v);
            case haxe.ds.Option.None: None;
        };
    }

    /**
     Utility to convert a `rusteze.Option<T>` into a `Null<T>`, where `Some(v)`
     is mapped to `v` and `None` is mapped to `null`.
     @param self 
     @return Bool
    **/
    @:generic
    public inline static function into<T>(self: Option<T>): Null<T> {
        return switch(self) {
            case Some(v): v;
            case None: null;
        };
    }

    /**
     Utility to convert a `Null<T>` into a `rusteze.Option<T>`, where `null` is
     mapped to `None` and `v` is mapped to `Some(v)`
     @param self 
     @return Bool
    **/
    @:generic
    public inline static function from<T>(self: Null<T>): Option<T> {
        return switch(self) {
            case null: None;
            case v: Some(v);
        };
    }

    /**
     Returns `true` if the option is a `Some` value
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.is_some
    **/
    @:generic
    public inline static function is_some<T>(self: Option<T>): Bool {
        return switch(self) {
            case Some(_): true;
            case None: false;
        };
    }

    /**
     Returns `true` if the option is a `None` value

     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.is_none
    **/
    @:generic
    public inline static function is_none<T>(self: Option<T>): Bool {
        return switch(self) {
            case Some(_): false;
            case None: true;
        };
    }

    /**
     Returns `true` if the option is a `Some` value containing the given value

     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.contains
    **/
    @:generic
    public inline static function contains<T>(self: Option<T>, x: T): Bool {
        return switch([self, x]) {
            case [Some(self), x]: self == x;
            case [None, x]: false;
        };
    }

    /**
     Unwraps an option, yielding the content of a `Some`. Throws an exception if
     the value is a `None`, with a custom message provided by `msg`.

     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.expect
    **/
    @:generic
    public inline static function expect<T>(self: Option<T>, msg: String): T {
        return switch(self) {
            case Some(v): v;
            case None: throw msg;
        };
    }

    /**
     Moves the value `v` out of the `Option<T>` if it is `Some(v)`. In general,
     because this function may throw an exception, its use is discouraged. Instead,
     prefer to use pattern matching and handle the `None` case explicitely.

     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap
    **/
    @:generic
    public inline static function unwrap<T>(self: Option<T>): T {
        return switch(self) {
            case Some(v): v;
            case None: throw 'unwrapped option is none!';
        };
    }

    /**
     Returns the contained value or a default. Arguments passed to `unwrap_or`
     are eagerly evaluated; if you are passing the result of a function call, it
     is recommended to use `unwrap_or_else`, which is lazily evaluated

     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or
    **/
    @:generic
    public inline static function unwrap_or<T>(self: Option<T>, def: T): T {
        return switch(self) {
            case Some(v): v;
            case None: def;
        };
    }

    /**
     Returns the contained value or computes it from a closure
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or_else
    **/
    @:generic
    public inline static function unwrap_or_else<T>(self: Option<T>, def: Void->T): T {
        return switch(self) {
            case Some(v): v;
            case None: def();
        };
    }

    /**
     Maps an `Option<T>` to `Option<U>` by applying a function to a contained value
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.map
    **/
    @:generic
    public inline static function map<I, O>(self: Option<I>, f: I->O): Option<O> {
        return switch(self) {
            case Some(v): Some(f(v));
            case None: None;
        };
    }

    /**
     Applies a function to the contained value (if any), or returns the provided
     default (if not).
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or
    **/
    @:generic
    public inline static function map_or<I, O>(self: Option<I>, f: I->O, def: O): O {
        return switch(self) {
            case Some(v): f(v);
            case None: def;
        };
    }

    /**
     Applies a function to the contained value (if any), or computes a default
     (if not).
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or_else
    **/
    @:generic
    public inline static function map_or_else<I, O>(self: Option<I>, f: I->O, def: Void->O): O {
        return switch(self) {
            case Some(v): f(v);
            case None: def();
        };
    }

    /**
     Transforms the `Option<T>` into a `Result<T, E>`, mapping `Some(v)` to `Ok(v)`
     and `None` to `Err(err)`.

     Arguments passed to `ok_or` are eagerly evaluated; if you are passing the result
     of a function call, it is recommended to use `ok_or_else`, which is lazily
     evaluated.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.ok_or
    **/
    @:generic
    public inline static function ok_or<T, E>(self: Option<T>, err: E): Result<T, E> {
        return switch(self) {
            case Some(v): Ok(v);
            case None:    Err(err);
        };
    }

    /**
     Transforms the `Option<T>` into a `Result<T, E>`, mapping `Some(v)` to `Ok(v)`
     and `None` to `Err(err())`.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.ok_or_else
    **/
    @:generic
    public inline static function ok_or_else<T, E>(self: Option<T>, err: () -> E): Result<T, E> {
        return switch(self) {
            case Some(v): Ok(v);
            case None:    Err(err());
        };
    }

    /**
     Returns `None` if the option is `None`, otherwise returns `optb`.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.and
    **/
    @:generic
    public inline static function and<T, U>(self: Option<T>, optb: Option<U>): Option<U> {
        return switch(self) {
            case Some(_): optb;
            case None:    None;
        }
    }
    
    /**
     Returns `None` if the option is `None`, otherwise calls `f` with the wrapped
     value and returns the results.

     Some languages call this operation _flatmap_.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.and_then
    **/
    @:generic
    public inline static function and_then<T, U>(self: Option<T>, f: (value: T) -> Option<U>): Option<U> {
        return switch(self) {
            case None:    None;
            case Some(v): f(v);
        };
    }

    /**
     Returns `None` if the option is `None`, otherwise calls predicate with the
     wrapped value and returns:

     * `Some(t)` if `predicate` returns `true` (where `t` is the wrapped value), and
     * `None` if `predicate` returns `false`.

     This function works similar to `Iter.filter()`. You can imagine the `Option<T>`
     being an iterator over one or zero elements. `filter()` lets you decide which
     elements to keep
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.filter
    **/
    @:generic
    public inline static function filter<T>(self: Option<T>, predicate: (value: T) -> Bool): Option<T> {
        return switch(self) {
            case None:    None;
            case Some(v): if(predicate(v)) Some(v); else None;
        };
    }

    /**
     Returns the option if it contains a value, otherwise returns `optb`.

     Arguments passed to `or` are eagerly evaluated; if you are passing the result
     of a function call, it is recommended to use `or_else`, which is lazily evaluated.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.or
    **/
    @:generic
    public inline static function or<T>(self: Option<T>, optb: Option<T>): Option<T> {
        return switch(self) {
            case Some(v): self;
            case None:    optb;
        };
    }

    /**
     Returns the option if it contains a value, otherwise calls `f` and returns
     the result.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.or_else
    **/
    @:generic
    public inline static function or_else<T>(self: Option<T>, f: () -> Option<T>): Option<T> {
        return switch(self) {
            case Some(v): self;
            case None:    f();
        };
    }

    /**
     Returns `Some` if exactly one of `self`, `optb`, is `Some`, otherwise returns
     `None`.
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.xor
    **/
    @:generic
    public inline static function xor<T>(self: Option<T>, optb: Option<T>): Option<T> {
        return switch([self, optb]) {
            case [Some(a), None]: Some(a);
            case [None, Some(b)]: Some(b);
            case _:               None;
        };
    }

    /**
     Takes the value out of the option, leaving a `None` in its place
     
     @see https://doc.rust-lang.org/std/option/enum.Option.html#method.take
    **/
    @:generic
    inline static function take<T>(self: Option<T>): Option<T> {
        return switch(self) {
            case Some(v): {
                self = None;
                Some(v);
            }
            case None: None;
        };
    }
}