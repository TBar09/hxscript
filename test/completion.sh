#!/bin/sh
# Checks that adding this library to a build does not break an editor's completion.
#
#   sh test/completion.sh              against flixel, which is where this broke
#   GAME=openfl sh test/completion.sh  against another game library
#   GAME= sh test/completion.sh        the library on its own, with no game library
#
# A hover is asked for twice, once without the library and once with it, and both have to come back
# with the documentation written above the function. The pair is the point: the library's own cost
# is the difference between them, and a run that only asked once could not tell a broken request
# apart from a slow machine.
#
# Why this exists. A bridge re-emits its base's constructor, which means reading that constructor
# back with `Context.getTypedExpr`, and a display compile does not type a function body it was not
# asked about. That threw `Invalid expression` out of a macro rather than against any file, so the
# editor showed a hover loading and then nothing, and nothing anywhere said why. It needed a game
# library in the build to happen at all, which is why no suite here caught it: without one there are
# no scriptable bases and so no bridges to generate.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
WORK="$ROOT/bin_test/completion"
GAME=${GAME-flixel}

rm -rf "$WORK"
mkdir -p "$WORK"

cat > "$WORK/Subject.hx" <<'EOF'
class Subject {
	/** DOCSTRING-MARKER, which is what a hover has to hand back. */
	public static function documented(a:Int, b:Int):Int {
		return a + b;
	}

	static function main() {
		Sys.println(documented(1, 2));
	}
}
EOF

# The byte offset of the call inside `main`, which is what the request is anchored to. Counted rather
# than written down, so editing the file above cannot silently move it.
OFFSET=$(awk 'BEGIN{RS="\0"} {print index($0, "documented(1, 2)") + 2}' "$WORK/Subject.hx")

[ -n "$GAME" ] && WITHGAME="-lib $GAME" || WITHGAME=""

# `--no-output` is deliberately absent: a display request produces no output anyway, and passing it
# changes which compiler passes run.
ask() { # label, extra flags
  label=$1
  shift
  start=$(date +%s%N)
  out=$(cd "$WORK" && haxe -cp . $WITHGAME "$@" -main Subject -cpp bin --display "Subject.hx@$OFFSET@type" 2>&1) || true
  ms=$(( ($(date +%s%N) - start) / 1000000 ))

  if printf '%s' "$out" | grep -q 'DOCSTRING-MARKER'; then
    echo "  ok    $label: ${ms}ms, documentation returned"
    return 0
  fi

  echo "  FAIL  $label: ${ms}ms, no documentation"
  printf '%s\n' "$out" | sed 's/^/        /' | head -12
  return 1
}

echo "completion, ${GAME:-no game library}, offset $OFFSET"
failed=0
ask "without hxscript" || failed=1
ask "with hxscript   " -lib hxscript || failed=1

[ "$failed" = "0" ] || { echo "== FAILED =="; exit 1; }
echo "== ok =="
