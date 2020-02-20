package rusteze;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;
using haxe.macro.ExprTools;
using haxe.macro.PositionTools;
#end

/**
 Haxe re-implementations of various Rust macros
 **/
class Macros {
    /**
     Ensure that a boolean expression is `true` at runtime. Optionally provide a
     second parameter to use for a custom exception message

     ```haxe
     assert_(true);

     function some_computation(): Bool { return true; }
     assert_(some_computation());

     // assert_ with a custom message
     final x: Bool = true;
     assert_(x, "x wasn't true!");

     final a = 3; final b = 27;
     assert_(a + b == 30, 'a = $a, b = $b');
     ```

     @throws String if the provided expression cannot be evaluated to true at runtime
     @see https://doc.rust-lang.org/1.8.0/std/macro.assert!.html
     **/
    macro public static function assert_(expr: ExprOf<Bool>, extra: Array<Expr>): Expr {
        final exprString: String = extra.length > 0 ? Std.string(extra[0].getValue()) : expr.toString();
        return macro @:pos(Context.currentPos()) if(!${expr}) throw 'assertion failed: $exprString';
    }

    /**
     Ensure that a boolean expression is `true` at runtime. Optionally provide a
     second parameter to use for a custom exception message

     Unlike `assert_`, `debug_assert_` statements are only enabled if the Haxe compiler
     is invoked with the `-debug` flag. This makes `debug_assert_` useful for checks
     that are too expensive to be present in a release build but may be helpful
     during development.

     ```haxe
     assert_(true);

     function some_computation(): Bool { return true; }
     assert_(some_computation());

     // assert_ with a custom message
     final x: Bool = true;
     assert_(x, "x wasn't true!");

     final a = 3; final b = 27;
     assert_(a + b == 30, 'a = $a, b = $b');
     ```

     @throws String if the provided expression cannot be evaluated to true at runtime
     @see https://doc.rust-lang.org/1.8.0/std/macro.debug_assert!.html
     **/
    macro public static function debug_assert_(expr: ExprOf<Bool>, extra: Array<Expr>): Expr {
        #if !debug
        return macro null;
        #else
        final exprString: String = extra.length > 0 ? Std.string(extra[0].getValue()) : expr.toString();
        return macro @:pos(Context.currentPos()) if(!${expr}) throw 'assertion failed: $exprString';
        #end
    }

    /**
     Asserts that two expressions are equal to each other.

     ```haxe
     final a: Int = 3;
     final b: Int = 1 + 2;
     assert_eq_(a, b);
     ```

     @throws String the values of the expressions if the two are not equal to each other
     @see https://doc.rust-lang.org/1.8.0/std/macro.assert_eq!.html
     **/
    macro public static function assert_eq_(left: Expr, right: Expr): Expr {
        final lv: String = left.toString();
        final rv: String = right.toString();
        return macro @:pos(Context.currentPos()) if(${left} != ${right}) throw 'assertion failed: `(left == right)`\n left: `$lv`\nright: `$rv`';
    }

    /**
     Asserts that two expressions are equal to each other.

     Unlike `assert_eq_`, `debug_assert_eq_` statements are only enabled if the Haxe compiler
     is invoked with the `-debug` flag. This makes `debug_assert_eq_` useful for checks
     that are too expensive to be present in a release build but may be helpful
     during development.

     ```haxe
     final a: Int = 3;
     final b: Int = 1 + 2;
     debug_assert_eq_(a, b);
     ```

     @throws String the values of the expressions if the two are not equal to each other
     @see https://doc.rust-lang.org/1.8.0/std/macro.assert_eq!.html
     **/
    macro public static function debug_assert_eq_(left: Expr, right: Expr): Expr {
        #if !debug
        return macro null;
        #else
        final lv: String = left.toString();
        final rv: String = right.toString();
        return macro @:pos(Context.currentPos()) if(${left} != ${right}) throw 'assertion failed: `(left == right)`\n left: `$lv`\nright: `$rv`';
        #end
    }

