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
    }
}