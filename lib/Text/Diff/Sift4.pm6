use v6;
use nqp;

unit module Text::Diff::Sift4;

sub sift4(Str() $s1, Str() $s2, Int $maxOffset = 100, Int $maxDistance = 100 --> Int) is export {
	return !$s2 ?? 0 !! $s2.chars if !$s1 or !$s1.chars;
	return $s1.chars if !$s2 or !$s2.chars;

	my int $l1 = $s1.chars;
	my int $l2 = $s2.chars;

	my int ($c1, $c2, $lcss, $local_cs, $trans) = (0, 0, 0, 0, 0);
	my @offset_arr;

	while $c1 < $l1 and $c2 < $l2 {
		if nqp::eqat($s1, nqp::substr($s2, $c2, 1), $c1) {
			++$local_cs;
			my Bool $isTrans = False;
			my int $i = 0;
			while $i < @offset_arr.elems {
				my %ofs := @offset_arr[$i];
				if $c1 <= %ofs<c1> or $c2 <= %ofs<c2> {
					$isTrans = abs($c2 - $c1) >= abs(%ofs<c2> - %ofs<c1>);
					if $isTrans {
						++$trans;
					} else {
						if !%ofs<trans> {
							%ofs<trans> = True;
							++$trans;
						}
					}
					last;
				} else {
					if $c1 > %ofs<c2> and $c2 > %ofs<c1> {
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

			if $c1 != $c2 {
				$c1 = $c2 = ($c1 min $c2);
			}

			loop (my int $i = 0; $i < $maxOffset and ($c1 + $i < $l1 or $c2 + $i < $l2); ++$i) {
				if ($c1 + $i < $l1) and nqp::eqat($s1, nqp::substr($s2, $c2, 1), $c1 + $i) {
					$c1 += $i - 1;
					--$c2;
					last;
				}
				if ($c2 + $i < $l2) and nqp::eqat($s1, nqp::substr($s2, $c2 + $i, 1), $c1) {
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
			return $tempDistance if $tempDistance >= $maxDistance;
		}

		if $c1 >= $l1 or $c2 >= $l2 {
			$lcss += $local_cs;
			$local_cs = 0;
			$c1 = $c2 = ($c1 min $c2);
		}
	}

	$lcss += $local_cs;

	return ($l1 max $l2) - $lcss + $trans;
}

# vim: ft=perl6
