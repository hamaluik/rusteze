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

    /**
     Returns `res` if the result is `Ok`, otherwise returns the `Err` value of `self`.

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.and
     **/
    @:generic
    public inline static function and<T, E, U>(self: Result<T, E>, res: Result<U, E>): Result<U, E> {
        return switch(self) {
            case Ok(_): res;
            case Err(e): Err(e);
        };
    }

    /**
     Calls `op` if the result is `Ok`, otherwise returns the `Err` value of `self`.

     This function can be used for control flow based on `Result` values.

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.and_then
     **/
    @:generic
    public inline static function and_then<T, E, U>(self: Result<T, E>, op: (v: T) -> Result<U, E>): Result<U, E> {
        return switch(self) {
            case Ok(v): op(v);
            case Err(e): Err(e);
        };
    }

    /**
     Returns `res` if the result is `Err`, otherwise returns the `Ok` value of `self`.

     Arguments passed to `or` are eagerly evaluated; if you are passing the result
     of a function call, it is recommended to use `or_else`, which is lazily evaluated.

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.or
     **/
    @:generic
    public inline static function or<T, E, F>(self: Result<T, E>, res: Result<T, F>): Result<T, F> {
        return switch(self) {
            case Err(_): res;
            case Ok(v): Ok(v);
        };
    }

    /**
     Calls `op` if the result is `Err`, otherwise returns the `Ok` value of `self`.

     This function can be used for control flow based on result values.

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.or_else
     **/
    @:generic
    public inline static function or_else<T, E, F>(self: Result<T, E>, op: (e: E) -> Result<T, F>): Result<T, F> {
        return switch(self) {
            case Err(e): op(e);
            case Ok(v): Ok(v);
        };
    }

    /**
     Unwraps a result, yielding the content of an `Ok`. Else, it returns `optb`.

     Arugments passed to `unwrap_or` are eagerly evaluated; if you are passing the
     result of a function call, it is recommended to use `unwrap_or_else`, which
     is lazily evaluated.

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_or
     **/
    @:generic
    public inline static function unwrap_or<T, E>(self: Result<T, E>, optb: T): T {
        return switch(self) {
            case Ok(v): v;
            case Err(_): optb;
        };
    }

    /**
     Unwraps a result, yielding the content of an `Ok`. If the value is an `Err`
     then it calls `op` with its value.

     ```haxe
     function count(x: String): Int { return x.length }
     assert_eq(Ok(2).unwrap_or_else(count), 2);
     assert_eq(Err("foo").unwrap_or_else(count), 3);
     ```

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_or_else
     **/
    @:generic
    public inline static function unwrap_or_else<T, E>(self: Result<T, E>, op: (e: E) -> T): T {
        return switch(self) {
            case Ok(v): v;
            case Err(e): op(e);
        };
    }

    /**
     Unwraps a result, yielding the content of an `Ok`.

     ```haxe
     final x: Result<Int, String> = Ok(2);
     assert_eq(x.unwrap(), 2);
     ```

     ```haxe
     final x: Result<Int, String> = Err("emergency failure");
     x.unwrap(); // throws `emergency failure`
     ```

     @throws String if the value is an `Err`, with a panic message provided by the `Err`'s value.
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap
     **/
    @:generic
    public inline static function unwrap<V, E>(self: Result<V, E>): V {
        return switch(self) {
            case Ok(v): v;
            case Err(e): throw Std.string(e);
        };
    }

    /**
     Unwraps a result, yielding the content of an `Ok`.

     ```haxe
     final x: Result<Int, String> = Err("emergency failure");
     x.expect("Testing expect"); // panics with `Testing expect: emergency failure`
     ```

     @throws String if the value is an `Err`, with a panic message including the passed message, and the content of the `Err`.
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.expect
     **/
    @:generic
    public inline static function expect<V, E>(self: Result<V, E>, msg: String): V {
        return switch(self) {
            case Ok(v): v;
            case Err(e): throw msg + ": " + Std.string(e);
        };
    }

    /**
     Unwraps a result, yielding the content of an `Err`.

     ```haxe
     final x: Result<Int, String> = Ok(2);
     x.unwrap_err(); // panics with `2`
     ```

     ```haxe
     final x: Result<Int, String> = Err("emergency failure");
     assert_eq(x.unwrap_err(), "emergency failure");
     ```

     @throws String if the value is an `Ok`, with a panic message provided by the `Ok`'s value.
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_err
     **/
    @:generic
    public inline static function unwrap_err<T, E>(self: Result<T, E>): E {
        return switch(self) {
            case Ok(v): throw Std.string(v);
            case Err(e): e;
        };
    }

    /**
     Unwraps a result, yielding the content of an `Err`.

     ```haxe
     final x: Result<Int, String> = Ok(10);
     x.expect("Testing expect_err"); // panics with `Testing expect_err: 10`
     ```

     @throws String if the value is an `Err`, with a panic message including the passed message, and the content of the `Err`.
     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.expect
     **/
    @:generic
    public inline static function expect_err<V, E>(self: Result<V, E>, msg: String): E {
        return switch(self) {
            case Ok(v): throw msg + ": " + Std.string(v);
            case Err(e): e;
        };
    }

    /**
     Transposes a `Result` of an `Option` into an `Option` of a `Result`.

     `Ok(None)` will be mapped to `None`.
     `Ok(Some(_))` and `Err(_)` will be mapped to `Some(Ok(_))` and `Some(Err(_))`.

     ```haxe
     final x: Result<Option<Int>, String> = Ok(Some(5));
     final y: Option<Result<Int, String>> = Some(Ok(5));
     assert_eq(x.transpose(), y);
     ```

     @see https://doc.rust-lang.org/std/result/enum.Result.html#method.transpose
     **/
    @:generic
    public inline static function transpose<T, E>(self: Result<Option<T>, E>): Option<Result<T, E>> {
        return switch(self) {
            case Ok(o): switch(o) {
                case Some(v): Some(Ok(v));
                case None: None;
            }
            case Err(e): Some(Err(e));
        };
    }
}