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
    /**
     Returns `true` if the result is `Ok`
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.is_ok
    **/
    @:generic
    public inline static function is_ok<T, E>(self: Result<T, E>): Bool {
        return switch(self) {
            case Ok(_): true;
            case Err(_): false;
        };
    }

    /**
     Returns `true` if the result is `Err`
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.is_err
    **/
    @:generic
    public inline static function is_err<T, E>(self: Result<T, E>): Bool {
        return switch(self) {
            case Ok(_): false;
            case Err(_): true;
        };
    }

    /**
     Returns `true` if the result is an `Ok` value containing the given value

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.contains
    **/
    @:generic
    public inline static function contains<T, E>(self: Result<T, E>, x: T): Bool {
        return switch(self) {
            case Ok(self): self == x;
            case _: false;
        };
    }

    /**
     Returns `true` if the result is an `Ok` value containing the given value

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.contains_err
    **/
    @:generic
    public inline static function contains_err<T, E>(self: Result<T, E>, e: E): Bool {
        return switch(self) {
            case Err(self): self == e;
            case _: false;
        };
    }

    /**
     Converts from `Result<T, E>` to `Option<T>`.

     Converts `self` into an `Option<T>`, consuming `self`, and discarding the
     error, if any.
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.ok
    **/
    @:generic
    public inline static function ok<T, E>(self: Result<T, E>): Option<T> {
        return switch(self) {
            case Ok(v): Some(v);
            case _:     None;
        };
    }

    /**
     Converts from `Result<T, E>` to `Option<E>`.

     Converts `self` into an `Option<E>`, consuming `self`, and discarding the
     success value, if any.
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.ok
    **/
    @:generic
    public inline static function err<T, E>(self: Result<T, E>): Option<E> {
        return switch(self) {
            case Err(e): Some(e);
            case _:      None;
        };
    }

    /**
     Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a contained
     `Ok` value, leaving an `Err` value untouched.

     The function can be used to compose the results of two functions.
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.map
    **/
    @:generic
    public inline static function map<T, E, U>(self: Result<T, E>, op: (v: T) -> U): Result<U, E> {
        return switch(self) {
            case Ok(v): Ok(op(v));
            case Err(e): Err(e);
        };
    }

    /**
     Apples a function to the contained value (if any), or returns the provided
     default (if not).
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or
    **/
    @:generic
    public inline static function map_or<T, E, U>(self: Result<T, E>, def: U, f: (v: T) -> U): U {
        return switch(self) {
            case Ok(t): f(t);
            case Err(_): def;
        };
    }

    /**
     Maps a `Result<T, E>` to `U` by applying a function to a contained `Ok` value,
     or a fallback function to a contained `Err` value.

     This function can be used to unpack a successful result while handling an
     error.

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or_else
    **/
    @:generic
    public inline static function map_or_else<T, E, U>(self: Result<T, E>, def: (e: E) -> U, f: (v: T) -> U): U {
        return switch(self) {
            case Ok(t): f(t);
            case Err(e): def(e);
        };
    }

    /**
     Maps a `Result<T, E>` to `Result<T, F>` by applying a function to a contained
     `Err` value, leaving an `Ok` value untouched.

     This function can be used to pass through a successful result while handling
     an error.
     
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.map_err
    **/
    @:generic
    public inline static function map_err<T, E, F>(self: Result<T, E>, op: (e: E) -> F): Result<T, F> {
        return switch(self) {
            case Ok(t): Ok(t);
            case Err(e): Err(op(e));
        };
    }

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