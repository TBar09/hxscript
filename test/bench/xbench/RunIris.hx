import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

/** Runner for hscript-iris. */
class RunIris {
	static function main():Void {
		XBench.run(Sys.args()[0], prepare, exec, front);
	}

	static function prepare(src:String):Dynamic {
		// Iris keeps every instance in a static map and uniquifies names against it, so it is cleared
		// between preparations to keep that bookkeeping out of the measurement.
		Iris.instances.clear();
		var it = new Iris(src, new IrisConfig("bench", false, true, []));
		it.parse(true);
		return it;
	}

	static function exec(h:Dynamic):Dynamic {
		var it:Iris = cast h;
		return it.execute();
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
		Iris.instances.clear();

		return new Iris(src, new IrisConfig("bench", false, true, [])).execute();
	}

}
