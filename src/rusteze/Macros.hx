package rusteze;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;
using haxe.macro.ExprTools;
#end

/**
 Haxe re-implementations of various Rust macros
 **/
class Macros {
    /**
     Ensure that a boolean expression is `true` at runtime. Optionally provide a
     second parameter to use for a custom exception message

     ```haxe
     assert(true);

     function some_computation(): Bool { return true; }
     assert(some_computation());

     // assert with a custom message
     final x: Bool = true;
     assert(x, "x wasn't true!");

     final a = 3; final b = 27;
     assert(a + b == 30, 'a = $a, b = $b');
     ```

     @throws String if the provided expression cannot be evaluated to true at runtime
     @see https://doc.rust-lang.org/1.8.0/std/macro.assert!.html
     **/
    macro public static function assert(expr: ExprOf<Bool>, extra: Array<Expr>): Expr {
        final exprString: String = extra.length > 0 ? Std.string(extra[0].getValue()) : expr.toString();
        return macro @:pos(Context.currentPos()) if(!${expr}) throw 'assertion failed: $exprString';
    }

    /**
     Ensure that a boolean expression is `true` at runtime. Optionally provide a
     second parameter to use for a custom exception message

     Unlike `assert`, `debug_assert` statements are only enabled if the Haxe compiler
     is invoked with the `-debug` flag. This makes `debug_assert` useful for checks
     that are too expensive to be present in a release build but may be helpful
     during development.

     ```haxe
     assert(true);

     function some_computation(): Bool { return true; }
     assert(some_computation());

     // assert with a custom message
     final x: Bool = true;
     assert(x, "x wasn't true!");

     final a = 3; final b = 27;
     assert(a + b == 30, 'a = $a, b = $b');
     ```

     @throws String if the provided expression cannot be evaluated to true at runtime
     @see https://doc.rust-lang.org/1.8.0/std/macro.debug_assert!.html
     **/
    macro public static function debug_assert(expr: ExprOf<Bool>, extra: Array<Expr>): Expr {
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
     assert_eq(a, b);
     ```

     @throws String the values of the expressions if the two are not equal to each other
     @see https://doc.rust-lang.org/1.8.0/std/macro.assert_eq!.html
     **/
    macro public static function assert_eq(left: Expr, right: Expr): Expr {
        final lv: String = left.toString();
        final rv: String = right.toString();
        return macro @:pos(Context.currentPos()) if(${left} != ${right}) throw 'assertion failed: `(left == right)`\n left: `$lv`\nright: `$rv`';
    }

    /**
     Asserts that two expressions are equal to each other.

     Unlike `assert_eq`, `debug_assert_eq` statements are only enabled if the Haxe compiler
     is invoked with the `-debug` flag. This makes `debug_assert_eq` useful for checks
     that are too expensive to be present in a release build but may be helpful
     during development.

     ```haxe
     final a: Int = 3;
     final b: Int = 1 + 2;
     debug_assert_eq(a, b);
     ```

     @throws String the values of the expressions if the two are not equal to each other
     @see https://doc.rust-lang.org/1.8.0/std/macro.assert_eq!.html
     **/
    macro public static function debug_assert_eq(left: Expr, right: Expr): Expr {
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
     emitted. To not emit a compile error, use the `option_env` macro instead.

     ```haxe
     final path: String = env("PATH");
     Sys.println("the $PATH variable at the time of compiling was: " + path);
     ```
     **/
    macro public static function env(name: String): ExprOf<String> {
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
     final key: Option<String> = option_env("SECRET_KEY");
     Sys.println("the secret key might be: " + Std.string(key));
     ```
     **/
    macro public static function option_env(name: String): ExprOf<rusteze.Option<String>> {
        final value: Null<String> = Sys.getEnv(name);
        if(value == null) return macro @:pos(Context.currentPos()) rusteze.Option.None;
        return macro @:pos(Context.currentPos()) rusteze.Option.Some('$value');
    }

    /**
     Includes a utf8-encoded file as a string.

     This macro will yield an expression of type `String` which is the contents
     of the filename specified. The file is located relative to the current file.
     **/
    macro public static function include_str(path: String): ExprOf<String> {
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
     **/
    macro public static function include_bytes(path: String): ExprOf<haxe.io.Bytes> {
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
     **/
    macro public static function concat(e1: Expr, rest: Array<Expr>): ExprOf<String> {
        var s: String = [e1].concat(rest).map((e) -> Std.string(e.getValue())).join("");
        return macro @:pos(Context.currentPos()) '$s';
    }

    macro public static function println(format: ExprOf<String>, args: Array<Expr>): Expr {
        var s: String = format.getValue() + "\n";
        // TODO: figure out how to emit a format string which is a concatenation
        // of the args
        //for(i in 0...args.length) {
        //    var index: Int = s.indexOf("{}");
        //    if(index == -1) {
        //        Context.error('argument `${args[i].toString()}` never used', args[i].pos);
        //    }
        //    s = s.substring(0, index)
        //}
        return macro @:pos(Context.currentPos()) {
            #if sys
            Sys.stdout().writeString($v{s});
            Sys.stdout().flush();
            #elseif hxnodejs
            Sys.stdout().writeString($v{s});
            #elseif js
            js.html.Console.log($v{s});
            #else
            trace($v{s});
            #end
        };
    }
}