    /**
     Inspect an environment variable at compile time.

     This macro will expand to the value of the named environment variable at compile
     time, yielding an expression of type `String`.

     If the environment variable is not defined, then a compilation error will be
     emitted. To not emit a compile error, use the `option_env_` macro instead.

     ```haxe
     final path: String = env_("PATH");
     Sys.println("the $PATH variable at the time of compiling was: " + path);
     ```

     @see https://doc.rust-lang.org/std/macro.env.html
     **/
    macro public static function env_(name: String): ExprOf<String> {
        final value: Null<String> = Sys.getEnv(name);
        if(value == null) Context.error('error: environment variable `$name` not defined', Context.currentPos());
        return macro @:pos(Context.currentPos()) '$value';
    }

    /**
     Optionally inspect an environment variable at compile time.

     If the named environment variable is present at compile time, this will expand
     into an expression of type `Option<String>` with a value of `Some`. If the
     environment variable is not present, then this will expand to `None`.

     A compile time error is never emitted when using this macro regardless of
     whether the environment variable is present or not.

     ```haxe
     final key: Option<String> = option_env_("SECRET_KEY");
     Sys.println("the secret key might be: " + Std.string(key));
     ```

     @see https://doc.rust-lang.org/std/macro.option_env.html
     **/
    macro public static function option_env_(name: String): ExprOf<rusteze.Option<String>> {
        final value: Null<String> = Sys.getEnv(name);
        if(value == null) return macro @:pos(Context.currentPos()) rusteze.Option.None;
        return macro @:pos(Context.currentPos()) rusteze.Option.Some('$value');
    }

    /**
     Includes a utf8-encoded file as a string.

     This macro will yield an expression of type `String` which is the contents
     of the filename specified. The file is located relative to the current file.

     File: `spanish.in`:

     ```
     adiós
     ```

     File: `Main.hx`:

     ```haxe
     class Main {
         public static function main() {
             final my_str = include_str_("spanish.in");
             assert_eq_(my_str, "adiós");
             println_("{}", my_str);
         }
     }
     ```

     @see https://doc.rust-lang.org/std/macro.include_str.html
     **/
    macro public static function include_str_(path: String): ExprOf<String> {
        final currentFile: String = Context.getPosInfos(Context.currentPos()).file;
        final currentFile: haxe.io.Path = new haxe.io.Path(currentFile);
        final dir: Null<String> = currentFile.dir;
        final path = dir == null ? haxe.io.Path.join([Sys.getCwd(), path]) : haxe.io.Path.join([Sys.getCwd(), dir, path]);
        if(!sys.FileSystem.exists(path)) Context.error('couldn\'t read `$path`: No such file', Context.currentPos());
        final contents: String = sys.io.File.getContent(path);
        return macro @:pos(Context.currentPos()) '$contents';
    }

    /**
     Includes a file as a byte array.
     
     This macro will yield an expression of type `haxe.io.Bytes` which is the contents
     of the filenae specified. THe file is located relative to the current file.

     @see https://doc.rust-lang.org/std/macro.include_bytes.html
     **/
    macro public static function include_bytes_(path: String): ExprOf<haxe.io.Bytes> {
        final currentFile: String = Context.getPosInfos(Context.currentPos()).file;
        final currentFile: haxe.io.Path = new haxe.io.Path(currentFile);
        final dir: Null<String> = currentFile.dir;
        final path = dir == null ? haxe.io.Path.join([Sys.getCwd(), path]) : haxe.io.Path.join([Sys.getCwd(), dir, path]);
        if(!sys.FileSystem.exists(path)) Context.error('couldn\'t read `$path`: No such file', Context.currentPos());
        if(!Context.getResources().exists(path)) {
            final bytes: haxe.io.Bytes = sys.io.File.getBytes(path);
            Context.addResource(path, bytes);
        }
        return macro @:pos(Context.currentPos()) haxe.Resource.getBytes($v{path});
    }

    /**
     Concatenates literals into a static `String`
     
     This macro takes any number of comma-separated literals, yielding an expression
     of `String` which represents all of the literals concatenated left-to-right.

     Integer and floating point literals are stringified in order to be concatenated.

     ```haxe
     final s: String = concat_("test", 10, 'b', true);
     assert_eq_(s, "test10btrue");
     ```
     
     @see https://doc.rust-lang.org/std/macro.concat.html
     **/
    macro public static function concat_(e1: Expr, rest: Array<Expr>): ExprOf<String> {
        var s: String = [e1].concat(rest).map((e) -> Std.string(e.getValue())).join("");
        return macro @:pos(Context.currentPos()) '$s';
    }

