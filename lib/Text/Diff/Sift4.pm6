use v6;
use nqp;

unit module Text::Diff::Sift4;

sub sift4(Str() $s1, Str() $s2, Int $maxOffset = 100, Int $maxDistance = 100 --> Int) is export {
	my int $l1 = nqp::chars($s1);
	my int $l2 = nqp::chars($s2);

	return !$s2 ?? 0 !! $l2 if !$s1 or !$l1;
	return $l1 if !$s2 or !$l2;

	my int ($c1, $c2, $lcss, $local_cs, $trans) = (0, 0, 0, 0, 0);
	my @offset_arr;

	while nqp::islt_i($c1, $l1) and nqp::islt_i($c2, $l2) {
		if nqp::eqat($s1, nqp::substr($s2, $c2, 1), $c1) {
			++$local_cs;
			my Bool $isTrans = False;
			my int $i = 0;
			while nqp::islt_i($i, @offset_arr.elems) {
				my %ofs := @offset_arr[$i];
				if nqp::isle_i($c1, %ofs<c1>) or nqp::isle_i($c2, %ofs<c2>) {
					$isTrans = ?nqp::isge_i(nqp::abs_i($c2 - $c1), nqp::abs_i(%ofs<c2> - %ofs<c1>));
					if $isTrans {
						++$trans;
					} elsif !%ofs<trans> {
						%ofs<trans> = True;
						++$trans;
					}
					last;
				} else {
					if nqp::isgt_i($c1, %ofs<c2>) and nqp::isgt_i($c2, %ofs<c1>) {
						@offset_arr.splice($i, 1);
					} else {
						++$i;
					}
				}
			}
			@offset_arr.push({c1 => $c1, c2 => $c2, trans => $isTrans});
		} else {
			$lcss += $local_cs;
			$local_cs = 0;

			$c1 = $c2 = ($c1 min $c2) if nqp::isne_i($c1, $c2);

			loop (my int $i = 0; nqp::islt_i($i, $maxOffset) and (nqp::islt_i($c1 + $i, $l1) or nqp::islt_i($c2 + $i, $l2)); ++$i) {
				if nqp::islt_i($c1 + $i, $l1) and nqp::eqat($s1, nqp::substr($s2, $c2, 1), $c1 + $i) {
					$c1 += $i - 1;
					--$c2;
					last;
				}
				if nqp::islt_i($c2 + $i, $l2) and nqp::eqat($s1, nqp::substr($s2, $c2 + $i, 1), $c1) {
					$c2 += $i - 1;
					--$c1;
					last;
				}
			}
		}

		++$c1;
		++$c2;

		if $maxDistance {
			my int $tempDistance = ($c1 max $c2) - $lcss + $trans;
			return $tempDistance if nqp::isge_i($tempDistance, $maxDistance);
		}

		if nqp::isge_i($c1, $l1) or nqp::isge_i($c2, $l2) {
			$lcss += $local_cs;
			$local_cs = 0;
			$c1 = $c2 = ($c1 min $c2);
		}
	}

	$lcss += $local_cs;

	($l1 max $l2) - $lcss + $trans;
}

# vim: ft=perl6
