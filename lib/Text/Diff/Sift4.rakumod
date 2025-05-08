use v6;
use nqp;

unit module Text::Diff::Sift4;

class Offset {
	has int $.c1 is built(:bind);
	has int $.c2 is built(:bind);
	has int $.trans is rw;
}

sub sift4(str $s1, str $s2, int $maxOffset = 10, int $maxDistance = 10 --> int) is export {
	my int $l1 = chars($s1);
	my int $l2 = chars($s2);

	return $l2 unless $l1;
	return $l1 unless $l2;

	my int $c1;
	my int $c2;
	my int $lcss;
	my int $local_cs;
	my int $trans;
	my @offset_arr;

	my int $i;
	my int $tempDistance;

	my int $ofs-c1;
	my int $ofs-c2;
	my Offset $ofs;

	while $c1 < $l1 and $c2 < $l2 {
		if nqp::ordat($s1, $c1) == nqp::ordat($s2, $c2) {
			++$local_cs;
			my int $isTrans;
			$i = 0;
			while $i < @offset_arr.elems {
				$ofs := @offset_arr[$i];
				$ofs-c1 = $ofs.c1;
				$ofs-c2 = $ofs.c2;
				if $c1 <= $ofs-c1 or $c2 <= $ofs-c2 {
					$isTrans = abs($c2 - $c1) >= abs($ofs-c2 - $ofs-c1);
					if $isTrans {
						++$trans;
					} else {
						if !$ofs.trans {
							$ofs.trans = 1;
							++$trans;
						}
					}
					last;
				} else {
					if $c1 > $ofs-c2 and $c2 > $ofs-c1 {
						@offset_arr.splice($i, 1);
					} else {
						++$i;
					}
				}
			}
			@offset_arr.push(Offset.new(:$c1, :$c2, trans => $isTrans));
		} else {
			$lcss += $local_cs;
			$local_cs = 0;

			if $c1 != $c2 {
				$c1 = $c2 = ($c1 min $c2);
			}

			if $maxDistance {
				$tempDistance = ($c1 max $c2) - $lcss + $trans;
				return $tempDistance if $tempDistance > $maxDistance;
			}

			loop ($i = 0; $i < $maxOffset and ($c1 + $i < $l1 or $c2 + $i < $l2); ++$i) {
				if ($c1 + $i < $l1) and nqp::ordat($s1, $c1 + $i) == nqp::ordat($s2, $c2) {
					$c1 += $i - 1;
					--$c2;
					last;
				}
				if ($c2 + $i < $l2) and nqp::ordat($s1, $c1) == nqp::ordat($s2, $c2 + $i) {
					$c2 += $i - 1;
					--$c1;
					last;
				}
			}
		}

		++$c1;
		++$c2;

		if $c1 >= $l1 or $c2 >= $l2 {
			$lcss += $local_cs;
			$local_cs = 0;
			$c1 = $c2 = ($c1 min $c2);
		}
	}

	$lcss += $local_cs;

	($l1 max $l2) - $lcss + $trans;
}

# vim: ft=perl6
