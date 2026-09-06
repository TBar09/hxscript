/** Runner for the classic hscript API, used for both hscript and hscript-improved. */
class RunHscript {
	static function main():Void {
		XBench.run(Sys.args()[0], prepare, exec, front);
	}

	static function prepare(src:String):Dynamic {
		var p = new hscript.Parser();
		p.allowTypes = true;
		p.allowJSON = true;
		p.allowMetadata = true;
		return {ast: p.parseString(src, "bench"), interp: new hscript.Interp()};
	}

	static function exec(h:Dynamic):Dynamic {
		var i:hscript.Interp = h.interp;
		return i.execute(h.ast);
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
		var p = new hscript.Parser();
		p.allowTypes = true;
		p.allowJSON = true;
		p.allowMetadata = true;

		return new hscript.Interp().execute(p.parseString(src, "bench"));
	}

}
