import hscript.SScript;

/**
 * Runner for SScript (SuperlativeScript).
 *
 * **Not through `SScript.execute()`**, which parses the source afresh every call and would put parse
 * cost inside the timed section where every other library has only execution there. Its `parser` and
 * `interp` are both public, so the split the harness wants is available: parse once in `prepare`,
 * run the parsed tree in `exec`, which is exactly what the RuleScript runner does for the same
 * reason.
 *
 * `doString` still runs first, because that is what fills in the origin and the presets the
 * interpreter expects to have been set up before anything executes.
 */
class RunSScript {
	static function main():Void {
		XBench.run(Sys.args()[0], prepare, exec, front);
	}

	static function prepare(src:String):Dynamic {
		var sc = new SScript();
		sc.doString(src);
		return {sc: sc, ast: sc.parser.parseString(src, "bench")};
	}

	static function exec(h:Dynamic):Dynamic {
		var sc:SScript = h.sc;
		return sc.interp.execute(h.ast);
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
		var sc = new SScript();
		sc.doString(src);
		sc.execute();

		return null;
	}

}
