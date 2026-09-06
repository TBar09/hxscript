import hxscript.Script;

/** Runner for this library. `RunInsanity` is the same body against hscript-insanity's package. */
class RunHxScript {
	static function main():Void {
		XBench.run(Sys.args()[0], prepare, exec, front);
	}

	static function prepare(src:String):Dynamic {
		// `Script`'s constructor parses, so it is handed an empty source and the real one is parsed
		// once, after the hooks are installed. Constructing with `src` and re-parsing to install them
		// meant this ran the parser TWICE, which every other runner does once, and `prepare` is
		// exactly what the parse-throughput case times, so it reported roughly double.
		var s = new Script("", "bench");
		s.onParsingError = function(e) {};
		s.onProgramError = function(e) {};
		s.parse(src);
		return (s.program == null) ? null : s;
	}

	static function exec(h:Dynamic):Dynamic {
		var s:Script = cast h;
		var v:Dynamic = s.start();
		if (s.failed)
			throw "script failed";
		return v;
	}

	/**
	 * The library's own front door, for the second table: construct, parse and run in one call, with
	 * nothing hoisted and nothing shared with the other runners.
	 *
	 * Deliberately whatever this library asks a host to write, including any work it repeats
	 * internally. The other table exists to compare interpreters, so it hoists parsing out; this one
	 * exists to say what one fire-and-forget call costs, so it hoists nothing.
	 */
	static function front(src:String):Dynamic {
		var s = new Script(src, "bench");
		s.onProgramError = function(e) {};

		if (s.program == null)
			throw "parse failed";

		var v:Dynamic = s.start();
		if (s.failed)
			throw "script failed";

		return v;
	}

}
