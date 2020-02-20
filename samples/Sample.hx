class Sample {
    static function divide(numerator: Float, denominator: Float): Option<Float> {
        return if(denominator == 0.0) {
            None;
        }
        else {
            Some(numerator / denominator);
        };
    }

    public static function main() {
        // optionals
        final result = divide(2.0, 3.0);
        switch(result) {
            case Some(x): Sys.println('Result: $x');
            case None:    Sys.println('Cannot divide by 0');
        }

        // iterators
        var arr: Array<Int> = [0, 1, 2, 3];
        for(i_squared in arr.iter().map((i) -> i * i)) {
            Sys.print('$i_squared, ');
        }
        Sys.println('');

        // iterators are lazily evaluated
        var iter = arr.iter().map((i) -> i*i);
        Sys.println(Std.string(iter.next()));
        Sys.println(Std.string(iter.next()));
        Sys.println(Std.string(iter.next()));
        Sys.println(Std.string(iter.next()));

        // iterators have some helper functionality
        var iter = arr.iter();
        Sys.println('there are ${iter.count()} items');

        // runtime assertions
        final theAnswer: Int = 5;
        try { debug_assert_eq_(theAnswer, 2); }
        catch(s: String) { Sys.println(s); }
        try { assert_(theAnswer == 42, "the life, the universe, everything"); }
        catch(s: String) { Sys.println(s); }

        // printing
        println_("a = {}, b = `{}`, c = {}", 42, "The cow jumped over the moon", Math.cos(Math.PI / 4));
        eprintln_("error... erro.. err. e");
        dbg_({
            x: 42,
            b: Math.cos(Math.PI / 4) * theAnswer,
        });

        // utility macros
        final compileTimePathVar: String = env_("PATH");
        Sys.println("PATH at compile-time was: " + compileTimePathVar);
        final ab: String = concat_("a", "b");
        assert_eq_(ab, "ab");
        function test(): Result<Int, String> {
            var ret: Result<Int, String> = try_(Err("no answer for you!"));
            return Ok(42);
        }
        var testResult: Result<Int, String> = test();
        dbg_(testResult);

        // macros to include strings inline and bytes as resources
        final importContents: String = include_str_("import.hx");
        Sys.println("the contents of `import.hx` are:\n" + importContents);
        final samplesHxmlBytes: haxe.io.Bytes = include_bytes_("../samples.hxml");
        Sys.println('the sample.hxml file has ${samplesHxmlBytes.length} bytes');

        todo_("call my agent");
    }
}