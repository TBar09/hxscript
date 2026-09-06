/**
 * One static, written and read across module and class boundaries.
 *
 * A static has one home in Haxe and has to have one here. Two arrangements are asked about
 * separately because they failed separately: the owning module writing through its own method, and
 * a class extending a host type writing from outside. `Shared` deliberately stays a plain module so
 * the only thing that moves between these cases is who is doing the writing.
 */
class Statics {
	/** @return The names of this module's cases. */
	public static function cases():Array<String> {
		return ['ownerWriteSeenOutside', 'hostExtenderWrites', 'hostExtenderReadsBack', 'roundTrip'];
	}

	/** What the owning module's own method wrote, read from here. */
	public static function ownerWriteSeenOutside():Dynamic {
		Shared.pending = null;
		Shared.offer('offered');
		var back:String = Std.string(Shared.pending);
		Shared.pending = null;
		return back;
	}

	/** What a class extending a host type wrote, read from here. */
	public static function hostExtenderWrites():Dynamic {
		Shared.pending = null;
		var board:Dynamic = new Board();
		board.point('pointed');
		var back:String = Std.string(Shared.pending);
		Shared.pending = null;
		return back;
	}

	/** What this module wrote, read by a class extending a host type. */
	public static function hostExtenderReadsBack():Dynamic {
		Shared.pending = 'set outside';
		var board:Dynamic = new Board();
		var back:String = Std.string(board.seen());
		Shared.pending = null;
		return back;
	}

	/** Both directions in one case, so a fix for one that breaks the other cannot pass. */
	public static function roundTrip():Dynamic {
		Shared.pending = null;
		var board:Dynamic = new Board();
		board.point('from the board');
		var here:String = Std.string(Shared.pending);
		Shared.offer('from the owner');
		var there:String = Std.string(board.seen());
		Shared.pending = null;
		return here + ' | ' + there;
	}
}
