import h2d.Object;

/**
 * A class that really extends something the host compiled, used here as a writer.
 *
 * Every other fixture in this project extends a host class to be read from or called on. This one
 * writes, because that is the half nothing covered: a screen setting the global that says where to
 * go next is the most ordinary thing a project does, and it was going somewhere nobody else looked.
 */
class Board extends Object {
	public function new() {
		super();
	}

	/** Writes a static of another module. */
	public function point(at:Dynamic):Void {
		Shared.pending = at;
	}

	/** Reads the same one back. */
	public function seen():Dynamic {
		return Shared.pending;
	}
}