    #if macro
    static function format_args(format: String, args: Array<Expr>): ExprOf<String> {
        var count: Int = 0;
        var lastIndex: Int = -1;
        for(i in 0...format.length) {
            var index: Int = format.indexOf("{}", i);
            if(index != -1 && lastIndex != index) {
                count++;
                lastIndex = index;
            }
        }
        if(count < args.length) {
            Context.error('argument `${args[args.length - 1].toString()}` never used', args[args.length - 1].pos);
        }
        else if(count > args.length) {
            Context.error('${count} positional arguments in format string, but there is ${args.length} argument${args.length > 1 ? "s" : ""}', Context.currentPos());
        }

        var exprs: Array<ExprOf<String>> = [];
        var formatParts: Array<String> = format.split("{}");
        if(formatParts.length != args.length + 1) Context.fatalError('expected formatParts.length = args.length + 1, but got `${formatParts.length}` = `${args.length}` + 1', Context.currentPos());
        for(i in 0...args.length) {
            exprs.push(macro @:pos(Context.currentPos()) $v{formatParts[i]});
            exprs.push(macro @:pos(args[i].pos) Std.string(${args[i]}));
        }
        exprs.push(macro @:pos(Context.currentPos()) $v{formatParts[formatParts.length - 1]});
        return macro @:pos(Context.currentPos()) $a{exprs}.join("");
    }
    #end

    /**
     Creates a `String` using interpolation of runtime expressions.

     The first argument `format_` recieves is a format string. This must be a string
     literal. The power of the formatting string is in the `{}`s contained.

     Additional parameters passed to `format_` replace the `{}`s within the formatting
     string in the order given unless named or positional parameters are used, see
     `rusteze.fmt` for more information.

     A common use for `format_` is concatenation and interpolation of strings. The
     same convention is using with `print_` macros, depending on the intended destination
     of the string.

     **TODO:** indexed parameters, named parameters
     
     ```haxe
     format_("test");
     format_("hello {}", "world!");
     format_("x = {}, y = {}", 10, 30);
     ```

     @see https://doc.rust-lang.org/std/macro.format.html
    **/
    macro public static function format_(format: String, args: Array<Expr>): ExprOf<String> {
        #if display
        return macro null;
        #else
        return format_args(format, args);
        #end
    }

    /**
     Prints to the standard output.

     Equivalent to the `println_` macro except that a newline is not printed at the
     end of the message.

     Note that stdout is frequently line-buffered by default so it may be necessary
     to use `Sys.stdout().flush()` to ensure the output is emitted immediately.

     Use `print_` only for the primary output of your program. Use `eprint_` instead
     to print error and progress messatges.
     
     ```haxe
     print_("this ");
     print_("will ");
     print_("be ");
     print_("on ");
     print_("the ");
     print_("same ");
     print_("line ");
     ```

     @see https://doc.rust-lang.org/std/macro.print.html
    **/
    macro public static function print_(format: String, args: Array<Expr>): Expr {
        #if display
        return macro null;
        #else
        var s: ExprOf<String> = format_args(format, args);
        return macro @:pos(Context.currentPos()) {
            #if sys
            Sys.stdout().writeString(${s});
            #elseif js
            js.html.Console.log(${s});
            #else
            trace(${s});
            #end
        };
        #end
    }

    /**
     Prints to the standard output, with a newline.

     On all platforms, the nweline is the LINE FEED character (`\n` / `U+000A`)
     alone (no additional CARRIAGE RETURN (`\r` / `U+000D`)).

     Use the `format+` syntax to write data to the standard output.

     Use `println+` only for the primary output of your program. Use `eprintln+`
     instead to print error and progress messages.

     ```haxe
     println_(''); // prints just a newline
     println_("hello there!");
     println_("format {} arguments", "some");
     ```

     @see https://doc.rust-lang.org/std/macro.println.html
    **/
    macro public static function println_(format: String, args: Array<Expr>): Expr {
        #if display
        return macro null;
        #else
        var s: ExprOf<String> = format_args(format + "\n", args);
        return macro @:pos(Context.currentPos()) {
            #if sys
            Sys.stdout().writeString(${s});
            #if !hxnodejs // flush throws a runtime fsync error on nodejs
            Sys.stdout().flush();
            #end
            #elseif js
            js.html.Console.log(${s});
            #else
            trace(${s});
            #end
        };
        #end
    }

    /**
     Prints to the standard error.

     Equivalent to the `print_` macro, except that output goes to `Sys.stderr()`
     instead of `Sys.stdout()`. See `print_` for example usage.

     Use `eprint_` only for error and progress messaages. Use `print_` instead
     for the primary output of your program.

     ```haxe
     eprint("Error: Could not complete task")
     ```

     @see https://doc.rust-lang.org/std/macro.eprint.html
    **/
    macro public static function eprint_(format: String, args: Array<Expr>): Expr {
        #if display
        return macro null;
        #else
        var s: ExprOf<String> = format_args(format, args);
        return macro @:pos(Context.currentPos()) {
            #if sys
            Sys.stderr().writeString(${s});
            #elseif js
            js.html.Console.error(${s});
            #else
            trace(${s});
            #end
        };
        #end
    }

    /**
     Prints to the standard error, with a newline.

     Equivalent to the `println_` macro, except that output goes to `Sys.stderr()`
     instead of `Sys.stdout()`. See `println_` for example usage.

     Use `eprintln_` only for error and progress messaages. Use `println_` instead
     for the primary output of your program.

     ```haxe
     eprintln("Error: Could not complete task")
     ```

     @see https://doc.rust-lang.org/std/macro.eprintln.html
    **/
    macro public static function eprintln_(format: String, args: Array<Expr>): Expr {
        #if display
        return macro null;
        #else
        var s: ExprOf<String> = format_args(format + "\n", args);
        return macro @:pos(Context.currentPos()) {
            #if sys
            Sys.stderr().writeString(${s});
            #if !hxnodejs // flush throws a runtime fsync error on nodejs
            Sys.stderr().flush();
            #end
            #elseif js
            js.html.Console.error(${s});
            #else
            trace(${s});
            #end
        };
        #end
    }

    /**
     This macro prints the value of each argument to `stderr` along with the source
     location of the macro invocation as well as the source code of the expression.

     The `dbg_` macro works exactly the same in release builds. This is useful when
     debugging issues that only occur in release builds or when debugging in release
     mode is significantly faster.

     Note that this macro is intended as debugging tool and therefore you should
     avoid having uses of it in version control for longer periods. Use cases involving
     debug output that should be added to version control are better served by
     proper logging utilities.

     @see https://doc.rust-lang.org/std/macro.dbg.html
    **/
    macro public static function dbg_(val: Expr, rest: Array<Expr>): Expr {
        #if display
        return macro null;
        #else
        var exprs: Array<Expr> = Lambda.map([val].concat(rest), function(e: Expr): Expr {
            var label: String = e.toString() + " = ";
            return macro @pos(e.pos) '$label' + haxe.Json.stringify(${e}, null, "  ");
        });
        var loc = Context.currentPos().toLocation();
        var locString: String = '[${loc.file.toString()}:${loc.range.start.line}]';
        var s: ExprOf<String> = macro @pos(Context.currentPos()) '$locString ' + $a{exprs}.join("\n") + '\n';
        return macro @:pos(Context.currentPos()) {
            #if sys
            Sys.stderr().writeString(${s});
            #if !hxnodejs // flush throws a runtime fsync error on nodejs
            Sys.stderr().flush();
            #end
            #elseif js
            js.html.Console.error(${s});
            #else
            trace(${s});
            #end
        };
        #end
    }

    /**
     Unwraps a result or propagtes its error.

     `try_` matches the given `Result`. In case of the `Ok` variant, the expression
     has the value of the wrapped value.

     In case of the `Err` variant, it retrieves the inner error. The resulting error
     is immediately returned.

     Because of the early return, `try_` can only be used in functions that return
     `Result`.

     @see https://doc.rust-lang.org/std/macro.try.html
    **/
    macro public static function try_<T, E>(val: ExprOf<rusteze.Result<T, E>>): ExprOf<T> {
        return macro @:pos(Context.currentPos()) switch(${val}) {
            case rusteze.Result.Ok(v): v;
            case rusteze.Result.Err(e): return Err(e);
        };
    }
}